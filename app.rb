require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'mongo'
require_relative 'lib/scraper'


client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
db = client.database

get '/' do
  puts db.collection_names
end

get '/band/:name/:id' do
  name = params['name']
  id = params['id']
  band = Scraper.getBand(name, id)

  collection = client[:bands]
  collection.update_one(band, {})

  band.to_json
end

get '/album/:band/:title/:id' do
  band = params['band']
  title = params['title']
  id = params['id']
  Scraper.getAlbum(band, title, id)
end

get '/search/band_name/:name' do
  name = params['name']
  Scraper.searchBand(name)
end

get '/search/album_name/:title' do
  title = params['title']
  Scraper.searchAlbum(title)
end
