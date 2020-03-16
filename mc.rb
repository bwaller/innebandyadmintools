require "prawn"
require "json"

img = "match-19-20.png"

json_from_file = File.read("myfile.json")
info = JSON.parse(json_from_file)

size = [2480,3507] 
output_filename = "tmp_matchändring_"+
                  info['fixture_number']+"_"+
                  info['home_team'].gsub(" ","")+"_"+
                  info['away_team'].gsub(" ","")+".pdf"

Prawn::Document.generate(output_filename,
                         :page_size  => size,
                         :background => img
) do

  draw_text info['fixture_number'], :size => 48, :at =>[ 450, 2980 ]
  draw_text info['serie'],          :size => 48, :at =>[ 1450, 2980 ]
  draw_text info['home_team'],      :size => 48, :at =>[ 450, 2880 ]
  draw_text info['away_team'],      :size => 48, :at =>[ 1450, 2880 ]

  draw_text info['orig_date'],      :size => 42, :at =>[ 330, 2730 ]
  draw_text info['orig_time'],      :size => 42, :at =>[ 720, 2730 ]
  draw_text info['orig_venue'],     :size => 42, :at =>[ 1370, 2730 ]

  draw_text info['new_date'],       :size => 42, :at =>[ 330, 2580 ]
  draw_text info['new_time'],       :size => 42, :at =>[ 720, 2580 ]
  draw_text info['new_venue'],      :size => 42, :at =>[ 1370, 2580 ]

  if info['new_date'].match(/TBD/) then
    draw_text 'X', :size => 56, :at =>[315, 2275] 
  else 
    draw_text 'X', :size => 56, :at =>[315, 2430] 
  end
 
  draw_text info['applicant_club'],    :size => 48, :at => [ 550, 2035 ]
  draw_text info['applicant_contact'], :size => 48, :at => [ 550, 1935 ]
  draw_text info['applicant_phone'],   :size => 48, :at => [ 550, 1835 ]
  draw_text info['applicant_email'],   :size => 48, :at => [ 550, 1735 ]

  draw_text info['opponent_contact'], :size => 48, :at => [ 550, 1590 ]
  draw_text info['opponent_phone'],   :size => 48, :at => [ 550, 1490 ]
  draw_text info['opponent_email'],   :size => 48, :at => [ 1370, 1490 ]

  case info['serie'] 
  when /Blå Lätt/
    y_pos = 1378
  when /Blå Svår/, /Blå Medel/
    y_pos = 1329
  when /Röd/
    y_pos = 1280
  when /[Jj]uniorer/
    y_pos = 1231
  else
    y_pos = 1231
  end

  draw_text 'x', :size => 42, :at => [ 349, y_pos ]

end
