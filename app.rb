require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/scraper'

get '/band/:name/:id' do
  name = params['name']
  id = params['id']
  Scraper.getBand(name, id)
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
