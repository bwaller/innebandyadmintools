#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './district.rb'
require './cache.rb'

class Club

  @@base_url = Event.stats_base_url + "ft.aspx?feid=" 
  
  attr_accessor :id, :name, :url, :number, :district, :address

  def to_json
    return [@number, @name, @url, @address, @district.id].to_json
  end
  
  def initialize(id)
    @id = id
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @number = array[0]
      @name = array[1]
      @url = array[2]
      @address = array[3]
      district_id = array[4]
      @district = District.new(district_id)
    else 
      @url = @@base_url + @id.to_s
      html = Nokogiri::HTML(open(@url))
      @name = html.at('//h1').content.to_s

      elem = html.at('dt:contains("Föreningsnummer")')
      if elem
        @number = elem.next_element.content.to_s.to_i 
      end

      elem = html.at('dt:contains("Adress")')
      if elem
        @address = elem.next_element.content.to_s.strip 
      end

      district_id = 0
      elem = html.at('dt:contains("Förbund")')
      if elem
        district_id = elem.next_element.child["href"].match(/[0-9]*$/).to_s.to_i
      end
      @district = District.new(district_id)

      Cache.set(self)
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @number.to_s + " " + @name + " " + @url + " " + @address + " " + @district.name
  end

end

#puts Club.new(ARGV[0].to_i)
