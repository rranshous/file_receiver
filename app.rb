#!/usr/bin/env ruby
require 'sinatra'
require 'base64'
require 'pry'

configure do
  set :data_path, File.absolute_path(ARGV.shift || './data')
end

post '/form_file_upload' do
  if params[:file] && params[:file][:filename]
    file_name = params[:file][:filename]
    puts "received form file: #{file_name}"
    encoded_name = Base64.urlsafe_encode64 file_name
    file_path = File.join(settings.data_path, encoded_name)
    puts "writing to: #{file_path}"
    file = params[:file][:tempfile]

    File.open(file_path, 'wb') do |fh|
      fh.write(file.read)
    end
    redirect to('/')
  else
    puts "submission did not include file"
    halt 400, "missing file"
  end
end

get '/' do
  @files = Dir[File.join(settings.data_path,'*')]
            .map{|n| File.basename n }
            .map{|n| Base64.urlsafe_decode64(n) rescue nil }
            .compact
  erb :"index.html"
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

