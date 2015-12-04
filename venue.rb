# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require "redis"
require 'json'

@@redis = Redis.new

class Venue

  def initialize(id, name, streetaddress, postal_code, locality)
    @id = id.to_i
    @name = name
    @streetaddress = streetaddress
    @postal_code = postal_code
    @locality = locality
  end
  
  def initialize(id, json)
    @id = id
    array = JSON.parse(json)
    @name = array[0]
    @streetaddress = array[1]
    @postal_code = array[2]
    @locality = array[3]
  end

  attr_accessor :id, :name, :streetaddress, :postal_code, :locality

  def to_s
    return @name + " " + @streetaddress + " " + @postal_code + " " + @locality 
  end
 
  def to_ruby
    puts '"' + @name + '" => Venue.new("' + @name + '", "' + @streetaddress + '", "' + @postal_code + '", "' + @locality + '"),'
  end

  def faid
    return id
  end

  def self.getvenue(id)

    if venue_as_json = @@redis.get(id) then
      return Venue.new(id, venue_as_json)
    else
      name, streetaddress, postal_code, locality = ""
      venue_url = "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=" + id.to_s
      venue_doc = Nokogiri::HTML(open(venue_url))
      if !element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis h1") then
        puts "Url " + venue_url + " returned empty document"
        return nil
      end
      name = element.content
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.street-address") then 
        streetaddress = element.content
      else 
        streetaddress = "STREET_UNDEFINED"
      end
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.postal-code") then
        postal_code = element.content
      else 
        postal_code = "POSTAL_CODE_UNDEFINED"
      end
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.locality") then
        locality = element.content 
      else 
        locality = "LOCALITY_UNDEFINED"
      end
      json_str = [name, streetaddress, postal_code, locality].to_json
      @@redis.set id, json_str
      return Venue.new(id, json_str)
    end 

  end

end

#Venue.testdd

