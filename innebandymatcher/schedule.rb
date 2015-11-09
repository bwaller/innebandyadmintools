#!/usr/bin/ruby
# encoding: utf-8

require 'date'
require 'prawn'

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
    @column_width = 8
    @time_points = Hash.new
  end

  def draw_vertical_line(xpos, store_time_points = false)
    minor_width = 2
    major_width = 4
    width = major_width
    vertical_line 0, @y_axis_top, :at => xpos
    
    quarters=0
    @y_axis_top.step(0, -@quarter_points) do |ypos|
      if (store_time_points) then 
        time_str = (@startdate + Rational(quarters,24*4)).strftime("%H:%M")
        @time_points[time_str] = ypos
      end
      if (quarters % 4 == 0) then 
        width = major_width 
      else
        width = minor_width
      end
      horizontal_line xpos-width, xpos+width, :at => ypos
      quarters += 1
    end
    stroke
  end

  def draw_hours (xpos)
    @time_points.each do |time_str, ypos|
      if (time_str.match(/:00$/)) then
        draw_text time_str, :at => [xpos-24, ypos-3], :size => 8
      end
    end
  end

  def draw_event_box( col, event_date, color_str = "FFFFFF")
    fill_color color_str
    start_str = event_date.strftime("%H:%M")
    end_str = (event_date + Rational(1,24)).strftime("%H:%M")
    rounded_polygon 2, [col*@column_width, @time_points[start_str]],
                       [(col+1)*@column_width, @time_points[start_str]],
                       [(col+1)*@column_width, @time_points[end_str]],
                       [col*@column_width, @time_points[end_str]]
    fill_and_stroke
  end
end

startyear = DateTime.now.year
endyear = startyear+1
schedule = GameSchedule.new("2015-2016", 
                            DateTime.new(startyear, 10, 1, 9, 0, 0, 1),
                            DateTime.new(endyear, 4, 15, 21, 0, 0, 1))
(0..schedule.column_width*3*3*7).step(schedule.column_width*9) do |x|
  if x == 0 then
    schedule.draw_vertical_line x, true
  else
    schedule.draw_vertical_line x
  end
end
schedule.draw_hours(50)

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

schedule.save_as("schedule.pdf")

