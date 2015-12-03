#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './venue.rb'

class Serie

  attr_accessor :url, :events, :name, :id, :table_url
  
  def initialize(url, team)
    puts url + " " + team
    @url = url
    @events = Hash.new
    @serie_htmldoc = Nokogiri::HTML(open(url))   
    src = @serie_htmldoc.at_css("html body#ctl00_htmlElmBody form#aspnetForm div#MainWrapper div#SiteWrapper div.iframe iframe#IdaIframe")["src"]
    serie_table_htmldoc = Nokogiri::HTML(open(src))
    @name = serie_table_htmldoc.at_css("html body div#container div#IbisInfo.ibisinfo h1").content.gsub(/^.* - /,"")
    serie_table_htmldoc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid.clTblStandings.clTblWithFullToggle tbody.clGrid tr a").each do |team_anchor|
      if team_anchor.content.match(team) then
        @id = team_anchor["href"].slice(/[0-9]*$/)
        @table_url = "http://statistik.innebandy.se/ft.aspx?scr=teamresult&flid=" + @id.to_s
      end
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def populate(venues)
    table_htmldoc = Nokogiri::HTML(open(@table_url))
    records = table_htmldoc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr")
    records.each do |record|
      record.css("span").each do |span|
        event_start = DateTime.parse(span.content)
        url, home_team, away_team = ""
        venue, event_id, event_number = 0
        record.css("a").each do |element|
          if element["href"].match("result") and !element["class"]  then
            home_team, away_team = element.content.split(" - ")
            home_team.strip
            away_team.strip
            url = "http://statistik.innebandy.se/" + element["href"]
            event_id = url.match(/[0-9]*$/).to_s.to_i
            event_number = get_number_from_url(url)
          end
          venue = venues[element.content.strip] if element["href"].match("venue")
          puts "No venue information for " + element.content.strip if !venue
        end
        @events[event_number] = Event.new(event_start, event_start + Rational(1,24), home_team, away_team, venue, event_id, event_number, true)
      end  
    end
  end

  def get_number_from_url(url)
    eventdoc = Nokogiri::HTML(open(url))
    record = eventdoc.css("html body div#container div#IbisInfo.ibisinfo div.clMatchView div.wide-load div#iList div#iSelection div table#iMatchInfo.clCommonGrid tbody tr") 
    record.each do |element|
      if element.content.match("Matchnummer") then
        return element.search("td").to_a[1].content.to_i
      end
    end
    return -1
  end
end

