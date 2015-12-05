#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'

class Person

  @@base_url = Event.stats_base_url + "ft.aspx?scr=person&fpid=" 
  
  attr_accessor :id, :name, :url, :email, :cell_phone, :address
  
  def initialize(id)
    @id = id.to_i
    @url = @@base_url + @id.to_s
    html = Nokogiri::HTML(open(@url))
    tmp = html.at_xpath("/html/body/div[2]/div[1]/div/h1")
    if tmp then
      @name = tmp.content
    else
      @name, @address, @email, @cell_phone = "UNDEFINED" 
    end
    tmp = html.at_xpath("/html/body/div[2]/div[1]/div/dl/dd[1]")
    if tmp then 
      @address = tmp.content 
    else
      @address = "UNDEFINED"
    end 
    tmp = html.at_xpath("/html/body/div[2]/div[1]/div/dl/dd[3]/a")
    if tmp then 
      @email = tmp.content
    else
      @email = "UNDEFINED"
    end
    tmp = html.at_xpath("/html/body/div[2]/div[1]/div/dl/dd[2]")
    if tmp then
      @cell_phone = tmp.content
    else
      @cell_phone = "UNDEFINED"
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
