require 'json'
require 'mongo'
require_relative 'scraper'
require_relative 'band'

class Crawler 
    def self.browse_bands(letter)
        client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
        db = client.database
        collection = client[:bandz]

        bands = browse_helper(letter, 0)
        bands.each do |band|
            band_data = Band.show_band_page(Parse.get_url(band['url']))

            unless band_data[:_id].nil? 
                collection.delete_one( { _id: band_data[:_id] } )
                collection.insert_one(band_data, {})
            end
        end
    end
    
    def self.browse_helper(letter, display_start)
        display_length = 500

        url = "http://www.metal-archives.com/browse/ajax-letter/l/" +
        letter +
        "/json/1?sEcho=9&iColumns=4&sColumns=&" + 
        "iDisplayStart=" + display_start.to_s + 
        "&iDisplayLength=" + display_length.to_s +
        "&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3" +
        "&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true" +
        "&bSortable_1=true&bSortable_2=true&bSortable_3=false&_=1492067396329"

        json = Parse.get_json(url)
        total_records = json['iTotalRecords']
        last_band = display_start + display_length
        puts "Fetching bands " + display_start.to_s + "-" + last_band.to_s + " out of " + total_records.to_s + " for letter " + letter

        if display_start + display_length < total_records
            list1 = parse_band_list(json['aaData'])
            list2 = browse_helper(letter, last_band)
            
            list1.each do |b|
                list2 << b
            end

            list2
        else 
            parse_band_list(json['aaData'])
        end
    end

    def self.parse_band_list(bands)
        result_array = []

        bands.each do |result|
            band = {}

            url = Nokogiri::HTML(result[0]).css('a')
            band["name"] = url.text

            band["url"] = url[0]['href']
            splitted_url = band["url"].split('/')
            band["_id"] = splitted_url[splitted_url.length-1]

            # band["country"] = result[1]
            # band["genre"] = result[2]
            result_array.push(band)
        end

        result_array
    end
end


