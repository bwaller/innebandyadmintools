#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'prawn'
require './event.rb'

class GameSchedule
  include Prawn::View
  
  attr_reader :column_width

  def initialize(name, startdate, enddate)
    @name = name
    @startdate = startdate
    @enddate = enddate
    @document = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    @y_axis_top = 7*72
    @hour_points = (@y_axis_top/(enddate.hour-startdate.hour)).to_i
    @minute_points = (@hour_points/60).to_i
    @quarter_points = (@hour_points/4).to_i
    @column_width = 10
    @time_points = Hash.new
    @day_points = Hash.new
    @series = Hash.new
    store_time_points
  end

  def get_ypos_from_time(date)
    key = DateTime.new(@startdate.year, 
                       @startdate.month, 
                       @startdate.day,
                       date.hour,
                       date.minute,
                       date.second,
                       "+24:00")
    puts "get_ypos: " + key.to_s
    return @time_points[key]
  end

  def store_time_points
    quarters=0
    @y_axis_top.step(0, -@quarter_points) do |ypos|
      @time_points[@startdate + Rational(quarters,24*4)] = ypos
      quarters += 1
    end
  end

  def store_day_points
    weeks = Array.new
    (@startdate.cweek..Date.new(DateTime.now.year, 12, 31).cweek).each do |week|
      weeks.push(week)
    end
    (1..@enddate.cweek).each do |week|
      weeks.push(week)
    end

    day_counter=0
    weeks.each do |week|
      (5..7).each do |weekday|
        key = DateTime.commercial(@startdate.year, week, weekday)
        @day_points[key] = day_counter*@column_width*@series.length
        day_counter += 1
      end
    end
  end

  def draw_vertical_line(xpos)
    minor_width = 2
    major_width = 4
    width = major_width
    vertical_line @time_points.values.last, @time_points[@startdate], :at => xpos
    
    @time_points.each do |date, ypos| 
      if (date.minute == 0) then 
        width = major_width 
      else
        width = minor_width
      end
      horizontal_line xpos-width, xpos+width, :at => ypos
    end
    stroke
  end

  def draw_hour_tics (xpos)
    @time_points.each do |date, ypos|
      if (date.minute == 0) then
        draw_text date.strftime("%H:%M"), :at => [xpos-24, ypos-3], :size => 8
      end
    end
  end

  def draw_day(date, xpos)
    date_str = date.strftime("%F")
    draw_text date.strftime("%a"), :at => [xpos, @y_axis_top+18], :size => 6
    draw_text date.strftime("%-d %b"), :at => [xpos, @y_axis_top+9], :size => 6
    if( date.cwday == 5) then #5 => friday
      draw_vertical_line xpos
    end
    @series.each do |serie, events|
      events.each do |key, event|
        if (key.strftime("%F") == date.strftime("%F")) then 
          puts "Hit!: " + serie + " " + event.arena + " " + event.opponents + " " + event.start_date.to_s + " " + event.end_date.to_s
          draw_event_box xpos, event.start_date, event.end_date
        end
      end
      xpos += @column_width
    end
    if( date.cwday == 6 and date.cweek % 2 == 0) then #6 => saturday
      draw_hour_tics xpos
    end
    return xpos
  end
  
  def draw_days
    @day_points.each do |date, xpos|
      draw_day(date, xpos)      
    end
  end
 
  def draw_event_box(xpos, datestart, dateend, color_str = "FFFFFF")
    puts "draw_event_box: " + datestart.to_s + " " + dateend.to_s
    if (get_ypos_from_time datestart) and (get_ypos_from_time dateend) then 
      #fill_color(color_str)
      rounded_polygon 2, [xpos, get_ypos_from_time(datestart)],
                         [xpos+@column_width, get_ypos_from_time(datestart)],
                         [xpos+@column_width, get_ypos_from_time(dateend)],
                         [xpos, get_ypos_from_time(dateend)]
      #fill_and_stroke
      stroke
    end
  end

  def add_event(series, event)
    if ( @series.has_key?(series) ) then 
      @series[series][event.start_date] = event
    else
      @series[series] = Hash.new
      @series[series][event.start_date] = event
    end
  end

  def dump
    puts "Number of series: #{@series.length}"
    @series.each do |serie, events|
      puts "Events for serie " + serie.to_s
      events.each_value do |event|
        puts event.eventdate_str + " " + event.start_time_str + " " + event.opponents + " " + event.arena
      end
    end    
    @time_points.each do |key, value|
      puts key.to_s + " " + value.to_s
    end
  end

