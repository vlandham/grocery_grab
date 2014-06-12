#!/usr/bin/env ruby

require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'iconv'

STORE = "ALDI"
store_id = "198"

start_url = "http://www.mystore411.com/store/listing/#{store_id}/#{STORE}-store-locations"

output_filename = "data/#{STORE}_data.json"

@agent = Mechanize.new

stores = Array.new

def get_links root_page
  parser = root_page.parser
  links = parser.css("#main .table1 td a")
end

def get_store link
  puts 'store'
  page = nil
  page_data = {}
  begin
    page = @agent.get(link['href'])
  ps = page.parser.css('.store-details p')
  page_data['store'] = STORE
  if ps and ps[0]
    page_data['address'] = ps[0].text.strip
  else
    puts "ERROR no address: #{link['href']}"
  end
  rescue => e
    puts "EROR"
    
  end
  page_data
end

def get_state link
  puts 'state'
  page = nil
  begin
    page = @agent.get(link['href'])
  rescue => e
    get_state link
  end
  state_data = []
  city_links = get_links page
  city_links.each do |link|
    state_data.push(get_store(link))
  end
  state_data
end

root_page = @agent.get(start_url)
state_links = get_links root_page

state_links.each do |link|
  puts link
  if link['href'] =~ /list_city/
    next
  elsif link['href'] =~ /list_state/
    stores.concat(get_state(link))
  else
    stores.push(get_store(link))
  end
end

File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(stores.to_json))
end


