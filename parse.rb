#encoding: utf-8

require 'date'
require 'spreadsheet'
require "./serie.rb"
require "./team.rb"
require "./ical.rb"

veckodag = Array.new(7)
veckodag[1] = "måndag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "onsdag" #Om matchen spelas en söndag är svarsdag ändå onsdag
veckodag[5] = "fredag"
veckodag[6] = "lördag"
veckodag[7] = "söndag"
contact_person = "void"

Spreadsheet.client_encoding = "UTF-8"
ARGV.each do |argv| 
  workbook = Spreadsheet::Workbook.new
  worksheet = workbook.create_worksheet 
  row = 0

  worksheet[row, 0] = "Kalendertyp"
  worksheet[row, 1] = "Titel"
  worksheet[row, 2] = "Plats"
  worksheet[row, 3] = "Innehåll"
  worksheet[row, 4] = "Starttid"
  worksheet[row, 5] = "Sluttid"
  worksheet[row, 6] = "Startdatum"
  worksheet[row, 7] = "Stopdatum"
  worksheet[row, 8] = "Kontakt"

  myteam = Team.new(argv.to_i)
  #Initialize google matrix origins address
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
        info += "<p><a target=\"_blank\" href=\"http://maps.google.se/maps?saddr=" + source_address + 
                "&daddr=" + event.venue.streetaddress + "+" + event.venue.postal_code + "+" + event.venue.locality + "\">" + event.venue.name + 
                "</a> har adress: <br>" + event.venue.streetaddress + "<br> " + event.venue.postal_code + " " + event.venue.locality + "</p>"
        if DateTime.now < event.start_time then
          route_url = URI.encode(
                      "https://maps.googleapis.com/maps/api/distancematrix/json" + 
                      "?key=AIzaSyC1AQr1tR2KtKLLtGebf6ULzDY4e4iZVVw" + 
                      "&traffic_model=pessimistic" + 
                      "&departure_time=" + (event.start_time - Rational(45,24*60) - Rational(1,48)).strftime('%s') +
                      "&origins=" + source_address +
                      "&destinations=" + event.venue.streetaddress + "+" + event.venue.postal_code + "+" + event.venue.locality
                      )
          matrix = JSON.parse(Nokogiri::HTML(open(route_url)))
          travel_time = 0
          if matrix["status"] == "OK" && matrix["rows"][0]["elements"][0]["status"] == "OK" then
            travel_time = matrix["rows"][0]["elements"][0]["duration_in_traffic"]["value"].to_i
          end
          if travel_time > 0 then
            hour = (event.start_time-Rational(travel_time,24*60*60)-Rational(45,24*60)).strftime("%H")
            minute = (((event.start_time-Rational(travel_time,24*60*60)-Rational(45,24*60)).strftime("%M").to_i/5)*5).to_s.rjust(2,'0')
            info += "Lämplig tid att åka från " + myteam.club.address.match(/[[:alpha:]]*$/).to_s + " är " + hour + ":" + minute + ". (Restid enligt Google Maps är " + (travel_time/60).to_i.to_s + " min .)<br>"
          end
        end
      end
     
      info += "<p>" + myteam.serie.anchor("target=\"_blank\"", myteam.serie.name) 
      info += "<br>Matchnummer: " + event.anchor("target=\"_blank\"", event.number.to_s) 
      info += "<br>"+event.anchor_matchtrupp("target=\"_blank\"", "Ibis matchtrupp") 
      if event.is_away? then
        info += "<br>" + event.home_team.name + " spelar i: " + event.home_team.dress_colors
      end
      info += "<br>Spelschema för <a target=\"_blank\" href=\"" + event.venue.url + "\">" + venue_name + "</a>"  
      info += "</p>"

      event_start_clock = (event.start_time-Rational(45,24*60)).strftime("%H:%M")
      event_end_clock = event.end_time.strftime("%H:%M")
      event_start_date = event.start_time.strftime("%Y-%m-%d")
      event_end_date = event.end_time.strftime("%Y-%m-%d")

      ical_event_description = "Matchstart: " + event.start_time.strftime("%H:%M")
      ical_event = Ical.new(event_start_date + " " + event_start_clock,
                              event_end_date + " " + event_end_clock,
                              heading,
                              ical_event_description,
                              venue_name)
      info += ical_event.event_html
      info += ical_event.include_js_html
  
    else
      puts "Event with id " + event.id.to_s + " is invalid"
    end

    worksheet[row, 0] = "Matcher"
    worksheet[row, 1] = heading
    worksheet[row, 2] = venue_name
    worksheet[row, 3] = info
    worksheet[row, 4] = event_start_clock
    worksheet[row, 5] = event_end_clock
    worksheet[row, 6] = event_start_date
    worksheet[row, 7] = event_end_date
    worksheet[row, 8] = contact_person

  end

  outfile = "sportnikimport_" + myteam.serie.name.gsub(/[a-zåäö ]/,"") + "_" + myteam.name.gsub(/ /,"") + ".xls"
  workbook.write outfile
  puts "Open created document with", "soffice --calc " +  outfile

end
