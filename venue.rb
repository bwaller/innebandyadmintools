# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'json'
require './cache.rb'

class Venue

  attr_accessor :id, :name, :streetaddress, :postal_code, :locality

  def to_json
    return [@name, @streetaddress, @postal_code, @locality].to_json
  end

  def initialize (id)

    @id = id
    if json_str = Cache.get(Cache.key(self)) then
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
      Cache.set(self)
    end 
  end  

  def to_s
    return @name + " " + @streetaddress + " " + @postal_code + " " + @locality 
  end
 
  def faid
    return id
  end

end

#Venue.testdd

