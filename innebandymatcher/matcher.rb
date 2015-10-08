#!/usr/bin/ruby

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'date'

veckodag = Array.new(7)
veckodag[1] = "mandag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "torsdag"
veckodag[5] = "fredag"
veckodag[6] = "lordag"
veckodag[7] = "sondag"

lagid = ARGV[0]
sfkod = 58.to_s
sdfkod = 15.to_s
season = ARGV[1]

event_starts_minutes_before_match = 45
event_ends_minutes_after_match = 60
contact_person = "B Waller"

uri = "http://www.stockholminnebandy.nu/FA/Lagmatcher.asp?LAGID="+lagid+"&SFKOD="+sfkod+"&SDFKOD="+sfkod+"&SASONG="+season
doc = Nokogiri::HTML(open(uri))
doc.css('tr').each do |element|
  row = element.text.split("\r\n")
  if row[1] != "Speldatum" 
    day = row[1].partition("/")[0].to_i
    month = row[1].partition("/")[2].to_i
    minute = row[2].partition(":")[2].to_i
    hour = row[2].partition(":")[0].to_i
    year = season.to_i
    if month < 6
      year = season.to_i + 1
    end
    matchstart = DateTime.new(year,month,day,hour,minute)
    eventstart = matchstart + Rational(-event_starts_minutes_before_match,60*24)
    eventend = matchstart + Rational(event_ends_minutes_after_match,60*24)
    answerdate = matchstart - 3

    hemmalag = row[4].strip
    bortalag = row[5].strip

    arena = row[7].strip
    if arena.match("^Tappstr.msskolan")
      arena = "Bollhallen"
    end

    print "Matcher;"
    print hemmalag, " vs ", bortalag,";"
    print arena,";" 
    print "Matchstart ", matchstart.strftime("%H:%M"),". Osa senast ", veckodag[answerdate.cwday], " 22.00.",";"
    print eventstart.strftime("%H:%M"),";"
    print eventend.strftime("%H:%M"),";"
    print matchstart.strftime("%Y-%m-%d"),";"
    print matchstart.strftime("%Y-%m-%d"),";"
    print contact_person
    print "\n"
  end
end
