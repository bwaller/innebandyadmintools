#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './cache.rb'

class PlayerCareer

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
      html = Nokogiri::HTML(open(@url)).css("html body div#container div#IbisInfo div table.clTblPlayerCareer tr")
     
      #puts html
      @name=html.shift.content.strip
      html = html.css("td")
      html.shift
      html.shift
      html.shift
      @birth_year=html.shift.content.to_i
      html.shift
      @club=html.shift.content.strip
    
      @career = Hash.new

      while html.first.content != "Summa:" do
        season = html.shift.content
        serie = html.shift.child.content
        club = html.shift.content
        nbmatches = html.shift.content.to_i
        html.shift
        html.shift
        html.shift
        html.shift
        #puts season.to_s + " " + serie.to_s + " " + club.to_s + " " + nbmatches.to_s
        @career[season + " " + serie] = nbmatches
      end

#      Cache.set(self)
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

end

total_career = Hash.new
ages = Hash.new
total_matches = 0
ARGV.each do |argv|
  player = PlayerCareer.new(argv)
  player.career.each do |serie, nbmatches|
#    puts serie + " " + nbmatches.to_s
    if !total_career[serie] then
      total_career[serie] = nbmatches
    else
      total_career[serie] += nbmatches 
    end 
    total_matches += nbmatches
  end
  if !ages[player.birth_year] then
    ages[player.birth_year] = 1
  else
    ages[player.birth_year] += 1
  end
end

total_career.each do |serie, nbmatches|
  puts serie + " " + nbmatches.to_s + " "+ (nbmatches.to_f/total_matches.to_f*100.0).round(1).to_s + "%"
end
ages.each do |birth_year, n|
  puts birth_year.to_s + " " + n.to_s
end
puts total_matches
