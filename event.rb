# encoding: utf-8

require 'date'

class Event

  @@stats_base_url = "http://statistik.innebandy.se/"
  @@event_base_url = @@stats_base_url + "ft.aspx?scr=result&fmid="

  attr_accessor :id, :url, :home_team, :away_team, :number, :start_time, :end_time, :venue

  def initialize(id, team_id, serie, length_m = 60)
    @id = id
    @url = @@event_base_url + id.to_s
    @serie = serie
    #puts "Event: " + @url  
    @is_valid = false
    event_html = Nokogiri::HTML(open(@url))
    node_set = event_html.css('td:contains("Laguppställning")') 
    if node_set.to_a.length > 0
      @is_valid = true
      home_team_id = @serie.teams[node_set.to_a[0].content.gsub("Laguppställning","").strip]
      away_team_id = @serie.teams[node_set.to_a[1].content.gsub("Laguppställning","").strip]
      @home_team = Team.new (home_team_id)
      @away_team = Team.new (away_team_id)
      team_id == home_team_id ? @is_home = true : @is_home = false  
    end

    venue_id = 0
    elem = event_html.at('td:contains("Spelplats")')
    if elem
      venue_id = elem.next_element.child["href"].match(/[0-9]*$/).to_s.to_i 
      @venue = Venue.new(venue_id)
    else
      @venue = nil  
    end

    @number = 0
    elem = event_html.at('td:contains("Matchnummer")')
    if elem 
      @number = elem.next_element.content
    end

    start_time_str = "1970-01-01"
    elem = event_html.at('td:contains("Tid")')
    if elem && elem.next_element && elem.next_element.content.match(/./)
      start_time_str = elem.next_element.content
    end                  
    @start_time = DateTime.parse (start_time_str)
    @end_time = @start_time + Rational(length_m,24*60)
    @is_valid = false if (@start_time.year == 1970)
  end

  def is_valid?
    return @is_valid
  end

  def is_home?
    return @is_home
  end

  def is_away?
    return !@is_home
  end

  def length
    minutes = (@end_time - @start_time).to_f*24*60
    return minutes
  end

  def self.stats_base_url
    return @@stats_base_url
  end

  def to_s
    return @id.to_s + " " + @url + " " + @number.to_s + " " + @home_team.name + " " + @away_team.name + " " + @serie.name + " " + @start_time.to_s + " " + @end_time.to_s + " " + @venue.id.to_s + " " + is_home?.to_s 
  end
end # Event

