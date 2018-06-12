#!/usr/bin/ruby

require 'json'
require 'gooddata'

def read_users_file(filename)
  file = File.open(filename)
  result = []

  begin
    content = file.read
    records = JSON.parse(content, symbolize_names: true) unless content.chomp.empty?
    result = records[:users]
  rescue EOFError => e
    file.close
  end

  return result
end



def better_read_users_file(filename)
  File.open(filename) do |file|
    JSON.parse(file.read, symbolize_names: true)[:users]
  end
end
