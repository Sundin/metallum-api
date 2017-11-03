require 'json'
require 'mongo'
require_relative 'band'
require_relative 'album'

class Crawler 
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
    @db = @client.database
    @band_collection = @client[:bands]
    @album_collection = @client[:albums]
    @member_collection = @client[:members]

    def self.browse_bands(letter)
        bands = browse_helper(letter, 0)

        number_of_threads = 8
        chunk_size = (bands.count / number_of_threads) + 1

        bands.each_slice(chunk_size) do |chunk|
            t = Thread.new {
                chunk.each do |band|
                    crawl_band(band['url'])
                end
            }
            t.abort_on_exception = true
        end

        bands
    end

    # Only save the info available from the search results (name, id, url, genre, country, status)
    def self.quick_crawl(letter)
        bands = browse_helper(letter, 0)

        number_of_threads = 8
        chunk_size = (bands.count / number_of_threads) + 1

        bands.each_slice(chunk_size) do |chunk|
            t = Thread.new {
                chunk.each do |band|
                    puts band
                    unless band[:_id].nil?
                         @band_collection.delete_one( { _id: band[:_id] } )
                        #@band_collection.insert_one(band, {})
                    end
                end
            }
            t.abort_on_exception = true
        end

        bands
    end

    def self.crawl_band(url) 
        puts "Crawling " + url
        band_data = Band.show_band_page(Parse.get_body(url))
        save_band(band_data)      
        band_data.to_json
    end

    # TODO: make asynch
    def self.save_band(band_data)
        unless band_data[:_id].nil? 
            @band_collection.delete_one( { _id: band_data[:_id] } )
            @band_collection.insert_one(band_data, {})

            band_data[:discography].each do |album|
                crawl_album(album[:url])
            end

            # TODO:
            # band_data[:members].each do |member|
            #     member_data = Member.show_member_page(Parse.get_body(member['url']))
            #     save_member(member_data)
            # end
        end
    end

    def self.crawl_album(url)
        puts "Crawling " + url
        album_data = Album.show_album_page(Parse.get_body(url))
        save_album(album_data)
        album_data.to_json
    end

    # TODO: make asynch
    def self.save_album(album_data) 
        unless album_data[:_id].nil? 
            @album_collection.delete_one( { _id: album_data[:_id] } )
            @album_collection.insert_one(album_data, {})
        end
    end

    # TODO: make asynch
    def self.save_member(member_data) 
        unless member_data[:_id].nil? 
            @member_collection.delete_one( { _id: member_data[:_id] } )
            @member_collection.insert_one(member_data, {})
        end
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


