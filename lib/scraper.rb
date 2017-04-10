require 'json'
require 'nokogiri'
require_relative 'album'
require_relative 'band'
require_relative 'parse'
require_relative 'url'

class Scraper 
    def self.getBand(name, id)
        url = "http://www.metal-archives.com/bands/" + name + "/" + id
        Band.show_band_page(Parse.get_url(url))
    end

    def self.getAlbum(band, title, id)
        url = "http://www.metal-archives.com/albums/" + band + "/" + name + "/" + id
        Album.show_album_page(Parse.get_url(url))
    end

    def self.searchBand(name)
        html = Parse.get_json(Url.BAND(name))
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

    def self.searchAlbum(title)
        html = Parse.get_json(Url.ALBUM(title))
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
end
