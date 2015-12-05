#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './district.rb'

class Serie

  @@base_url = Event.stats_base_url + "ft.aspx?scr=table&ftid=" 
  
  attr_accessor :id, :name, :url, :district
  
  def initialize(id)
    @id = id.to_i
    @url = @@base_url + @id.to_s
    html = Nokogiri::HTML(open(@url))
    @name = html.at_xpath("/html/body/div[2]/div[1]/h1").content.gsub(/Tabell och resultat - /,"")
    district_id = html.at_xpath("/html/body/div[2]/div[1]/ul/li[4]/a")["href"].match(/[0-9]*$/).to_s.to_i
    @district = District.new(district_id)
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " " + @url
  end
end

#puts Serie.new(ARGV[0].to_i)
