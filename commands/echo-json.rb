#!/usr/bin/env ruby

require 'json'
require_relative '../sources/rb.rb'

class HelpError < AbstractHelpError
  def initialize(message = "")
    super(message)
    self.help = [
      'USAGE:',
      'echo-json.rb <make> [--] ...[<key> <value>]',
      'echo-json.rb <stringify|encode|decode|json|pretty> [--] ...<input>',
    ].join("\n")
  end
end

def real(input)
  begin
    JSON.parse(input)
  rescue
    input
  end
end

def parse_json(input)
  begin
    { parseError: nil, value: JSON.parse(input) }
  rescue => parseError
    { parseError: parseError, value: input }
  end
end

def main(*args)
  # parse <action>
  if args.length == 0
    raise HelpError.new("No <action> was provided.")
  end
  actions = ['make', 'stringify', 'encode', 'decode', 'json', 'pretty']
  unless actions.include?(args[0])
    raise HelpError.new("An unrecognised <action> was provided: #{args[0]}")
  end
  action = args.shift
  # parse [...options] ...<input>
  properties = []
  inputs = []
  while args.length > 0
    arg = args.shift
    if arg == '--'
      inputs.concat(args)
      break
    elsif arg.start_with?('--property=')
      properties << arg.sub(/^--property=/, '')
    else
      inputs << arg
    end
  end
  # <make> ...[<key> <value>]
  if action == 'make'
    # validate we have a <value> for every <key>
    if inputs.length % 2 != 0
      raise '<make> requires an even number of <key> <value> pairs.'
    end
    # build the object
    output = {}
    while inputs.length > 0
      key = inputs.shift
      value = inputs.shift
      output[key] = real(value)
    end
    return write_stdout_stringify(output)
  end
  # <action> ...<input>
  while inputs.length > 0
    input = inputs.shift
    case action
    when 'stringify'
      write_stdout_stringify(input)
    when 'json', 'pretty'
      parsed = parse_json(input)
      if parsed[:parseError] != nil
        raise "Failed to parse what should be JSON-encoded <input> = #{parsed[:parseError].message}"
      end
      if action == 'json'
        write_stdout_stringify(parsed[:value])
      else
        write_stdout_pretty(parsed[:value])
      end
    when 'encode'
      parsed = parse_json(input)
      write_stdout_stringify(parsed[:value])
    when 'decode'
      parsed = parse_json(input)
      if properties.length == 0
        output = if parsed[:value].is_a?(Hash) || parsed[:value].is_a?(Array) || parsed[:value].nil?
                   JSON.generate(parsed[:value])
                 else
                   parsed[:value].to_s
                 end
        write_stdout_plain(output)
      else
        outputs = []
        properties.each do |property|
          keys = property.split('.')
          diver = parsed[:value]
          keys.each do |key|
            if diver.is_a?(Hash) && diver.key?(key)
              diver = diver[key]
            else
              raise "Property \"#{property}\" does not exist in the provided input."
            end
          end
          if diver.is_a?(Hash) || diver.is_a?(Array) || diver.nil?
            outputs << JSON.generate(diver)
          else
            outputs << diver.to_s
          end
        end
        write_stdout_plain(outputs.join("\n"))
      end
    when 'parse'
      parsed = parse_json(input)
      if parsed[:parseError] != nil
        raise "Failed to parse what should be JSON-encoded <input> = #{parsed[:parseError].message}"
      end
      write_stdout_pretty(parsed[:value])
    else
      raise "Invalid action: #{action}"
    end
  end
end

begin
  main(*ARGV)
rescue => error
  exit_with_error(error)
end
