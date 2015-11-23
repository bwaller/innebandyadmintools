#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './venue.rb'

class Serie

  attr_accessor :name, :url, :name, :events
  
  def initialize(name, url)
    @name = name
    @url = url
    @events = Hash.new
  end

  def populate(venues)
    htmldoc = Nokogiri::HTML(open(url))   
    records = htmldoc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr")
    records.each do |record|
      record.css("span").each do |span|
        event_start = DateTime.parse(span.content)
        url, home_team, away_team = ""
        venue, id = 0
        record.css("a").each do |element|
          if element["href"].match("result") and !element["class"]  then
            home_team, away_team = element.content.split(" - ")
            home_team.strip
            away_team.strip
            url = element["href"]
            id = get_id_from_url(url)
          end
          venue = venues[element.content.strip] if element["href"].match("venue")
          puts "No venue information for " + element.content.strip if !venue
        end
        @events[id] = Event.new(event_start, event_start + Rational(1,24), home_team, away_team, venue, url, true)
      end  
    end
  end

  def get_id_from_url(url)
    doc_url = "http://statistik.innebandy.se/" + url
    eventdoc = Nokogiri::HTML(open(doc_url))
    record = eventdoc.css("html body div#container div#IbisInfo.ibisinfo div.clMatchView div.wide-load div#iList div#iSelection div table#iMatchInfo.clCommonGrid tbody tr") 
    record.each do |element|
      if element.content.match("Matchnummer") then
        return element.search("td").to_a[1].content
      end
    end
    return -1
  end
end

