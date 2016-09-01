require 'sinatra'

set :bind, '0.0.0.0'
#set :port, 80
 
get '/' do
  date=`date`
 "Generate excelfiles for Sportnik import<br>" + date.to_s
end

get '/generate' do
  team_id=params['team_id'].gsub("+"," ")
  command = "ruby parse.rb " + team_id
  result_file = `#{command}`
  send_file result_file, :filename => result_file, :type => 'Application/octet-stream' 
 "team_id: is #{team_id}"
end

