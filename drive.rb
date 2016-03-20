# encoding: utf-8

require "google/api_client"
require "google_drive"
require "icalendar"

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
session = GoogleDrive.saved_session("config.json")
calender_name = "meeting.ics"

# Gets list of remote files.
file = session.file_by_title(calender_name)
file.delete if file

cal = Icalendar::Calendar.new
cal.event do |e|
  e.dtstart     = Icalendar::Values::Date.new('20160130')
  e.dtend       = Icalendar::Values::Date.new('20160130')
  e.summary     = "Meeting with the man."
  e.description = "Have a long lunch meeting and decide nothing..."
  e.ip_class    = "PRIVATE"
end

session.upload_from_string(cal.to_ical,calender_name)
puts session.file_by_title(calender_name).human_url
