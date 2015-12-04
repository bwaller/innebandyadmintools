require "./venue.rb"

faid = ARGV[0].to_i

if venue = Venue.getvenue(faid) then
  puts venue.to_s
else
  puts "Found no venue with id:" + faid.to_s
end
