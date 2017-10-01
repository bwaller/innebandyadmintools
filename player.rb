#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './cache.rb'

class Player

  @@base_url = Event.stats_base_url + "ft.aspx?scr=playercareer&fplid=" 
  
  attr_accessor :id, :name, :url, :birth_year, :club, :career
  
  def to_json
    return [@name, @url, @birth_year, @club].to_json
  end

  def to_s
    return @id.to_s + " " + @name + " "+ @url + " "+ @birth_year.to_s + " "+ @club 
  end

  def initialize(id)
    @id = id
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @name = array[0]
      @url = array[1]
      @birth_year = array[2]
      @club = array[3]
    else
      @url = @@base_url + @id.to_s
      html = Nokogiri::HTML(open(@url))
     
      @name = html.css("span#ctl00_SpelareNamn").text
      @birth_year = html.css("span#ctl00_SpelareFodelsear").text
      @club = html.css("span#ctl00_NuvarandeKlubb").text

      Cache.set(self)
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

end
