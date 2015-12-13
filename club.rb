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
      @name = html.at_xpath("/html/body/div[2]/div[1]/div/h1").content.to_s
      district_id = 0
      html.css("html body div#container div#IbisInfo.ibisinfo div.clFogis div#iList dl").each do |dl|
        dl.css("dt").each do |dt|
          @number = dt.next_element.content.to_s.to_i if dt.content.match(/Föreningsnummer/)  
          @address = dt.next_element.content.to_s.strip if dt.content.match(/Adress/)  
          district_id = dt.next_element.child["href"].match(/[0-9]*$/).to_s.to_i if dt.content.match(/Förbund/)
        end
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
