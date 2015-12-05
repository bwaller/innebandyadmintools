require "./venue.rb"

start_id = ARGV[0].to_i
if ARGV.length == 1 then
  stop_id = start_id
else
  stop_id = ARGV[1].to_i
end


(start_id..stop_id).each do |id|
  if venue = Venue.getvenue(id) then
    puts id.to_s + " " + venue.to_s
  end
end
