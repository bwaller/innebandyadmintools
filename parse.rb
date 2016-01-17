# encoding: utf-8

require 'date'
require 'writeexcel'
require "./serie.rb"
require "./team.rb"

veckodag = Array.new(7)
veckodag[1] = "måndag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "onsdag" #Om matchen spelas en söndag är svarsdag ändå onsdag
veckodag[5] = "fredag"
veckodag[6] = "lördag"
veckodag[7] = "söndag"
contact_person = "void"

outfile = "sportnik." + DateTime.now.strftime("%Y%m%d_%H%M") + ".xls"
workbook = WriteExcel.new(outfile)
worksheet = workbook.add_worksheet
row = 0

worksheet.write(row, 0, "Kalendertyp")
worksheet.write(row, 1, "Titel")
worksheet.write(row, 2, "Plats")
worksheet.write(row, 3, "Innehåll")
worksheet.write(row, 4, "Starttid")
worksheet.write(row, 5, "Sluttid")
worksheet.write(row, 6, "Startdatum")
worksheet.write(row, 7, "Stopdatum")
worksheet.write(row, 8, "Kontakt")

ARGV.each do |argv| 
  myteam = Team.new(argv.to_i)
  puts "Creating serie " + myteam.serie.name
  myteam.populate_events
  myteam.events.each do |event|

    row += 1

    heading = "Event with id " + event.id.to_s + " is not defined"
    info = "Something went wrong creating this event. You might try to regenerate this team, otherwise delete this event before importing. Url is " + event.url
    venue_name, event_start_clock, event_end_clock, event_start_date, event_end_date = ""

    if event.is_valid? then
      heading = event.home_team.name + " vs " + event.away_team.name
      venue_name = event.venue.name
      answerdate = event.start_time - 3
      info = "<p>Matchstart " + event.start_time.strftime("%H:%M") + ". Osa senast " + veckodag[answerdate.cwday] + " 20.00.</p>"
      if event.is_away? && event.away_team
        source_address = event.away_team.club.address.match(/[[:alpha:]]*$/).to_s
        info += "<p><a target=\"_blank\" href=\"http://maps.google.se/maps?saddr=" + source_address + "&daddr=" + event.venue.streetaddress + "+" + event.venue.postal_code + "+" + event.venue.locality + "\">" + event.venue.name + "</a> har adress: <br />" + event.venue.streetaddress + "<br /> " + event.venue.postal_code + " " + event.venue.locality + "</p>"
      end
     
      info += "<p>" + myteam.serie.anchor("target=\"_blank\"", myteam.serie.name) 
      info += "<br>Matchnummer: " + event.anchor("target=\"_blank\"", event.number.to_s) 
      info += "<br>"+event.anchor_matchtrupp("target=\"_blank\"", "Ibis matchtrupp") 
      if event.is_away? then
        info += "<br>Hemmalagets färger: " + event.home_team.dress_colors
      end
      info += "<br>Spelschema för <a target=\"_blank\" href=\"" + event.venue.url + "\">" + venue_name + "</a>"  
      info += "</p>"
  
      event_start_clock = (event.start_time-Rational(45,24*60)).strftime("%H:%M")
      event_end_clock = event.end_time.strftime("%H:%M")
      event_start_date = event.start_time.strftime("%Y-%m-%d")
      event_end_date = event.end_time.strftime("%Y-%m-%d")
    else
      puts "Event with id " + event.id.to_s + " is invalid"
    end

    worksheet.write(row, 0, "Matcher")
    worksheet.write(row, 1, heading)
    worksheet.write(row, 2, venue_name)
    worksheet.write(row, 3, info)
    worksheet.write(row, 4, event_start_clock)
    worksheet.write(row, 5, event_end_clock)
    worksheet.write(row, 6, event_start_date)
    worksheet.write(row, 7, event_end_date)
    worksheet.write(row, 8, contact_person)

  end
end

workbook.close
puts "Open created document with", "soffice --calc " +  outfile
