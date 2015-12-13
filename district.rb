#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'
require "./cache.rb"
require 'json'

class District

  @@base_url = Event.stats_base_url + "ft.aspx?ffid=" 
  
  attr_accessor :id, :name, :url

  def to_json
    return [name, url].to_json
  end
  
  def initialize(id)
    @id = id.to_i
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @name = array[0]
      @utl = array[1]
    else
      @url = @@base_url + @id.to_s
      html = Nokogiri::HTML(open(@url))
      @name = html.at_xpath("/html/body/div[2]/div[1]/div/h1").content
      Cache.set(self)      
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " " + @url
  end

end

#puts District.new(ARGV[0].to_i)