end

startyear = DateTime.now.year
endyear = startyear+1
schedule = GameSchedule.new("2015-2016", 
                            DateTime.new(startyear, 9, 23, 8, 0, 0, 1),
                            DateTime.new(endyear, 4, 15, 21, 0, 0, 1))
schedule.add_event("SerieA", Event.new(DateTime.new(startyear, 10, 2, 9, 0, 0, 1), DateTime.new(startyear, 10, 2, 10, 0, 0, 1), "Hässelby IBF"))
schedule.add_event("SerieB", Event.new(DateTime.new(startyear, 10, 2, 9, 15, 0, 1), DateTime.new(startyear, 10, 2, 10, 0, 0, 1), "Hässelby IBF"))
schedule.add_event("SerieA", Event.new(DateTime.new(startyear, 10, 9, 13, 0, 0, 1), DateTime.new(startyear, 10, 9, 14, 0, 0, 1), "Ingarö IF", "Ingaröhallen"))
schedule.add_event("SerieB", Event.new(DateTime.new(startyear, 11, 1, 16, 15, 0, 1), DateTime.new(startyear, 11, 1, 17, 30, 0, 1), "Kungsängen IF"))
schedule.add_event("SerieB", Event.new(DateTime.new(startyear, 10, 4, 12, 0, 0, 1), DateTime.new(startyear, 10, 4, 13, 0, 0, 1), "Ängby", "Ängbyhallen"))
schedule.add_event("SerieC", Event.new(DateTime.new(startyear, 10, 2, 9, 0, 0, 1), DateTime.new(startyear, 10, 2, 10, 0, 0, 1), "Hässelby IBF"))
schedule.add_event("SerieC", Event.new(DateTime.new(startyear, 10, 9, 13, 0, 0, 1), DateTime.new(startyear, 10, 9, 14, 0, 0, 1), "Ingarö IF", "Ingaröhallen"))
schedule.add_event("SerieC", Event.new(DateTime.new(startyear, 11, 1, 16, 30, 0, 1), DateTime.new(startyear, 11, 1, 17, 30, 0, 1), "Kungsängen IF"))
schedule.add_event("SerieC", Event.new(DateTime.new(startyear, 10, 4, 12, 0, 0, 1), DateTime.new(startyear, 10, 4, 13, 0, 0, 1), "Ängby", "Ängbyhallen"))
schedule.store_day_points
schedule.draw_days
schedule.dump
schedule.save_as("schedule.pdf")

=begin
schedule.draw_event_box(0, DateTime.new(startyear, 10, 1, 9, 0, 0, 1), "FFFF00")
schedule.draw_event_box(1, DateTime.new(startyear, 10, 1, 10, 0, 0, 1))
schedule.draw_event_box(2, DateTime.new(startyear, 10, 1, 11, 0, 0, 1), "0000FF")
schedule.draw_event_box(3, DateTime.new(startyear, 10, 1, 12, 0, 0, 1))
schedule.draw_event_box(4, DateTime.new(startyear, 10, 1, 13, 0, 0, 1))
schedule.draw_event_box(5, DateTime.new(startyear, 10, 1, 14, 0, 0, 1))
schedule.draw_event_box(6, DateTime.new(startyear, 10, 1, 15, 0, 0, 1))
schedule.draw_event_box(7, DateTime.new(startyear, 10, 1, 15, 15, 0, 1))
schedule.draw_event_box(8, DateTime.new(startyear, 10, 1, 15, 30, 0, 1))
schedule.draw_event_box(9, DateTime.new(startyear, 10, 1, 15, 45, 0, 1))
schedule.draw_event_box(10, DateTime.new(startyear, 10, 1, 16, 0, 0, 1))
=end

