#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'

venuesdoc = Nokogiri::HTML(open("http://www.innebandy.se/Stockholm/Tavling/Hallforteckning/"))
venues = venuesdoc.css("html body#ctl00_htmlElmBody form#aspnetForm div#MainWrapper div#SiteWrapper div#ctl00_Content div#Center div#MainBody.articlePageBody div p a")
venueshash = Hash.new
venues.each do |venue|
  venueshash[venue.content.strip] = venue["href"]
  puts venue.content.strip + " " + venueshash[venue.content.strip]
end
#Fix missing venues
venueshash["Björkebyhallen"] = venueshash["Björkeby Sporthall"]
venueshash["Hammarbackens Sporthall"] = venueshash["Hammarbackshallen"]
venueshash["Åkersberga Sporthall A"] = venueshash["Åkersberga Sporthall"]
venueshash["Ekhammarshallen"] = venueshash["Ekhammarhallen"]
venueshash["Vikingavallen - Bollhallen Täby IP"] = venueshash["Vikingavallen Täby IP"]
venueshash["Strandhallen - Tyresö"] = venueshash["Strandhallen"]
venueshash["Söderbymalmskolan"] = venueshash["Söderbymalmsskolan"]

def get_address(venue_url)
  puts venue_url
  venuedoc = Nokogiri::HTML(open(venue_url))
  venueaddress = venuedoc.css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span")
  street_address, postal_code, locality = "UNDEFINED"
  venueaddress.each do |element|
    street_address = element.content.strip if element["class"].match("street-address")
    postal_code = element.content.strip if element["class"].match("postal-code")
    locality = element.content.strip if element["class"].match("locality")
  end
  puts street_address, postal_code, locality
  return street_address, postal_code, locality
end

eventdoc = Nokogiri::HTML(open("http://statistik.innebandy.se/ft.aspx?scr=teamresult&flid=484"))   
events = eventdoc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr")
events.each do |event|
  event.css("span").each do |span|
    event_date = DateTime.parse(span.content)
    home_team, away_team, arena = ""
    event.css("a").each do |element|
      if element["href"].match("result") and !element["class"]  then
        home_team, away_team = element.content.split(" - ")
        home_team.strip
        away_team.strip
      end
      arena = element.content.strip if element["href"].match("venue")
    end
    puts arena
    street_address, postal_code, locality = "UNDEFINED"
    street_address, postal_code, locality = get_address(venueshash[arena])
    puts event_date.strftime("%F %T") + " " + home_team + " vs " + away_team + " at " + arena + " " + street_address + " " + postal_code + " " + locality
  end  
end


