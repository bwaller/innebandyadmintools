require "./venue.rb"

redis = Redis.new

id = ARGV[0].to_i
name = ARGV[1].to_s
streetaddress = ARGV[2].to_s
postal_code = ARGV[3].to_s
locality = ARGV[4].to_s

json_str = [name, streetaddress, postal_code, locality].to_json
puts json_str

redis.set(id, json_str)
