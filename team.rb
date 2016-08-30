#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './venue.rb'
require './club.rb'
require './serie.rb'
require './person.rb'
require './cache.rb'

class Team

  @@team_base_url = Event.stats_base_url  + "ft.aspx?flid="
  @@team_events_base_url = Event.stats_base_url  + "ft.aspx?scr=teamresult&flid="
  @@team_fixturelist_base_url = Event.stats_base_url  + "ft.aspx?scr=fixturelist&ftid="
  
  attr_accessor :id, :url, :name, :club, :dress_colors, :serie, :contact_person, :events

  def to_json
    return [@name, @url, @dress_colors, @club.id, @serie.id, @contact_person.id].to_json
  end
  
  def initialize(id)
    @id = id
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @name = array[0]
      @url = array[1]
      @dress_colors = array[2]
      @club = Club.new(array[3])
      @serie = Serie.get_serie(array[4])
      @contact_person = Person.new(array[5])
      @events = Array.new
    else
      @url = @@team_base_url + @id.to_s
      html = Nokogiri::HTML(open(url))
      club_id, contact_person_id, serie_id = 0
      html.css('a').each do |anchor|
        club_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/feid/) 
        contact_person_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/fpid/)
        serie_id = anchor.attribute('href').value.match(/[0-9]*$/).to_s.to_i if anchor.attribute('href').value.match(/ftid/)
      end 
      @club = Club.new(club_id)
      @dress_colors = "Dress colors not found"
      html.css('dt').each do |dt|
        @dress_colors = dt.next_element.content.to_s if dt.content.match(/Färger/)
      end  
      fixturelist_url = @@team_fixturelist_base_url + serie_id.to_s
      fixturelist_html = Nokogiri::HTML(open(fixturelist_url))
      search_path = '//*[@href="ft.aspx?flid='+ @id.to_s + '"]'
      fixturelist_html.xpath(search_path).each do |elem|
        @name = elem.content
      end
      @serie = Serie.get_serie(serie_id)
      @contact_person = Person.new(contact_person_id)
      @events = Array.new
      Cache.set(self)
    end
    @length_m = 60
    @length_m = 45 if @serie.name.match(/Blå/)
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def populate_events
    events_url = @@team_events_base_url + @id.to_s
    events_html = Nokogiri::HTML(open(events_url))
    events_html.css("a").each do |anchor|
      event_id = anchor["href"].match(/[0-9]*$/).to_s.to_i if anchor["href"].match(/fmid/) && !anchor["class"]
      if event_id then 
        event = Event.new(event_id, @id, @serie, @length_m)
        @events.push(event) 
      end
    end
  end
 
  def to_s
    return @id.to_s + " " + @name + " " + @dress_colors 
  end

end

