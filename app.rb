require 'sinatra'

configure do
  set :data_path, File.absolute_path(ARGV.shift || './data')
end

post '/:name' do |name|
  out_path = File.join(settings.data_path, name)
  puts "writing to: #{out_path}"
  FileUtils.mkdir_p File.dirname(out_path)
  request.body.rewind
  File.write(out_path, request.body.read)
end
