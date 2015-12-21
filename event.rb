# encoding: utf-8

require 'date'

class Event

  @@stats_base_url = "http://statistik.innebandy.se/"
  @@event_base_url = @@stats_base_url + "ft.aspx?scr=result&fmid="

  attr_accessor :id, :url, :home_team, :away_team, :number, :start_time, :end_time, :venue

  def initialize(id, team_id, serie, length_m = 60)
    @id = id
    @url = @@event_base_url + id.to_s
    #puts "Event: " + @url  
    @is_valid = false
    event_html = Nokogiri::HTML(open(@url))
    event_html.css("html body div#container div#IbisInfo.ibisinfo div.clMatchView div.wide-load div#iList table.clTblMatchStanding").each do |table|
      @is_valid = true
      home_team_id = table.css("a")[0]["href"].match(/[0-9]*$/).to_s.to_i
      away_team_id = table.css("a")[1]["href"].match(/[0-9]*$/).to_s.to_i
      @home_team = Team.new (home_team_id)
      @away_team = Team.new (away_team_id)
      team_id == home_team_id ? @is_home = true : @is_home = false  
    end
    
    @number = 0
    start_time_str = "1970-01-01"
    venue_id = 0
    event_html.css("html body div#container div#IbisInfo.ibisinfo div.clMatchView div.wide-load div#iList div#iSelection div table#iMatchInfo.clCommonGrid tbody").each do |tbody|
      tbody.css("td").each do |td|
        @number = td.next_element.content if td.content.match(/Matchnummer/)
        start_time_str = td.next_element.content if td.content.match(/Tid/) && td.next_element.content.match(/./)
        venue_id = td.next_element.child["href"].match(/[0-9]*$/).to_s.to_i if td.content.match(/Spelplats/)
      end 
    end 
    @serie = serie
    @start_time = DateTime.parse (start_time_str)
    @end_time = @start_time + Rational(length_m,24*60)
    @is_valid = false if (@start_time.year == 1970)
    @venue = Venue.new(venue_id)
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

