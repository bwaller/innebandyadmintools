#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './district.rb'
require './cache.rb'

class Serie

  @@base_url = Event.stats_base_url + "ft.aspx?scr=table&ftid=" 
  @@the_series = Hash.new
  
  attr_accessor :id, :name, :url, :district, :teams
  
  def to_json
    return [@name, @url, @district.id].to_json
  end

  def initialize(id)
    @id = id
    @teams = Hash.new
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @name = array[0]
      @url = array[1]
      @district = District.new(array[2])
    else
      @url = @@base_url + @id.to_s
      html = Nokogiri::HTML(open(@url))
      @name = html.at("//h1").content.gsub(/Tabell och resultat - /,"").gsub(/Spelprogram - /,"")
      district_id = html.css("html body div#container div#IbisInfo.ibisinfo ul.clFogisMenu.no-print li a")[2]["href"].match(/[0-9]*$/).to_s.to_i
      @district = District.new(district_id)
      Cache.set(self)
    end
    html = Nokogiri::HTML(open(@url))
    html.css('html body div#container div#IbisInfo.ibisinfo').css('a').each do |anchor|
      team_name = anchor.content.strip.gsub(" ","")
      @teams[team_name] = anchor["href"].match(/[0-9]*$/).to_s.to_i if anchor.to_s.match(/ft.aspx\?flid=/) && !@teams[team_name]
    end
  end

  def anchor(attributes, content)
    return "<a " + attributes + " href=" + @url + ">" + content + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " " + @url + " " + teams.to_s
  end

  def self.get_serie(id)
    @@the_series[id] = Serie.new(id) if !@@the_series[id]
    return @@the_series[id]
  end

end

#puts Serie.new(ARGV[0].to_i)
