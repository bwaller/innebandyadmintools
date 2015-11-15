#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'nokogiri'
require 'open-uri'
require './event.rb'

page = Nokogiri::HTML(open("http://statistik.innebandy.se/ft.aspx?scr=teamresult&flid=494"))   
#games = page.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid").text 
games = page.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr")
games.each do |game|
  puts game
end


