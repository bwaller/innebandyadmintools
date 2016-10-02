require 'date'
require 'rmagick'
require 'icalendar'
include Magick

event_height_px = 20
day_height_px = event_height_px*ARGV.count
margin_width_px = 60
start_hour = 8
end_hour = 21
start_date = Date.new(2016,10,01)
end_date = Date.new(2017,04,15)
canvas_width_px = margin_width_px+(end_hour-start_hour)*60
canvas_height_px = (end_date-start_date)*day_height_px.to_i
colors = ["RoyalBlue1","turquoise1","fuchsia","SlateBlue1","Green", "Blue", "Red", "Yellow", "Pink", "Magenta"]

canvas = Magick::ImageList.new
canvas.new_image(canvas_width_px, canvas_height_px, Magick::HatchFill.new('white', 'gray80'))

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

(start_date...end_date).each do |date|
  width_px = 60
  y_offset = (date.ld-start_date.ld)*day_height_px
  text.annotate(canvas, width_px,day_height_px,0, y_offset, "#{date.strftime('%a')}")
  text.annotate(canvas, width_px,day_height_px,25, y_offset, "#{date.strftime('%m-%d')}")
  date_line.line(0,y_offset,canvas_width_px,y_offset)
end

(start_hour..end_hour).each do |hour|
  x0_px = margin_width_px+(hour-start_hour)*60
  hour_line.line(x0_px, 0, x0_px, canvas_height_px) 
end

file_count = 1
cal_count = 1
ARGV.each do |file|

  cal_file = File.open(file)
  cals = Icalendar::Calendar.parse(cal_file)
  cals.each do |cal|

    cal.events.each do |event|

      #puts event.dtstart.to_s + " " + event.summary

      x0 = (event.dtstart.day_fraction*24*60).to_i - start_hour*60 + margin_width_px
      x1 = (event.dtend.day_fraction*24*60).to_i-start_hour*60 + margin_width_px
      y0 = (event.dtstart.ld-start_date.ld)*day_height_px+(file_count-1)*event_height_px
      y1 = y0 + event_height_px

      color = colors[cal_count-1]
      rect.stroke(color)
      rect.fill(color)
      rect.fill_opacity(0.2)
      rect.roundrectangle(x0,y0, x1,y1, event_height_px/4,event_height_px/4)
      rect.annotate(canvas,x1-x0,y1-y0,x0,y0,"#{event.summary}")

    end

    cal_count += 1
  end
  file_count += 1
end

date_line.draw(canvas)
hour_line.draw(canvas)
rect.draw(canvas)
#canvas.display
canvas.write("junk.png")

puts canvas_width_px.to_s + "x" + canvas_height_px.to_s 

exit
