#!/usr/bin/ruby

require 'date'

veckodag = Array.new(7)
veckodag[1] = "mandag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "onsdag" #Om matchen spelas en söndag är svarsdag ändå onsdag
veckodag[5] = "fredag"
veckodag[6] = "lordag"
veckodag[7] = "sondag"

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
  arena = data [7].strip

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
  print "Matchstart ", matchstart.strftime("%H:%M"),". Osa senast ", veckodag[answerdate.cwday], " 20.00.",","
  print eventstart.strftime("%H:%M"),","
  print eventend.strftime("%H:%M"),","
  print matchstart.strftime("%Y-%m-%d"),","
  print matchstart.strftime("%Y-%m-%d"),","
  print contact_person
  print "\n"

end
