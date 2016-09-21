#encoding: utf-8

require 'date'
require 'icalendar'
require "./serie.rb"
require "./team.rb"

team_id = ARGV[0]
serie_id = ARGV[1]

cal = Icalendar::Calendar.new

myteam = Team.new(ARGV[0], ARGV[1])
myteam.populate_events
myteam.events.each do |event|

  if event.is_valid? then

    ical_event = Icalendar::Event.new
    ical_event.dtstart = (event.start_time-Rational(45,24*60))
    ical_event.dtend = event.end_time
    ical_event.summary = event.home_team.name.to_s.strip + " vs " + event.away_team.name.to_s.strip
    ical_event.location = event.venue.name.to_s 
    ical_event.location += '\n' + event.venue.streetaddress.to_s + '\n' + event.venue.postal_code + " " + event.venue.locality if event.is_away?
    ical_event.description = "Matchstart: " + event.start_time.strftime("%H:%M") + '\n' + event.serie.name.to_s
    ical_event.url = "http://www.ekeroik.se/group/28556"
    cal.add_event(ical_event)

  end

end

outfile = myteam.serie.name.gsub(/[a-zåäö ]/,"") + "_" + myteam.name.gsub(/ /,"") + ".ics"
of = File.open(outfile,"w+")
of.puts(cal.to_ical)
puts outfile
