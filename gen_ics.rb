#encoding: utf-8

require 'date'
require 'icalendar'
require "./serie.rb"
require "./team.rb"
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.team_id = nil
options.serie_id = nil
options.marginal = 45
options.game_length = 0
options.name = ""

OptionParser.new do |opts|
  opts.banner = "Usage: optparser.rb -i venueid [-nh]"

  opts.on("-t", "--teamid id", Integer, "team id") do |t|
    options.team_id = t
  end

  opts.on("-s", "--serieid id", Integer, "serie id") do |s|
    options.serie_id = s
  end

  opts.on("-m", "--minutesbefore min", Integer, "minutes before game") do |m|
    options.marginal = m
  end

  opts.on("-n", "--name name", "Name of schedule") do |n|
    options.name = n
  end

  opts.on("-l", "--gamelength min", Integer, "Length of game in minutes") do |l|
    options.game_length = l
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

myteam = Team.new(options.team_id, options.serie_id)
myteam.populate_events
myteam.events.each do |event|

  if event.is_valid? then

    ical_event = Icalendar::Event.new
    ical_event.dtstart = (event.start_time-Rational(options.marginal,24*60))
    if options.game_length > 0 then
      ical_event.dtend = (event.start_time + Rational(options.game_length,24*60))
    else
      ical_event.dtend = event.end_time
    end
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
