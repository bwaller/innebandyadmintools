#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'

class District

  @@base_url = Event.stats_base_url + "ft.aspx?ffid=" 
  
  attr_accessor :id, :name, :url
  
  def initialize(id)
    @id = id.to_i
    @url = @@base_url + @id.to_s
    html = Nokogiri::HTML(open(@url))
    @name = html.at_xpath("/html/body/div[2]/div[1]/div/h1").content
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " " + @url
  end
end

#puts District.new(ARGV[0].to_i)
