require 'open-uri'
require 'json'

class Parse
  
  def self.get_body(url)
    uri = URI.escape(url)
    URI.parse(uri).read
  end

  def self.get_json(url)
    data = URI.parse(url).read
    JSON.parse(data)
  end
  
  def self.format_array(arr, indexes)
    unique = indexes.length
    formatted = []
    aux = []
    arr.each_with_index do |e, i|
      aux.push e
      if(i > 0 && i % unique == unique-1)
        # aux[-1] += "\n\n"
        formatted.push aux
        aux = []
      end
    end
    formatted
  end
  
end