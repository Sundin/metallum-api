require 'sinatra'
require 'sinatra/reloader'
require 'json'
require_relative 'lib/crawler'

### CRAWLING ###

# Letters: A-Z, #, ~
get '/browse_bands/:letter' do
  letter = params['letter']
  bands = Crawler.browse_bands(letter)
  bands.to_json
end


### BANDS ###

get '/bands/:name/:id' do
  name = params['name']
  id = params['id']
  url = "https://www.metal-archives.com/bands/" + name + "/" + id
  Crawler.crawl_band(url)
end


### ALBUMS ###

get '/albums/:band/:title/:id' do
  band = params['band']
  title = params['title']
  id = params['id']
  url = "https://www.metal-archives.com/albums/" + band + "/" + title + "/" + id
  url = url.tr(" ", "_")
  Crawler.crawl_album(url)
end


#### SEARCH ###

get '/search/album_name/:title' do
  title = params['title']
  Scraper.searchAlbum(title)
end
