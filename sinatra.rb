require 'sinatra'

set :bind, '0.0.0.0'
#set :port, 80
 
get '/' do
  erb :main
end

get '/info' do
  erb :info
end

get '/generate' do
  team_id=params['team_id'].gsub("+"," ")
  command = "ruby parse.rb " + team_id
  result_file = `#{command}`.split(" ").last
  send_file result_file, :filename => result_file, :type => 'Application/octet-stream' 
 "team_id: is #{team_id}"
end

