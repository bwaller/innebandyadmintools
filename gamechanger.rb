# encoding: utf-8

require 'sinatra'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './person.rb'
require 'prawn'
require 'tmpdir'

def encode(astring)
  return astring.gsub("å","_aa_").gsub("ä","_ae_").gsub("ö","_oo_").gsub("Å","_AA_").gsub("Ä","_AE_").gsub("Ö","_OO_")
end

def decode(astring)
  return astring.gsub("_aa_","å").gsub("_ae_","ä").gsub("_oo_","ö").gsub("_AA_","Å").gsub("_AE_","Ä").gsub("_OO_","Ö")
end

get '/' do

  params['serie'] ? serie = decode(params['serie']) : serie = ""
  home_team = decode(params['home_team']) if params['home_team']
  away_team = decode(params['away_team']) if params['away_team']
  orig_venue = decode(params['orig_venue']) if params['orig_venue']
  applicant_contact = decode(params['applicant_contact']) if params['applicant_contact']
  opponent_contact = decode(params['opponent_contact']) if params['opponent_contact']

  erb :main, :locals => {:fixture_number => params['fixture_number'],
                         :serie => serie,
                         :home_team => home_team,
                         :away_team => away_team,
                         :orig_date => params['orig_date'],
                         :orig_time => params['orig_time'],
                         :orig_venue => orig_venue,
                         :applicant_contact => applicant_contact,
                         :applicant_phone => params['applicant_phone'],
                         :applicant_email => params['applicant_email'],
                         :opponent_contact => opponent_contact,
                         :opponent_phone => params['opponent_phone'],
                         :opponent_email => params['opponent_email']
                        }

end

