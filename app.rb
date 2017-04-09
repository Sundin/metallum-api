require 'json'
require 'nokogiri'
require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/album'
require_relative 'lib/band'
require_relative 'lib/parse'
require_relative 'lib/url'

get '/' do
  'Hello World!'
end

get '/search/band_name/:name' do
  html = Parse.get_json(Url.BAND(params['name']))
  search_results = html["aaData"]

  result_array = []

  search_results.each do |result|
      band = {}

      url = Nokogiri::HTML(result[0]).css('a')
      band["name"] = url.text
      band["url"] = url.xpath('//a/@href')
      band["genere"] = result[1]
      band["country"] = result[2]
      result_array.push(band)
  end

  result_array.to_json
end

get '/band_by_name_and_id/:name/:id' do
  name = params['name']
  id = params['id']
  url =  "http://www.metal-archives.com/bands/" + name + "/" + id
  Band.show_band_page(Parse.get_url(url)).to_json
end

get '/band/:name' do
  html = Parse.get_json(Url.BAND(params['name']))
  direct_link = Nokogiri::HTML(html["aaData"][0][0]).css('a')
  direct_link.map{ |link|
    res = Band.show_band_page(Parse.get_url(link['href']))
    res.to_json
  }
end

get '/album/:band/:name/:id' do
  band = params['band']
  name = params['name']
  id = params['id']
  url =  "http://www.metal-archives.com/albums/" + band + "/" + name + "/" + id
  Album.show_album_page(Parse.get_url(url)).to_json

  # html = Parse.get_json(Url.ALBUM(params['name']))
  # direct_link = Nokogiri::HTML(html["aaData"][0][1]).css('a')
  # direct_link.map{ |link|
  #   res = Album.show_album_page(Parse.get_url(link['href']))
  #   res.to_json
  # }
end

get '/:number' do
  params['number']
end
