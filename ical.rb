# encoding: UTF-8

class Ical
 
  def initialize(start_date, end_date, title, description, location)
    @start_date = start_date
    @end_date = end_date
    @title = title
    @description = description
    @location = location
  end

  def include_js_html
    return '<script type="text/javascript" src="https://addevent.com/libs/atc/1.6.1/atc.min.js" async defer></script>'
  end
  
  def event_html
    ans = '<div title="Add to Calendar" class="addeventatc">'
    ans += 'Add to calendar'
    ans += '<span class="start">' + @start_date + '</span>'
    ans += '<span class="end">' + @end_date + '</span>'
    ans += '<span class="timezone">Europe/Stockholm</span>'
    ans += '<span class="title">' + @title + '</span>'
    ans += '<span class="description">' + @description + '</span>'
    ans += '<span class="location">' + @location + '</span>'
    #ans += '<span class="organizer">Organizer</span>'
    #ans += '<span class="organizer_email">Organizer e-mail</span>'
    ans += '<span class="all_day_event">false</span>'
    ans += '<span class="date_format">MM/DD/YYYY</span>'
    ans += '<span class="client">aoWwMfDsvzwhGzfvymPv20458</span>'
    ans += '</div>'
    return ans
  end

end

