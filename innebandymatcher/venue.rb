# encoding: utf-8

require 'nokogiri'
require 'open-uri'

class Venue

  def initialize(name, streetaddress, postal_code, locality, url ="")
    @name = name
    @streetaddress = streetaddress
    @postal_code = postal_code
    @locality = locality
    @url = url 
  end

  @@predefined_venues = {
    
    "Björkeby Sporthall" => Venue.new("Björkeby Sporthall", "Brasvägen 2", "175 61", "Järfälla", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1240"),
    "Bodals Bollhall" => Venue.new("Bodals Bollhall", "Bodalsvägen 47", "181 36", "Lidingö", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1247"),
    "Ekhammarshallen" => Venue.new("Ekhammarhallen", "Skolvägen 20", "19630", "Kungsängen", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1263"),
    "Hammarbackens Sporthall" => Venue.new("Hammarbackshallen", "Ekebyvägen 2", "18334", "Vallentuna", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1321"),    
    "Jakobsbergs Sporthall" => Venue.new("Jakobsbergs Sporthall", "Mjölnarvägen 3", "177 41", "Järfälla", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1248"),
    "Kolstahallen" => Venue.new("Kolstahallen", "Vikingavägen 4", "195 51", "Märsta", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=2507"),
    "Sätrahallen" => Venue.new("Sätrahallen", "Björksätravägen 2", "127 36", "Skärholmen", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=2927"),
    "Söderbymalmskolan" => Venue.new("Söderbymalmsskolan", "Eskilsvägen 8", "136 43", "Haningen", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1305"),
    "Strandhallen - Tyresö" => Venue.new("Strandhallen", "Lagergrens väg 10, Tyresö Strand", "13563", "Tyresö", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1281"),
    "Vikingavallen - Bollhallen Täby IP" => Venue.new("Vikingavallen Täby IP", "Hövdingavägen 1-3", "187 77", "Täby", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1331"),
    "Viksjö Sporthall" => Venue.new("Viksjö Sporthall", "Plogvägen 4", "175 44", "Järfälla", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1246"),
    "Åkersberga Sporthall A" => Venue.new("Åkersberga Sporthall", "Hackstav. 43", "18435", "Åkersberga", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1241"),
    "Ärvingehallen" => Venue.new("Ärvingehallen", "Köpenhamnsgatan 15", "164 42", "Kista", "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=1238"),

  }

  attr_accessor :name, :streetaddress, :postal_code, :locality, :url

  def self.create(url)
    venueshash = Hash.new

    venuesdoc = Nokogiri::HTML(open(url))
    venues = venuesdoc.css("html body#ctl00_htmlElmBody form#aspnetForm div#MainWrapper div#SiteWrapper div#ctl00_Content div#Center div#MainBody.articlePageBody div p a")
    venues.each do |venue|
      name = venue.content.strip
      venue_url = venue["href"]
      puts name + " " + venue_url

      if @@predefined_venues.has_key?(name) then
        venueshash[name] = @@predefined_venues[name]
      else
        venuedoc = Nokogiri::HTML(open(venue_url))
        venueaddress = venuedoc.css("html body div#container div#IbisInfo.ibisinfo div.clFogis dl dd span")
        streetaddress, postal_code, locality = "UNDEFINED"
        venueaddress.each do |element|
          streetaddress = element.content.strip if element["class"].match("street-address")
          postal_code = element.content.strip if element["class"].match("postal-code")
          locality = element.content.strip if element["class"].match("locality")
        end
        venueshash[name] = Venue.new(name, streetaddress, postal_code, locality, venue_url)
      end

    end

    return venueshash
  end

  def to_s
    return @name + " " + @streetaddress + " " + @postal_code + " " + @location + " " + @url
  end
 
  def to_ruby
    puts '"' + @name + '" => Venue.new("' + @name + '", "' + @streetaddress + '", "' + @postal_code + '", "' + @locality + '", "' + @url + '"),'
  end

  def self.test
    Venue.create("http://www.innebandy.se/Stockholm/Tavling/Hallforteckning/").each do |key, venue|
      puts "Venue: " + key, "Gata: " + venue.streetaddress, "Postadress: " + venue.postal_code + " " + venue.locality, "Url: " + venue.url
      puts
      #venue.to_ruby
    end
  end
  
end

Venue.test

