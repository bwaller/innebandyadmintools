require 'sinatra'

set :bind, '0.0.0.0'
 
get '/generate' do
  result_file = `/usr/bin/ruby parse.rb 479`.split(" ").last
  send_file result_file, :filename => result_file, :type => 'Application/octet-stream' 
end

