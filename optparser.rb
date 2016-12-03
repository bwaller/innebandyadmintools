require 'optparse'
require 'ostruct'
options = OpenStruct.new
options.venue_id = nil
options.title = ""

OptionParser.new do |opts|
  opts.banner = "Usage: optparser.rb -i venueid [-th]"

  opts.on("-i", "--venueid id", Integer, "venue id") do |i|
    options.venue_id = i
  end

  opts.on("-t", "--title title", "Title annoted on schedule") do |t|
    options.title = t
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

p options.venue_id
p options.title
p ARGV

