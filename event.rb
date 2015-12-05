# encoding: utf-8

require 'date'

class Event

  @@stats_base_url = "http://statistik.innebandy.se/"

  attr_accessor :start_time, :end_time, :home_team, :away_team, :venue, :id, :number

  def initialize(start_time, end_time, home_team, away_team, venue, id, number, is_home)
    @start_time = start_time
    @end_time = end_time
    @home_team = home_team
    @away_team = away_team
    @venue = venue
    @id = id
    @number = number
    @is_home = is_home
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

end # Event

