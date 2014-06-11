#!/usr/bin/env ruby

require 'json'

json_filename_pattern = ARGV[0]
output_filename = "locations.tsv"

files = Dir.glob(json_filename_pattern)

jsons = []

files.each do |filename|
  puts filename
  file_content = File.open(filename, 'r').read
  json = JSON.parse(file_content)
  jsons << json.flatten
end

puts jsons.size

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
          address_for(location), city_for(location)].join("\t")
  data
end

def headers
  ["name", "lat", "lon", "address", "city"]
end

found_locs = []
count = 0

datas = []

jsons.each_with_index do |json, index|
  puts index

json.each do |loc|
  key = key_for loc
  if !found_locs.include?(key)
    found_locs << key

    datas << data_for(loc)

    count += 1
  end
end
end
  puts "uniq: #{count}"
  puts found_locs.join(", ")

File.open(output_filename, 'w') do |file|
  file.puts headers.join("\t")
  datas.each {|d| file.puts d}
end
