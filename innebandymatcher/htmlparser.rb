#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './venue.rb'

venues = Venue.create("http://www.innebandy.se/Stockholm/Tavling/Hallforteckning/")

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
      arena = venues[element.content.strip] if element["href"].match("venue")
    end
    #puts arena
    puts event_date.strftime("%F %T") + " " + home_team + " vs " + away_team + " at " + arena.name + " " + arena.streetaddress + " " + arena.postal_code + " " + arena.locality
  end  
end


