#!/usr/bin/env ruby
# this file is alpha quality, conventions will change, feedback welcome

class CodeError < StandardError
  attr_reader :code
  def initialize(message, code = 1)
    super(message)
    @code = code
  end
end

class AbstractHelpError < StandardError
  attr_accessor :help
  attr_reader :code
  def initialize(message = "")
    super(message)
    @error_message = message
    @code = 22
  end
  def to_s
    message = @help
    if @error_message && !@error_message.empty?
      message += "\n\nERROR: #{@error_message}"
    end
    message
  end
end

def exit_with_error(error, status = nil)
  if status.nil? || status < 0
    status = error.respond_to?(:code) ? error.code : 1
  else
    status
  end
  STDERR.puts error.to_s
  exit status
end

def write_stdout_stringify(output)
  write_stdout_plain(JSON.generate(output))
end

def write_stdout_plain(output)
  print output
end

def write_stdout_pretty(output)
  puts JSON.pretty_generate(output)
end

def read_stdin_whole
  STDIN.read
end
