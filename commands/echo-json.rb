#!/usr/bin/env ruby

require 'json'

def help(*args)
  STDERR.puts [
    'USAGE:',
    'echo-json.rb <stringify|encode|decode|parse> <content>',
    'echo <content> | echo-json.rb <stringify|encode|decode|parse>',
    (args.length > 0 ? ['', 'ERROR:', *args] : [])
  ].flatten.join("\n")
  exit 22
end

def parse(*args)
  if args.length == 0
    raise 'No arguments provided.'
  end

  operation = args.shift
  unless ['stringify', 'encode', 'decode', 'parse'].include?(operation)
    raise "<operation> was invalid, it was: #{operation}"
  end

  if args.length == 0
    content = read_stdin
  else
    content = args.shift
    if args.length != 0
      raise 'An unrecognised argument was provided: ' + args.first
    end
  end

  { operation: operation, content: content }
end

def write_stdout_plain(output)
  print output
end

def write_stdout_pretty(output)
  print JSON.pretty_generate(output)
end

def read_stdin
  STDIN.read
end

def main
  inputs = parse(*ARGV)
  operation = inputs[:operation]
  content = inputs[:content]

  # handle interpretation differences between stringify, encode, decode, and parse
  parsed = nil
  parse_error = nil

  if operation == 'stringify'
    parsed = content
  else
    begin
      parsed = JSON.parse(content)
    rescue JSON::ParserError => e
      parse_error = e
      parsed = content
    end
  end

  case operation
  when 'stringify', 'encode'
    begin
      output = JSON.generate(parsed)
      write_stdout_plain(output)
    rescue => e
      raise "Failed to encode the content as a JSON string: #{e.message}"
    end
  when 'decode'
    begin
      output = parsed.is_a?(Hash) || parsed.is_a?(Array) ? JSON.generate(parsed) : parsed.to_s
      write_stdout_plain(output)
    rescue => e
      raise "Failed to recode the content as a JSON string: #{e.message}"
    end
  when 'parse'
    if parse_error != nil
      raise "Failed to parse the JSON content: #{parse_error.message}"
    end
    write_stdout_pretty(parsed)
  else
    raise "Internal Error: Invalid operation: #{operation}"
  end
end

begin
  main
rescue => e
  help(e.message)
end
