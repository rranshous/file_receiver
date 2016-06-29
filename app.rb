#!/usr/bin/env ruby
require 'sinatra'
require 'base64'

configure do
  set :data_path, File.absolute_path(ARGV.shift || './data')
end

post '/*' do |name|
  encoded_name = Base64.urlsafe_encode64 name
  file_path = File.join(settings.data_path, encoded_name)
  puts "writing to: #{file_path}"
  FileUtils.mkdir_p File.dirname(file_path)
  request.body.rewind
  File.write(file_path, request.body.read)
  "success"
end

get '/*' do |name|
  encoded_name = Base64.urlsafe_encode64 name
  file_path = File.join(settings.data_path, encoded_name)
  puts "reading #{file_path}"
  if !File.exists? file_path
    puts "can't read, does not exist: #{file_path}"
    halt 404
  end
  send_file file_path
end

delete '/*' do |name|
  encoded_name = Base64.urlsafe_encode64 name
  file_path = File.join(settings.data_path, encoded_name)
  puts "deleting: #{file_path}"
  if !File.exists? file_path
    puts "can't delete, does not exist: #{file_path}"
    halt 404
  end
  File.unlink file_path
  "success"
end
