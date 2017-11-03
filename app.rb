require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'mongo'
require_relative 'lib/scraper'
require_relative 'lib/crawler'
require_relative 'lib/searcher'


client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database


##### On startup: ######
# bands = Crawler.browse_bands('r')
########################


get '/crawl/:letter' do
  # a - z, NBR, ~ 
  letter = params['letter']
  bands = Crawler.browse_bands(letter)
  puts bands.count
  bands.to_json
end

get '/crawl/band/:name/:id' do
  name = params['name']
  id = params['id']

  url = "https://www.metal-archives.com/bands/" + name + "/" + id
  Crawler.crawl_band(url)
end

get '/band/:id' do
  id = params['id']
  collection = client[:bands]
  band = collection.find( { _id: id} ).first

  band.to_json
end

get '/album/:band/:title/:id' do
  band = params['band']
  title = params['title']
  id = params['id']
  album = Scraper.getAlbum(band, title, id)

  collection = client[:albums]
  collection.update_one(album, {})

  album.to_json
end

get '/album/:id' do
  id = params['id']
  collection = client[:albums]
  album = collection.find( { _id: id} ).first

  album.to_json
end

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
