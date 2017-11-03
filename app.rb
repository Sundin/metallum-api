require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'mongo'
require_relative 'lib/crawler'
require_relative 'lib/searcher'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database


### CRAWLING ###

get '/crawl/:letter' do
  # a - z, NBR, ~ 
  letter = params['letter']
  bands = Crawler.browse_bands(letter)
  puts bands.count
  bands.to_json
end

get '/quick_crawl/:letter' do
  letter = params['letter']
  bands = Crawler.quick_crawl(letter)
  puts bands.count
  bands.to_json
end

get '/crawl/band/:name/:id' do
  name = params['name']
  id = params['id']

  url = "https://www.metal-archives.com/bands/" + name + "/" + id
  Crawler.crawl_band(url)
end


### BANDS ###

get '/band/:name/:id' do
  id = params['id']
  collection = client[:bands]
  band = collection.find( { _id: id} ).first

  if band.nil?
    puts "Not found in database, fetching from Metal Archives instead"
    name = params['name']
    url = "https://www.metal-archives.com/bands/" + name + "/" + id
    Crawler.crawl_band(url)
  else
    band.to_json
  end
end

get '/band/:id' do
  id = params['id']
  collection = client[:bands]
  band = collection.find( { _id: id} ).first

  band.to_json
end


### ALBUMS ###

get '/album/:band/:title/:id' do
  id = params['id']
  collection = client[:albums]
  album = collection.find( { _id: id} ).first

  if album.nil?
    band = params['band']
    title = params['title']
    url = "https://www.metal-archives.com/albums/" + band + "/" + title + "/" + id
    Crawler.crawl_album(url)
  else
    album.to_json
  end
end

get '/album/:id' do
  id = params['id']
  collection = client[:albums]
  album = collection.find( { _id: id} ).first

  album.to_json
end


#### SEARCH ###

get '/search/band_name/:band_name' do
  band_name = params['band_name']
  
  search_results = Searcher.search_bands(band_name)

  result = {
    search_results: search_results,
    query: band_name
  }

  result.to_json
end

get '/search/album_name/:title' do
  title = params['title']
  Scraper.searchAlbum(title)
end
