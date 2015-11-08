#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'writeexcel'

filename = ARGV[0]

class Event

  attr_accessor :arena, :series, :start_time, :end_time, :opponents

  def initialize(series, start_date_str, start_clock_str, length, opponents, arena)
    @series = String.new(series.to_s)
    @start_time = DateTime.iso8601(start_date_str+"T"+start_clock_str+":00+01:00")
    @length = length #In minutes
    @end_time = @start_time + Rational(length,24*60)
    @opponents = String.new(opponents.to_s)
    @arena = String.new(arena.to_s)
    @@home_arena = "Tappströms Bollhall"
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

  def text
    return @arena == @@home_arena ? "Hemma" : "Borta"
  end

  def home
    return @arena == @@home_arena ? true : false
  end

  def away
    return !home
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
    @home_top_format = workbook.add_format(:top => 1, :left => 1, :right => 1, :bg_color => 'blue')
    @home_side_format = workbook.add_format(:left => 1, :right => 1, :bg_color => 'blue')
    @home_bottom_format = workbook.add_format(:bottom => 1, :left => 1, :right => 1, :bg_color => 'blue')
    @away_top_format = workbook.add_format(:top => 1, :left => 1, :right => 1, :bg_color => 'yellow')
    @away_side_format = workbook.add_format(:left => 1, :right => 1, :bg_color => 'yellow')
    @away_bottom_format = workbook.add_format(:bottom => 1, :left => 1, :right => 1, :bg_color => 'yellow')
    @series = Hash.new
    set_landscape
    set_paper(9) # A4
    set_print_scale(45)
    print_rows
  end 

  def add_event(event)
    if ( @series.has_key?(event.series) ) then 
      @series[event.series][event.eventdate_str] = event
    else
      @series[event.series] = Hash.new
      @series[event.series][event.eventdate_str] = event
    end
 end

  def print_rows
    (@starthour...@endhour).each do |hour|
      (0...60).step(15) do |minute|
        hour.to_s.size == 2 ? hour_str = hour.to_s: hour_str = "0"+hour.to_s 
        minute.to_s.size == 2 ? minute_str = minute.to_s: minute_str = "0"+minute.to_s 
        time_str = "T"+hour_str + ":" + minute_str + ".0"
        write_date_time(@row, 0, time_str, @time_format)
        @row += 1
      end
    end
  end

  def getformat (event)
    if (event.home) then
      return @home_top_format, @home_side_format, @home_bottom_format
    else
      return @away_top_format, @away_side_format, @away_bottom_format
    end
  end

  def print_column (year, week, col, series, head_format = @head_format)
    first_col, last_col = col
    (Date.commercial(year,week,5)..Date.commercial(year, week, 7)).each do |date|
      write(0, col, date.strftime(head_format))
      series.each do |serie, events|
        set_column(col, col, 3)
        write(1, col, serie)
        if event = events[date.strftime("%F")] then
          row = 1 + (event.start_time.hour-@starthour)*4+event.start_time.minute/15
          top_format, side_format, bottom_format = self.getformat(event)
          write_blank(row, col, top_format)
          write_blank(row + 1, col, side_format)
          write_blank(row + 2, col, side_format)
          write_blank(row + 3, col, bottom_format)
        end
        col += 1
        set_column(col, col, 0.5)
      end 
      last_col = col - 1
      merge_range(0, first_col, 0, last_col, date.strftime(head_format), @workbook.add_format())
      first_col = col
    end
    set_column(col, col, 1)
    return col + 1
  end

  def print_columns
    year = @year 
    (@start_week..51).each do |week|
      @col = print_column(year, week, @col, @series)
    end
    #next year
    year += 1
    (1..@end_week).each do |week|
      @col = print_column(@year+1, week, @col, @series)
    end
  end

  def dump
    @series.each do |serie, events|
      puts "Events for serie " + serie.to_s
      events.each_value do |event|
        puts event.eventdate_str + " " + event.start_time_str + " " + event.opponents + " " + event.arena
      end
    end
  end

end

#test


workbook = EventWorkbook.new(filename) 
worksheet = workbook.add_worksheet(DateTime.now.year, 45, 15)

#worksheet.dump

worksheet.print_columns

workbook.close

