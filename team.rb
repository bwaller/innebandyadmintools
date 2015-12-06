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
  @@team_events_base_url = Event.stats_base_url  + "ft.aspx?scr=teamresult&flid="
  
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
    @events = Array.new
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def populate_events
    events_url = @@team_events_base_url + @id.to_s
    puts "Populate: " + events_url
    events_html = Nokogiri::HTML(open(events_url))
    events_html.css("a").each do |anchor|
      event_id = anchor["href"].match(/[0-9]*$/).to_s.to_i if anchor["href"].match(/fmid/) && !anchor["class"]
      if event_id then 
        puts "New event: " + event_id.to_s
        event = Event.new(event_id, @id, @serie)
        @events.push(event) 
      end
    end
  end
 
  def to_s
    return @id.to_s + " " + @name + " " + @dress_colors 
  end

end

