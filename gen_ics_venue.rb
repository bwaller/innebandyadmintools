# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'icalendar'

minutes_per_day = 60*24
venue_game_length = { 
  "Damer division 2" => Rational(90,minutes_per_day),
  "Damer division 3 mellersta" => Rational(90,minutes_per_day),
  "Herrar division 4 västra" => Rational(90,minutes_per_day),
  "Herrar division 5 mellersta" => Rational(90,minutes_per_day),
  "Pantamera Flickor Blå Lätt Lätt C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Lätt Svår C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Medel B" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Medel C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Svår Mellersta" => Rational(60,minutes_per_day),
  "Pantamera Flickor Röd Lätt Norra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medellätt Norra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medel Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medel Södra" => Rational(75,minutes_per_day),
  "Pantamera Herrjuniorer division 2 södra" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 3 B" => Rational(90,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Lätt B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Lätt D" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Svår B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Svår B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Mellersta" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Norra" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Södra" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel B" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel C" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medellätt Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Svår" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Mörkröd Medel Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Mörkröd Svår" => Rational(75,minutes_per_day)
}

cal = Icalendar::Calendar.new

@url = "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=" + ARGV[0].to_s
venue_doc = Nokogiri::HTML(open(@url))

venue_doc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr td").each do |td|
  if td["nowrap"] && td.content.length > 0 then
    dtstart = DateTime.parse(td.content)
    dtend = dtstart + venue_game_length[td.next_element.content] 
    ical_event = Icalendar::Event.new        
    ical_event.dtstart = dtstart
    ical_event.dtend = dtend
    cal.add_event(ical_event)
  end

end

puts cal.to_ical

