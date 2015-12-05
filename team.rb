#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './venue.rb'
require './club.rb'
require './serie.rb'
require './person.rb'

class Team

  @@team_base_url = Event.stats_base_url  + "ft.aspx?flid="
  
  attr_accessor :id, :url, :name, :club, :dress_colors, :serie, :contact_person, :events
  
  def initialize(id)
    @id = id.to_i
    @url = @@team_base_url + @id.to_s
    html = Nokogiri::HTML(open(url))
    @name = html.at_xpath("/html/body/div[2]/div[1]/div/h1").content
    club_id, contact_person_id, serie_id = 0
    html.css('a').each do |anchor|
      club_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/feid/) 
      contact_person_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/fpid/)
      serie_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/ftid/)
    end 
    @club = Club.new(club_id)
    html.css('dt').each do |dt|
      @dress_colors = dt.next_element.content.to_s if dt.content.match(/Färger/)
    end  
    @serie = Serie.new(serie_id)
    @contact_person = Person.new(contact_person_id)
    #@events = populate_events
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def populate_events
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
          venue = Venue.getvenue(element["href"].slice(/[0-9]*$/).to_i) if element["href"].match("venue")
          puts "No venue information for " + venue_id.to_s if !venue
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
  
  def to_s
    return @id.to_s + " " + @name + " " + @dress_colors 
  end

end

puts Team.new(ARGV[0].to_i)