get '/getgamedata' do

  base_url = "http://statistik.innebandy.se/"
  fixture_number = "Unknown"

  def get_contact_id(team_url)
    contact_id = 0

    team_page = Nokogiri::HTML(open(team_url))

    links = team_page.css('div#iList dl').css('a')
    links.each do |link|
      contact_id = link["href"].gsub(/[^0-9]/,'') if link["href"].match("scr=person")
    end

    return contact_id
  end

  page = Nokogiri::HTML(open(params['game_url']))

  elem = page.at('td:contains("Matchnummer")')
  fixture_number = elem.next_element.content if elem != nil

  elem = page.at('td:contains("Tävling")')
  serie = elem.next_element.content
  serie_url = base_url + elem.next_element.element_children[0]["href"] # Save this for blue series, needed below

  elem = page.at('td:contains("Tid")')
  date_time = elem.next_element.content
  orig_date = date_time.split(" ")[0]
  orig_time = date_time.split(" ")[1]

  elem = page.at('td:contains("Spelplats")')
  orig_venue = elem.next_element.content.gsub(/ , /,", ")

  if serie.match(/[Bb]lå/) then
    elem = page.at('h1:contains("Matchinformation")')
    home_team = elem.content.gsub("Matchinformation: ","").gsub(/ -.*$/,"").strip
    away_team = elem.content.gsub(/^.* - /,"").strip

    home_team_url = ""
    away_team_url = ""
    serie_page = Nokogiri::HTML(open(serie_url))
    links = serie_page.css('a')
    links.each do |link|
      home_team_url = base_url + link["href"] if link.content.match(/#{home_team.gsub("(","\\(").gsub(")","\\)")}/)
      away_team_url = base_url + link["href"] if link.content.match(/#{away_team.gsub("(","\\(").gsub(")","\\)")}/)
    end
  else
    th = page.css('div#iList th')

    home_team = th[0].content
    home_team_url = base_url + th[0].element_children[0]["href"]

    away_team = th[2].content
    away_team_url = base_url + th[2].element_children[0]["href"]
  end

  if home_team.match("Ekerö") then
    applicant_person = Person.new(get_contact_id(home_team_url))
    opponent_person = Person.new(get_contact_id(away_team_url))
  else
    applicant_person = Person.new(get_contact_id(away_team_url))
    opponent_person = Person.new(get_contact_id(home_team_url))
  end

  query = "/?fixture_number=#{fixture_number}" +
          "&serie='#{serie}'" +
          "&home_team='#{home_team}'" +
          "&away_team='#{away_team}'" +
          "&orig_date=#{orig_date}" +
          "&orig_time=#{orig_time}" +
          "&orig_venue='#{orig_venue}'" +
          "&applicant_contact='#{applicant_person.name}'" +
          "&applicant_phone='#{applicant_person.cell_phone}'" +
          "&applicant_email='#{applicant_person.email}'" +
          "&opponent_contact='#{opponent_person.name}'" +
          "&opponent_phone='#{opponent_person.cell_phone}'" +
          "&opponent_email='#{opponent_person.email}'"

  redirect encode(query)

end

set :prawn, { :page_layout => :portrait }

get '/renderpdf' do

  size = [2480,3507]
  img = "match-19-20.png"

  pdf = Prawn::Document.new(:page_size  => size,
                            :background => img)

  pdf.draw_text params['fixture_number'], :size => 48, :at =>[ 450, 2980 ]

  if params['serie'].length < 37 then
    pdf.draw_text params['serie'],          :size => 48, :at =>[ 1400, 2980 ]
  else
    pdf.draw_text params['serie'],          :size => 36, :at =>[ 1400, 2980 ]
  end
  pdf.draw_text params['home_team'],      :size => 48, :at =>[ 450, 2880 ]
  pdf.draw_text params['away_team'],      :size => 48, :at =>[ 1400, 2880 ]

  pdf.draw_text params['orig_date'],      :size => 42, :at =>[ 330, 2730 ]
  pdf.draw_text params['orig_time'],      :size => 42, :at =>[ 720, 2730 ]
  pdf.draw_text params['orig_venue'],     :size => 42, :at =>[ 1370, 2730 ]

  if params['new_fixture_date'].match(/true/) then
    pdf.draw_text 'X', :size => 56, :at =>[315, 2430]
    new_date  = params['new_date']
    new_time  = params['new_time']
    new_venue = params['new_venue']
  else
    pdf.draw_text 'X', :size => 56, :at =>[315, 2275]
    new_date  = '---'
    new_time  = '---'
    new_venue = '---'
  end

  pdf.draw_text new_date,       :size => 42, :at =>[ 330, 2580 ]
  pdf.draw_text new_time,       :size => 42, :at =>[ 720, 2580 ]
  pdf.draw_text new_venue,      :size => 42, :at =>[ 1370, 2580 ]

  pdf.draw_text params['applicant_club'],    :size => 48, :at => [ 550, 2035 ]
  pdf.draw_text params['applicant_contact'], :size => 48, :at => [ 550, 1935 ]
  pdf.draw_text params['applicant_phone'],   :size => 48, :at => [ 550, 1835 ]
  pdf.draw_text params['applicant_email'],   :size => 48, :at => [ 550, 1735 ]

  pdf.draw_text params['opponent_contact'], :size => 48, :at => [ 550, 1590 ]
  pdf.draw_text params['opponent_phone'],   :size => 48, :at => [ 550, 1490 ]
  pdf.draw_text params['opponent_email'],   :size => 48, :at => [ 1370, 1490 ]

  case params['serie']
  when /[Bb]lå [Ll]ätt/
    y_pos = 1378
  when /[Bb]lå [Ss]vår/, /[Bb]lå [Mm]edel/
    y_pos = 1329
  when /[Rr]öd/
    y_pos = 1280
  when /[Jj]uniorer/
    y_pos = 1231
  else
    y_pos = 1231
  end

  pdf.draw_text 'x', :size => 42, :at => [ 349, y_pos ]

  render_filename = Dir::Tmpname.create(['gamechange-', '.pdf']) {}
  send_filename = "#{params['fixture_number']}_matchändring.pdf"

  pdf.render_file(render_filename)

  send_file render_filename, :filename => send_filename, :type => 'Application/pdf', :disposition => 'attachment'

end
