# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'icalendar'
require 'optparse'
require 'ostruct'

minutes_per_day = 60*24
venue_game_length = { 
  "Herrar Div 1 Mellersta Svealand" => Rational(125,minutes_per_day),
  "Herrar veteraner division 1" => Rational(90,minutes_per_day),
  "Herrar utveckling Elit"  => Rational(90,minutes_per_day),
  "Damer division 2" => Rational(90,minutes_per_day),
  "Damer division 3 mellersta" => Rational(90,minutes_per_day),
  "Damer division 3 södra" => Rational(90,minutes_per_day),
  "Herrar division 3 norra" => Rational(90,minutes_per_day),
  "Herrar division 4 västra" => Rational(90,minutes_per_day),
  "Herrar division 4 östra" => Rational(90,minutes_per_day),
  "Herrar division 5 mellersta" => Rational(90,minutes_per_day),
  "Juniorallsvenskan D Herr"  => Rational(90,minutes_per_day),
  "Juniorallsvenskan E Herr"  => Rational(90,minutes_per_day),
  "Pantamera Flickor Blå Lätt Lätt C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Lätt Lätt D" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Lätt Svår A" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Lätt Svår B" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Lätt Svår C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Medel A" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Medel B" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Medel C" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Svår Mellersta" => Rational(60,minutes_per_day),
  "Pantamera Flickor Blå Svår Norra" => Rational(60,minutes_per_day),
  "Pantamera Flickor Röd Lätt Norra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medellätt Norra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medellätt Södra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medellätt Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medel Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Medel Södra" => Rational(75,minutes_per_day),
  "Pantamera Flickor Röd Svår" => Rational(75,minutes_per_day),
  "Pantamera Damjuniorer division 2 norra" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 1" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 2 norra" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 2 södra" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 3 B" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 3 C" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 3 D" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 2 Norra" => Rational(90,minutes_per_day),
  "Pantamera Herrjuniorer division 3 Mellersta" => Rational(90,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Lätt A" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Lätt B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Lätt D" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Svår B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Svår C" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Lätt Svår D" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt C" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt D" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt E" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Lätt F" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Svår B" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Svår C" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Medel Svår D" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt C" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Mellersta" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Norra" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Lätt Södra" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Svår Södra" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Blå Svår Svår Mellersta" => Rational(60,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel A" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel B" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel C" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel D" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel E" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medel F" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medellätt Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medelsvår Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Medelsvår Södra" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Lätt Södra" =>  Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Lätt Mellersta" =>  Rational(75,minutes_per_day),
  "Pantamera Pojkar Ljusröd Svår" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Mörkröd Medel Mellersta" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Mörkröd Medelsvår Norra" => Rational(75,minutes_per_day),
  "Pantamera Pojkar Mörkröd Svår" => Rational(75,minutes_per_day)
}

options = OpenStruct.new
options.venue_id = nil
options.name = ""

OptionParser.new do |opts|
  opts.banner = "Usage: optparser.rb -i venueid [-nh]"

  opts.on("-i", "--venueid id", Integer, "venue id") do |i|
    options.venue_id = i
  end

  opts.on("-n", "--name name", "Name of schedule") do |n|
    options.name = n
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

cal = Icalendar::Calendar.new
if options.name.to_s.strip.length != 0 then
  cal.prodid = options.name 
else
  cal.prodid = ""
end

@url = "http://statistik.innebandy.se/ft.aspx?scr=venue&faid=" + options.venue_id.to_s
venue_doc = Nokogiri::HTML(open(@url))

venue_doc.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr td").each do |td|
  if td["nowrap"] && td.content.length > 0 then
    dtstart = DateTime.parse(td.content)
    puts td.content + " " + td.next_element.content
    dtend = dtstart + venue_game_length[td.next_element.content.strip] 
    ical_event = Icalendar::Event.new        
    ical_event.dtstart = dtstart
    ical_event.dtend = dtend
    cal.add_event(ical_event)
  end

end

puts cal.to_ical
