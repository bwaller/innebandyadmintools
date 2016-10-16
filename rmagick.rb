require 'date'
require 'rmagick'
require 'icalendar'
include Magick

event_height_px = 15
margin_width_px = 60
margin_height_px = 40
start_hour = 8
end_hour = 21
start_date = Date.new(2016,9,26)
end_date = Date.new(2017,04,15)
canvas_width_px = margin_width_px+(end_hour-start_hour)*60
colors = ["Green", "Blue", "Red", "DarkTurquoise", "YellowGreen", "SlateGrey3"]

text = Magick::Draw.new

rect = Magick::Draw.new
rect.font_family = 'helvetica'
rect.pointsize = 9
rect.gravity = Magick::CenterGravity
 
date_line = Magick::Draw.new
date_line.stroke('black')
date_line.fill_opacity(0)
date_line.stroke_width(1)

hour_line = Magick::Draw.new
hour_line.stroke('black')
hour_line.fill_opacity(0)
hour_line.stroke_opacity(0.75)
hour_line.stroke_width(1)

quarter_line = Magick::Draw.new
quarter_line.stroke('black')
quarter_line.fill_opacity(0)
quarter_line.stroke_opacity(0.5)
quarter_line.stroke_width(1)

hour_text = Magick::Draw.new

#####################
# Populate dates hash
#####################
dates = Hash.new
(start_date...end_date).each do |date|
  dates[date] = Hash.new
end

###############################
# Add Icalendar events to dates
###############################
cal_index = 0
ARGV.each do |file|

  cal_file = File.open(file)
  cals = Icalendar::Calendar.parse(cal_file)
  cals.each do |cal|

    cal.events.each do |event|
      event.x_custom_property.push(colors[cal_index])
      date = event.dtstart.to_date
      if dates[date] then
         dates[date][cal_index] = Array.new if !dates[date][cal_index]
         dates[date][cal_index].push(event) 
      end
    end

    cal_index += 1

  end
end

############################
# Count the number of rows
############################
row_count = 0
dates.each do |date,events|
  row_count += 1 #each day
  row_count += events.size - 1 if events.size > 0 #add one row for each extra event per day
end

###################
# Create the image
###################
canvas = Magick::ImageList.new
canvas.new_image(canvas_width_px, event_height_px*row_count + margin_height_px)

y0 = margin_height_px
text_width_px = 60
#################################
# Draw all dates and their events
#################################
dates.each do |date,cals|

  fill = 'black'
  fill = 'red' if date.sunday? 
 
  text.annotate(canvas, text_width_px, event_height_px, 0, y0, "#{date.strftime('%a')}") do
    self.font = 'Helvetica'
    self.pointsize = 9
    self.fill = fill
    self.gravity = Magick::WestGravity
  end

  text.annotate(canvas, text_width_px, event_height_px, 25, y0, "#{date.strftime('%d %b')}")

  date_line.stroke_opacity(0.3)
  date_line.stroke_opacity(0.7) if date.monday?
  date_line.line(0, y0, canvas_width_px, y0)

  cals.each do |cal,events|

    events.each do |event|
      x0 = (event.dtstart.day_fraction*24*60).to_i - start_hour*60 + margin_width_px
      x1 = (event.dtend.day_fraction*24*60).to_i-start_hour*60 + margin_width_px
      y1 = y0 + event_height_px

      rect.stroke(event.x_custom_property[0])
      rect.fill(event.x_custom_property[0])
      rect.fill_opacity(0.2)
      rect.roundrectangle(x0,y0, x1,y1, event_height_px/4,event_height_px/4)
      rect.annotate(canvas,x1-x0,y1-y0,x0,y0,"#{event.summary}")
  
    end

    y0 += event_height_px if cals.size() > 1

  end
  
  y0 += event_height_px if cals.size() < 2

end

############################
# Draw hour lines vertically
############################
(start_hour..end_hour).each do |hour|
  x0 = margin_width_px+(hour-start_hour)*60
  y0_ = event_height_px*1.5
  hour_line.line(x0, y0_ , x0, y0) 
  (1..3).each do |quarter|
    x0_quarter = x0 + quarter*15
    quarter_line.line(x0_quarter, y0_, x0_quarter, y0)
  end 
  #Draw full hour text
  hour_text.annotate(canvas,10,10,x0,y0_-10,"#{hour}:00") do
    self.font = 'Helvetica'
    self.pointsize = 9
    self.align = Magick::CenterAlign
    self.gravity = Magick::CenterGravity
  end
end

date_line.draw(canvas)
hour_line.draw(canvas)
quarter_line.draw(canvas)
rect.draw(canvas)
canvas.trim!
canvas.write("junk.png")

#puts canvas_width_px.to_s + "x" + canvas_height_px.to_s 
#puts canvas_height_px, y0

exit
