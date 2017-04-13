require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'mongo'
require_relative 'lib/scraper'
require_relative 'lib/crawler'

client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database

get '/:letter' do
  # a - z, NBR, ~ 
  letter = params['letter']
  bands = Crawler.browse_bands(letter)
  puts bands.count
  bands.to_json
end

get '/band/:name/:id' do
  name = params['name']
  id = params['id']
  band = Scraper.getBand(name, id)

  collection = client[:bands]
  collection.delete_one( { _id: id } )
  collection.insert_one(band, {}) 

  band.to_json
end

get '/band/:id' do
  id = params['id']
  collection = client[:bandz]
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

get '/search/band_name/:name' do
  name = params['name']
  Scraper.searchBand(name)
end

get '/search/album_name/:title' do
  title = params['title']
  Scraper.searchAlbum(title)
end
