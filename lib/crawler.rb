require 'json'
require_relative 'band'
require_relative 'album'

class Crawler     
    def self.crawl_band(url) 
        puts "Crawling " + url
        band_data = Band.show_band_page(Parse.get_body(url))    
        band_data.to_json
    end

    def self.crawl_album(url)
        puts "Crawling " + url
        album_data = Album.show_album_page(Parse.get_body(url))
        album_data.to_json
    end

    # Only save the info available from the search results (name, id, url, genre, country, status)
    def self.browse_bands(letter)
        bands = browse_helper(letter, 0)

        number_of_threads = 8
        chunk_size = (bands.count / number_of_threads) + 1

        bands.each_slice(chunk_size) do |chunk|
            t = Thread.new {
                chunk.each do |band|
                    puts band
                end
            }
            t.abort_on_exception = true
        end

        bands
    end
    
    def self.browse_helper(letter, display_start)
        display_length = 500

        url = "https://www.metal-archives.com/browse/ajax-letter/l/" +
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
            url = Nokogiri::HTML(result[0]).css('a')
            band_url = url[0]['href']
            splitted_url = band_url.split('/')

            band = {
                band_name: url.text,
                url: band_url,
                _id: splitted_url[splitted_url.length-1],
                country: result[1],
                genre: result[2],
                status: Nokogiri::HTML(result[3]).css('span').text
            }
            result_array.push(band)
        end

        result_array
    end
end


