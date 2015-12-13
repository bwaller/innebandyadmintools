# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require "redis"
require 'json'

@@redis = Redis.new

class Venue

  attr_accessor :id, :name, :streetaddress, :postal_code, :locality

  def initialize (id)

    @id = id
    key = Venue.key(@id)
    if json_str = @@redis.get(key) then
      array = JSON.parse(json_str)
      @name = array[0]
      @streetaddress = array[1]
      @postal_code = array[2]
      @locality = array[3]
    else
      venue_url = "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=" + id.to_s
      venue_doc = Nokogiri::HTML(open(venue_url))
      if !element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis h1") then
        puts "Url " + venue_url + " returned empty document"
        return nil
      end
      @name = element.content
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.street-address") then 
        @streetaddress = element.content
      else 
        @streetaddress = "STREET_UNDEFINED"
      end
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.postal-code") then
        @postal_code = element.content
      else 
        @postal_code = "POSTAL_CODE_UNDEFINED"
      end
      if element = venue_doc.at_css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span.locality") then
        @locality = element.content 
      else 
        @locality = "LOCALITY_UNDEFINED"
      end
      Venue.set(@id, @name, @streetaddress, @postal_code, @locality)
    end 
  end
  
  def self.set(id, name, streetaddress, postal_code, locality)
    json_str = [name, streetaddress, postal_code, locality].to_json
    @@redis.set self.key(id), json_str
  end

  def self.key(id)
    return key = self.class.to_s+id.to_s
  end

  def to_s
    return @name + " " + @streetaddress + " " + @postal_code + " " + @locality 
  end
 
  def faid
    return id
  end

end

#Venue.testdd

