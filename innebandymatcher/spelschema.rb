#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'writeexcel'

filename = ARGV[0]

class Event

  attr_accessor :arena, :series

  def initialize(series, start_date_str, start_clock_str, length, arena)
    @series = String.new(series.to_s)
    @start_time = DateTime.iso8601(start_date_str+"T"+start_clock_str+":00+01:00")
    @length = length #In minutes
    @end_time = @start_time + Rational(length,24*60)
    @arena = String.new(arena.to_s)
  end

  def eventdate_str
    return @start_time.strftime("%F")
  end

  def start_time_str
    return @start_time.strftime("%T")
  end

  def end_time_str
    return @end_time.strftime("%T")
  end

end # game

class EventWorkbook < WriteExcel
  def initialize( filename )
    super(filename)
  end 
  
  def add_worksheet(year, startweek, endweek, sheetname = '', name_utf16be = false)
    name, name_utf16be = check_sheetname(sheetname, name_utf16be)

    init_data = [
                  self,
                  name,
                  name_utf16be,
                  year,
                  startweek,
                  endweek
    ]
    worksheet = EventWorksheet.new(*init_data)
    @worksheets << worksheet                      # Store ref for iterator
    @parser.set_ext_sheets(name, worksheet.index) # Store names in Formula.rb
    worksheet
  end
end

class EventWorksheet < Writeexcel::Worksheet
  def initialize(workbook, name, name_utf16be, year, startweek, endweek)
    super(workbook, name, name_utf16be)
    @year = year
    @start_week = startweek
    @end_week = endweek
    @head_format = "%a %e/%m"
    @col = 1
    @row = 1
    @starthour = 8
    @endhour = 21
    @time_format = workbook.add_format(:num_format => 'hh:mm')
    print_rows
  end 

  def print_rows
    (@starthour...@endhour).each do |hour|
      (0...60).step(15) do |minute|
        hour.to_s.size == 2 ? hour_str = hour.to_s: hour_str = "0"+hour.to_s 
        minute.to_s.size == 2 ? minute_str = minute.to_s: minute_str = "0"+minute.to_s 
        time_str = "T"+hour_str + ":" + minute_str + ".0"
        self.write_date_time(@row, 0, time_str, @time_format)
        @row += 1
      end
    end
  end

  def print_column (year, week, col, events, head_format = @head_format)
    (Date.commercial(year,week,5)..Date.commercial(year, week, 7)).each do |date|
      self.write(0, col, date.strftime(head_format))
      if event = events[date.strftime("%F")] then
        puts event.eventdate_str + " " + event.start_time_str + " " + event.end_time_str + " " + event.arena
      end
      col 
    end
    return col
  end

  def print_columns(events)
    year = @year 
    (@start_week..51).each do |week|
      @col = print_column(year, week, @col, events)
    end
    #next year
    year += 1
    (1..@end_week).each do |week|
      @col = print_column(@year+1, week, @col, events)
    end
  end
end

#test
myfirstevent = Event.new("P-LR-M-D","2015-11-15","14:00", 60, "Tappströms Bollhall")
mysecondevent = Event.new("P-LR-M-D","2016-01-12","16:00", 60, "Tappströms Bollhall")
#puts myfirstevent.eventdate_str + " " + myfirstevent.start_time_str + " " + myfirstevent.end_time_str + " " + myfirstevent.arena

events = Hash.new
events[myfirstevent.eventdate_str] = myfirstevent
events[mysecondevent.eventdate_str] = mysecondevent

workbook = EventWorkbook.new(filename) 
worksheet = workbook.add_worksheet(DateTime.now.year, 35, 15)
worksheet.print_columns(events)

workbook.close

