#!/usr/bin/ruby

require 'open-uri'
require 'rubygems'
require 'nokogiri'

uri = "http://www.stockholminnebandy.nu/FA/Lagmatcher.asp?LAGID="+ARGV[0]+"&SFKOD=58&SDFKOD=15&SASONG=2013"
doc = Nokogiri::HTML(open(uri))
doc.css('tr').each do |element|
  row = element.text.split("\r\n")
  if row[1] != "Speldatum" 
    day = row[1].partition("/")[0].to_i
    month = row[1].partition("/")[2].to_i
    minute = row[2].partition(":")[2].to_i
    hour = row[2].partition(":")[0].to_i
    if month > 6
      year = Time.now.year
    else 
      year = Time.now.year + 1
    end
    matchtime = Time.local(year,month,day,hour,minute,0) 
    eventstart = (matchtime-(60*45)).strftime("%H:%M")
    eventslut = (matchtime+(60*60)).strftime("%H:%M")
    startdatum = matchtime.strftime("%Y-%m-%d")
    stopdatum = startdatum

    hemmalag = row[4].strip
    bortalag = row[5].strip

    arena = row[7].strip

    print "Matcher;"
    print hemmalag, " vs ", bortalag,";"
    print arena,";" 
    print "Matchstart ", matchtime.strftime("%H:%M"),". Osa senast onsdag 22.00.",";"
    print eventstart,";"
    print eventslut,";"
    print startdatum,";"
    print stopdatum,";"
    print "Bjorn Waller"
    print "\n"
  end
end
