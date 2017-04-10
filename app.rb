require 'json'
require 'nokogiri'
require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/album'
require_relative 'lib/band'
require_relative 'lib/parse'
require_relative 'lib/url'

get '/band/:name/:id' do
  name = params['name']
  id = params['id']
  url = "http://www.metal-archives.com/bands/" + name + "/" + id
  Band.show_band_page(Parse.get_url(url)).to_json
end

get '/album/:band/:name/:id' do
  band = params['band']
  name = params['name']
  id = params['id']
  url = "http://www.metal-archives.com/albums/" + band + "/" + name + "/" + id
  Album.show_album_page(Parse.get_url(url)).to_json
end

get '/search/band_name/:name' do
  html = Parse.get_json(Url.BAND(params['name']))
  search_results = html["aaData"]

  result_array = []

  search_results.each do |result|
      band = {}

      url = Nokogiri::HTML(result[0]).css('a')
      band["name"] = url.text

      band["url"] = url[0]['href']
      splitted_url = band["url"].split('/')
      band["id"] = splitted_url[splitted_url.length-1]

      band["genre"] = result[1]
      band["country"] = result[2]
      result_array.push(band)
  end

  result_array.to_json
end

get '/search/album_name/:name' do
  html = Parse.get_json(Url.ALBUM(params['name']))
  search_results = html["aaData"]
  result_array = []

  search_results.each do |result|
      album = {}

      band = Nokogiri::HTML(result[0]).css('a')
      if band.length > 1 
        # Split release
        album["band"] = []
        band.each do |band|
          album["band"].push band.text
        end
      else 
        album["band"] = Nokogiri::HTML(result[0]).css('a').text
      end

      url = Nokogiri::HTML(result[1]).css('a')
      album["url"] = url[0]['href']
      album["title"] = url.text

      splitted_url = album["url"].split('/')
      album["id"] = splitted_url[splitted_url.length-1]

      album["type"] = result[2]

      temp = result[3].split('<!-- ')[1]
      releaseDate = temp.split(' -->')[0]
      album["release_date"] = releaseDate

      result_array.push(album)
  end

  result_array.to_json
end
