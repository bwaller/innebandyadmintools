#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './event.rb'
require './cache.rb'

class Person

  @@base_url = Event.stats_base_url + "ft.aspx?scr=person&fpid=" 
  
  attr_accessor :id, :name, :url, :email, :cell_phone, :address
  
  def to_json
    return [@name, @address, @email, @cell_phone, @url].to_json
  end

  def initialize(id)
    @id = id
    if json_str = Cache.get(Cache.key(self)) then
      array = JSON.parse(json_str)
      @name = array[0]
      @address = array[1]
      @email = array[2]
      @cell_phone = array[3]
      @url = array[4]
    else
      @url = @@base_url + @id.to_s
      html = Nokogiri::HTML(open(@url))

      elem = html.at("//h1")
      if elem then
        @name = elem.content
      else
        @name, @address, @email, @cell_phone = "UNDEFINED" 
      end

      elem = html.at('dt:contains("Adress")')
      if elem then 
        @address = elem.next_element.content 
      else
        @address = "UNDEFINED"
      end 

      elem = html.at('dt:contains("E-post")')
      if elem then 
        @email = elem.next_element.content
      else
        @email = "UNDEFINED"
      end

      elem = html.at('dt:contains("Telefon mobil")')
      if elem then
        @cell_phone = elem.next_element.content
      else
        @cell_phone = "UNDEFINED"
      end 

      Cache.set(self)
    end
  end

  def href
    return "<a href=" + @url + ">" + @name + "</a>"
  end

  def to_s
    return @id.to_s + " " + @name + " "+ @address + " "+ @email + " "+ @cell_phone + " "+ @url.to_s
  end

end

#puts Person.new(ARGV[0].to_i)
