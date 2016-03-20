# encoding: UTF-8
require 'icalendar'

# Create a calendar with an event (standard method)
cal = Icalendar::Calendar.new
cal.event do |e|
  e.dtstart     = Icalendar::Values::Date.new('20050428')
  e.dtend       = Icalendar::Values::Date.new('20050429')
  e.summary     = "Meeting with the man."
  e.description = "Have a long lunch meeting and decide nothing..."
  e.ip_class    = "PRIVATE"
end

event = Icalendar::Event.new
event.dtstart = DateTime.civil(2006, 6, 23, 8, 30)
event.summary = "A great event!"
cal.add_event(event)

event2 = cal.event  # This automatically adds the event to the calendar
event2.dtstart = DateTime.civil(2006, 6, 24, 8, 30)
event2.summary = "Another great event!"

cal.publish

cal_string = cal.to_ical
puts cal_string

