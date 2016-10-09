require 'date'
require 'rmagick'
require 'icalendar'
include Magick

event_height_px = 20
day_height_px = event_height_px*ARGV.count
margin_width_px = 60
margin_height_px = 40
start_hour = 8
end_hour = 21
start_date = Date.new(2016,10,01)
end_date = Date.new(2017,04,15)
canvas_width_px = margin_width_px+(end_hour-start_hour)*60
canvas_height_px = (end_date-start_date)*day_height_px.to_i
colors = ["RoyalBlue1","turquoise1","fuchsia","SlateBlue1","Green", "Blue", "Red", "Yellow", "Pink", "Magenta"]

canvas = Magick::ImageList.new
#Magick::HatchFill.new('white', 'gray80')
canvas.new_image(canvas_width_px, canvas_height_px)

text = Magick::Draw.new
text.font_family = 'helvetica'
text.pointsize = 10
text.gravity = Magick::WestGravity

rect = Magick::Draw.new
rect.font_family = 'helvetica'
rect.pointsize = 9
rect.gravity = Magick::CenterGravity
 
date_line = Magick::Draw.new
date_line.stroke_width = 5

hour_line = Magick::Draw.new
hour_line.stroke_width = 5

y_offset = margin_height_px
y_coordinate = Hash.new

#####################
# Populate dates hash
#####################
dates = Hash.new
(start_date...end_date).each do |date|
  dates[date] = Array.new
end

###############################
# Add Icalendar events to dates
###############################
ARGV.each do |file|

  cal_file = File.open(file)
  cals = Icalendar::Calendar.parse(cal_file)
  cals.each do |cal|

    cal.events.each do |event|

      key = event.dtstart.to_date
      dates[key].push(event) if dates[key]

    end

  end
end

############################
# Draw all dates with events
############################
dates.each do |key,date|
  date.each do |event|
    
  end
end

date_line.draw(canvas)
hour_line.draw(canvas)
rect.draw(canvas)
#canvas.display
canvas.write("junk.png")

#puts canvas_width_px.to_s + "x" + canvas_height_px.to_s 

exit
