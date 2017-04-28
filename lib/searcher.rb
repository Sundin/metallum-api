require 'json'
require 'mongo'

class Searcher 
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'test')
    @db = @client.database
    @band_collection = @client[:bands]
    @album_collection = @client[:albums]

    # You need to run this command in mongo for the search to work:
    # db["bands"].createIndex( { band_name: "text" } )
    def self.search_bands(band_name)
        result_array = []

        @band_collection.find({ '$text' => { '$search' => band_name, '$caseSensitive' => false } } ).each do |result|
            band = {
                band_name: result[:band_name],
                _id: result[:_id],
                country: result[:country],
                genre: result[:genre]
            }
            result_array.push(band)
        end

        result_array
    end    
end
