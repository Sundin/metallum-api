require 'nokogiri'

class Album

  def self.show_album_page(html)
    page = Nokogiri::HTML(html)

    url = page.css("h1[class=album_name] a")[0]['href'] unless page.css("h1[class=album_name] a").empty?
    if url == nil 
      return {}
    end

    splitted_url = url.split('/')
    id = splitted_url[splitted_url.length-1]

    album_title = page.css("h1[class=album_name] a")[0].text

    album_values = {}
    page.css('div#album_info').search('dt').each do |node|
      if node.text == 'Label:'
        label_url = node.next_element.css('a')[0]['href'] unless node.next_element.css('a').empty?
        if label_url != nil 
          splitted_url = label_url.split('/') 
          split_again = splitted_url[splitted_url.length-1].split('#')  
          label_id = split_again[0]
        end
        
        label = {
          _id: label_id,
          name: node.next_element.text
        }
        album_values['Label:'] = label
      else      
        album_values[node.text] = node.next_element.text
      end
    end

    songs = []
    page.css('table.table_lyrics').search('td.wrapWords').each do |element|
      title = element.text.strip || element.text
      length = element.next_element.content
      song = {
        title: title.tr("\n", "").tr("\t", ""),
        length: length
      }
      songs.push song
    end

    cover_url = page.css("a.image#cover")[0]['href'] unless page.css("a.image#cover").empty?

    lineup = get_lineup(page)

    bands = []
    page.css('h2.band_name a').each do |element|
      url = element['href']
      splitted_url = url.split('/')
      band_id = splitted_url[splitted_url.length-1]
      band = {
        _id: band_id,
        name: element.text
      }
      bands.push band
    end

    album = {
      _id: id,
      title: album_title,
      bands: bands,
      type: album_values['Type:'],
      release_date: album_values['Release date:'],
      catalog_id: album_values['Catalog ID:'],
      label: album_values['Label:'],
      format: album_values['Format:'],
      limitation: album_values['Limitation:'],
      songs: songs,
      cover_url: cover_url,
      year: album_values['Release date:'][-4..-1].to_i || nil,
      lineup: lineup.to_a
    }
    # TODO: reviews

    album
  end

  def self.get_lineup(page)
    members = []
    page.css('div#album_members tr.lineupRow').each do |memberRow|
      url = memberRow.css('a')[0]['href']
      splitted_url = url.split('/')
      id = splitted_url[splitted_url.length-1]

      member = {
        _id: id,
        name: memberRow.css('a').text,
        instrument: memberRow.css('td')[1].text.tr("\n", "").tr("\t", "")
      }
      
      members.push member
    end
    members.to_set # Ugly work around to get rid of duplicates
  end

  def self.show_album_reviews(res)
    reviews = []
    review = {}
    links = []
    album_keys = {0 => "year", 1 => "name", 2 => "role"}
    a = 0
    # res.css("td[nowrap=nowrap] a").each do |link|
    #   links.push link['href']
    # end
    res.css("td[nowrap=nowrap]").remove
    res.css("td").each_with_index do |item, index|
      p item.content
      # review[album_keys[index]] = item.content.strip.split.join " "
      # if (index + 4) % 4 == 3
      #   reviews.push review
      #   review = {}
      # end
    end
    reviews
    # show_album_review links[choice.to_i - 1]
  end

  def self.show_album_review(url)
    page = Nokogiri::HTML Client.get_url url
    puts "\n"
    puts page.css('h3.reviewTitle').first.content.strip.split.join " "
    puts "\n"
    puts page.css('a.profileMenu').first.parent.content.strip.split.join " "
    puts "\n"
    puts page.css('div.reviewContent').first.content.strip.split.join " "
    puts "\n"
  end
end
