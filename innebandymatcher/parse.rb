# encoding: utf-8

require 'date'
require 'writeexcel'
require "./serie.rb"

veckodag = Array.new(7)
veckodag[1] = "måndag"
veckodag[2] = "tisdag"
veckodag[3] = "onsdag"
veckodag[4] = "onsdag" #Om matchen spelas en söndag är svarsdag ändå onsdag
veckodag[5] = "fredag"
veckodag[6] = "lördag"
veckodag[7] = "söndag"
contact_person = "B Waller"

serie_url = ARGV[0]
serie_url = "http://statistik.innebandy.se/ft.aspx?scr=teamresult&flid=484"

venues = Venue.create("http://www.innebandy.se/Stockholm/Tavling/Hallforteckning/")

workbook = WriteExcel.new("test.xls")
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

myserie = Serie.new("myserie", serie_url)
myserie.populate(venues)
myserie.events.each do |key, event|

  row += 1

  answerdate = event.start_time - 3
  info = "<p>Matchstart " + event.start_time.strftime("%H:%M") + ". Osa senast " + veckodag[answerdate.cwday] + " 20.00.</p>"
  if event.venue.name != "Tappströms Bollhall" 
    info += "<p><a target=\"_blank\" href=\"http://maps.google.se/maps?saddr=Ekerö Centrum&daddr=" + event.venue.streetaddress + "+" + event.venue.postal_code + "+" + event.venue.locality + "\">" + event.venue.name + "</a> har adress: <br />" + event.venue.streetaddress + "<br /> " + event.venue.postal_code + " " + event.venue.locality + "</p>"
  end
  
  info += "Matchnummer: <a target=\"_blank\" href=\"http://statistik.innebandy.se/" + event.url + "\">" + key + "</a>"
  worksheet.write(row, 0, "Matcher")
  worksheet.write(row, 1, event.home_team + " vs " + event.away_team)
  worksheet.write(row, 2, event.venue.name)
  worksheet.write(row, 3, info)
  worksheet.write(row, 4, event.start_time.strftime("%H:%M"))
  worksheet.write(row, 5, event.end_time.strftime("%H:%M"))
  worksheet.write(row, 6, event.start_time.strftime("%Y-%m-%d"))
  worksheet.write(row, 7, event.end_time.strftime("%Y-%m-%d"))
  worksheet.write(row, 8, contact_person)

end

workbook.close
