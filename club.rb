#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require './district.rb'

class Club

  @@base_url = Event.stats_base_url + "ft.aspx?feid=" 
  
  attr_accessor :id, :name, :url, :number, :district
  
  def initialize(id)
    @id = id.to_i
    @url = @@base_url + @id.to_s
    html = Nokogiri::HTML(open(@url))
    @name = html.at_xpath("/html/body/div[2]/div[1]/div/h1").content
    district_id = html.at_xpath("/html/body/div[2]/div[1]/div/div[1]/dl/dd[6]/a")["href"].match(/[0-9]*$/).to_s.to_i
    @number = html.at_xpath("/html/body/div[2]/div[1]/div/div[1]/dl/dd[1]").content
    @district = District.new(district_id)
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " " + @number + " " + @url
  end
end

#puts Club.new(ARGV[0].to_i)
