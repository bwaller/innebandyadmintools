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

venues = Venue.create("http://www.innebandy.se/Stockholm/Tavling/Hallforteckning/")

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

def get_event_htmlanchor(id, text)
  return "<a target=\"_blank\" href=\"http://statistik.innebandy.se/ft.aspx?scr=result&fmid=" + id.to_s + "\">" + text + "</a>" 
end

def get_event_matchtruppanchor(id, text)
  return "<a href=\"https://ibis.innebandy.se/Fogisforeningklient/Match/MatchTrupp.aspx?matchId=" + id.to_s + "\">" + text + "</a>"
end

(0...ARGV.length).step(2) do |i| 
  myserie = Serie.new(ARGV[i],ARGV[i+1])
  myserie.populate(venues)
  puts "Creating serie " + myserie.name 
  myserie.events.each do |key, event|

    row += 1

    answerdate = event.start_time - 3
    info = "<p>Matchstart " + event.start_time.strftime("%H:%M") + ". Osa senast " + veckodag[answerdate.cwday] + " 20.00.</p>"
    if event.venue.name != "Tappströms Bollhall" 
      info += "<p><a target=\"_blank\" href=\"http://maps.google.se/maps?saddr=Ekerö Centrum&daddr=" + event.venue.streetaddress + "+" + event.venue.postal_code + "+" + event.venue.locality + "\">" + event.venue.name + "</a> har adress: <br />" + event.venue.streetaddress + "<br /> " + event.venue.postal_code + " " + event.venue.locality + "</p>"
    end
     
    info += "<p style=\"font-size:12px\"><a " + myserie.href + "</a><br>"
    info += "Matchnumer: " + get_event_htmlanchor(event.id, event.number.to_s) + "<br>"
    info += get_event_matchtruppanchor(event.id, "Ibis matchtrupp") + "</p>"
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
end

workbook.close
puts "Open created document with", "soffice --calc " +  outfile
