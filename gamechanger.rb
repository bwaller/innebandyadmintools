# encoding: utf-8

require 'optparse'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './person.rb'

base_url = "http://statistik.innebandy.se/"
applicant_club = "Ekerö IK"

def get_contact_id(team_url)
  contact_id = 0

  team_page = Nokogiri::HTML(open(team_url)) 

  links = team_page.css('div#iList dl').css('a')
  links.each do |link|
    contact_id = link["href"].gsub(/[^0-9]/,'') if link["href"].match("scr=person")
  end

  return contact_id
end

options = OpenStruct.new
options.url = nil

OptionParser.new do |opts|

  opts.on("-u", "--url url", String, "url till matchen") do |u|
    options.url = u
  end

end.parse!

page = Nokogiri::HTML(open(options.url))

th = page.css('div#iList th')
home_team = th[0].content
home_team_url = base_url + th[0].element_children[0]["href"]

away_team = th[2].content
away_team_url = base_url + th[2].element_children[0]["href"]

elem = page.at('td:contains("Matchnummer")')
fixture_number = elem.next_element.content

elem = page.at('td:contains("Tävling")')
serie = elem.next_element.content

elem = page.at('td:contains("Tid")')
date_time = elem.next_element.content
orig_date = date_time.split(" ")[0]
orig_time = date_time.split(" ")[1]

elem = page.at('td:contains("Spelplats")')
orig_venue = elem.next_element.content.gsub(/ , /,", ")
  
if home_team.match("Ekerö") then
 applicant_person = Person.new(get_contact_id(home_team_url))
 opponent_person = Person.new(get_contact_id(away_team_url))
else
 applicant_person = Person.new(get_contact_id(away_team_url))
 opponent_person = Person.new(get_contact_id(home_team_url))
end

game_change_info = { 
  "fixture_number" => fixture_number,
  "serie" => serie,
  "home_team" => home_team,
  "away_team" => away_team,
  "orig_date" => orig_date,
  "orig_time" => orig_time,
  "orig_venue" => orig_venue,
  "new_date"  => "TBD",
  "new_time" => "TBD",
  "new_venue" => orig_venue,
  "applicant_club" => applicant_club,
  "applicant_contact" => applicant_person.name,
  "applicant_phone" => applicant_person.cell_phone,
  "applicant_email" => applicant_person.email,
  "opponent_contact" => opponent_person.name,
  "opponent_phone" => opponent_person.cell_phone,
  "opponent_email" => opponent_person.email,
  "last_entry" => 'leave_empty'
}

puts game_change_info.to_json

