require 'json'
require_relative 'scraper'

class Crawler 
    def self.browse(letter)
        browse_helper(letter, 0)
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
        if display_start + display_length < total_records
            list1 = JSON.parse(parse_band_list(json['aaData'])) 
            list2 = JSON.parse(browse_helper(letter, display_start + display_length))
            
            list1.each do |b|
                list2 << b
            end
            list2.to_json
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
            band["id"] = splitted_url[splitted_url.length-1]

            # band["country"] = result[1]
            # band["genre"] = result[2]
            result_array.push(band)
        end

        result_array.to_json
    end
end


