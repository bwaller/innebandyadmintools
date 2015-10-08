#!/usr/bin/ruby
# encoding: utf-8

require 'date'

veckodag = Array.new(7)
veckodag[1] = "mandag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "onsdag" #Om matchen spelas en söndag är svarsdag ändå onsdag
veckodag[5] = "fredag"
veckodag[6] = "lordag"
veckodag[7] = "sondag"

def arena_address(name)

  case name
  when "Åkersberga Sporthall A"
      return "Hackstavägen 43", "184 35 Åkersberga"
  when "Ärvingehallen"
      return "Köpenhamnsgatan 15", "164 42 Kista"
  when "Björkebyhallen"
      return "Brasvägen 2", "175 61 Järfälla"
  when "Djurö Sporthall"
      return "Högmalmsvägen 10", "130 40 Djurhamn"
  when "Ekhammarshallen"
      return "Skolvägen 20", "196 30 Kungsängen"
  when "Farstahallen 3"
      return "Farstaängsvägen 3", "123 46 Farsta"
  when "Grindtorpshallen"
      return "Grindtoprsvägen 1a", "183 32 Täby"
  when "Hammarbackens Sporthall"
      return "Ekebyvägen 2", "183 34 Vallentuna"
  when "Ingarö Sporthall"
      return "Brunns Skola", "134 60 Ingarö"
  when "Nya Rotebrohallen"
      return "Ebba Brahes Väg 3", "192 69 Sollentuna"
  when "Strandhallen - Tyresö"
      return "Lagergrens väg 10", "135 63 Tyresö"
  when "Sätrahallen"
      return "Björksätravägen 2", "127 37 Skärholmen"
  when "Söderbymalmskolan"
      return "Eskilsvägen 8", "136 81 Handen"
  when "Tappströms Bollhall"
      return "Tappströmsvägen 1", "178 23 Ekerö"
  when "Tomtbergahallen"
      return "Rådsvägen 1", "141 48 Huddinge"
  when "Vikingavallen - Bollhallen Täby IP"
      return "Hövdingavägen 1-3","187 77 Täby"
  else return "NOT DEFINED","NOT DEFINED"
  end
end

file = ARGV[0]

event_starts_minutes_before_match = 45
event_ends_minutes_after_match = 60
contact_person = "B Waller"

puts "Kalendertyp,Title,Arena,Info,Eventstart,Eventslut,Startdatum,Slutdatum,Contact"
File.open(file,"r").each_line do |line|
  data = line.split(/\t/)
  hemmalag = data[4].strip
  bortalag = data[5].strip
  datum = data[6]
  arena = data[8].strip

  if ( datum.size > 0 ) then 
    year = datum.split("-")[0].to_i
    month = datum.split("-")[1].to_i
    day = datum.split("-")[2].split[0].to_i
    hour = datum.split("-")[2].split[1].split(":")[0].to_i
    minute = datum.split("-")[2].split[1].split(":")[1].to_i
  else 
    year = 1970
    month = 1
    day = 1
    hour = 0
    minute = 0
  end

#  puts year,month,day,hour,minute

  matchstart = DateTime.new(year,month,day,hour,minute)
  eventstart = matchstart + Rational(-event_starts_minutes_before_match,60*24)
  eventend = matchstart + Rational(event_ends_minutes_after_match,60*24)
  answerdate = matchstart - 3

#  puts "hl: "+hemmalag+" bl: "+bortalag+" start: "+startdatum+" hall: "+hall
  
  print "Matcher,"
  print hemmalag, " vs ", bortalag,","
  print arena,"," 
  road, postalcode = arena_address(arena)
  print "<p>Matchstart ", matchstart.strftime("%H:%M"),". Osa senast ", veckodag[answerdate.cwday], " 20.00.</p>"
  if arena != "Tappströms Bollhall" 
    print "<p><a href=\"http://maps.google.se/maps?q=", road,"+", postalcode,"\">",arena, "</a> har adress: <br />",road, "<br /> ", postalcode,"</p>,"
  else 
    print ","
  end
  print eventstart.strftime("%H:%M"),","
  print eventend.strftime("%H:%M"),","
  print matchstart.strftime("%Y-%m-%d"),","
  print matchstart.strftime("%Y-%m-%d"),","
  print contact_person
  print "\n"

end
