#!/usr/bin/env ruby

require 'json'
require 'net/https'
require 'uri'
require 'httpclient'

# kansas city
# city = "kansas_city"
# ul_corner = [39.3220812129387, -94.78935241699219]
# lr_corner = [38.79316214013487, -94.3341064453125]

# city = "eugene"
# ul_corner = [44.177284875914935, -123.26390814268962]
# lr_corner = [43.90581362518504, -122.81484198058024]

city = "ann_arbor"
ul_corner = [42.335667761477616, -83.84191475110129]
lr_corner = [42.18270165738039, -83.54391060071066]


lon_step = 0.016
lat_step = -0.017

type = "grocery_or_supermarket"

current_location = Array.new()
current_location[0] = ul_corner[0]
current_location[1] = ul_corner[1]

count = 0

@client = HTTPClient.new

def query location, type
  url = "https://maps.googleapis.com/maps/api/place/search/json?location=#{location.join(',')}&rankby=distance&key=AIzaSyDE2xjumztSsKAEft86XsfOkP3MsU6NnZE&sensor=false&types=#{type}"

  page = @client.get_content(url)

  json = JSON.parse(page)

  puts json['results'].inspect

  json['results']
end

results = []

while (current_location[0] > lr_corner[0])
  loc_results = query current_location, type
  results << loc_results
  count += 1

  puts current_location.join(", ") #if count % 10 == 0

  current_location[1] += lon_step

  if current_location[1] > lr_corner[1]
    puts "newline " + current_location.join(",")
    current_location[1] = ul_corner[1]
    current_location[0] += lat_step
  end
end

File.open("data/#{city}_google_places_out.json", 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(results.to_json))
end

puts count

# json_filename_pattern = ARGV[0]
# output_filename = "locations.csv"
# 
# files = Dir.glob(json_filename_pattern)
# 
# jsons = []
# 
# files.each do |filename|
#   puts filename
#   file_content = File.open(filename, 'r').read
#   json = JSON.parse(file_content)
#   jsons << json["results"]
# end
# 
# puts jsons.size

def key_for location
  "#{location["id"]}"
end

def address_for location
  "#{location["vicinity"]}".split(",")[0..-2].join(",").strip
end

def city_for location
  "#{location["vicinity"]}".split(",")[-1].strip
end

def state_for location
  "unknown"
  # "#{location["StateProvince"]}".strip
end

def zip_for location
  "unknown"
  # "#{location["PostalCode"]}".strip
end

def lat location
  location["geometry"]["location"]["lat"].to_f
end

def lon location
  location["geometry"]["location"]["lng"].to_f
end

def name_for location
  location["name"]
end

def type
  "grocery"
end

def data_for location
  data = [name_for(location), lat(location), lon(location),
          address_for(location), city_for(location)].join(",")
  data
end

# found_locs = []
# count = 0
# 
# datas = []
# 
# jsons.each_with_index do |json, index|
#   puts index
# 
# json.each do |loc|
#   key = key_for loc
#   if !found_locs.include?(key)
#     found_locs << key
# 
#     datas << data_for(loc)
# 
#     count += 1
#   end
# end
# end
#   puts "uniq: #{count}"
#   puts found_locs.join(", ")
# 
# File.open(output_filename, 'w') do |file|
#   datas.each {|d| file.puts d}
# end
