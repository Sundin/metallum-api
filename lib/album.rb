class Album

  def self.show_album_page(html)
    page = Nokogiri::HTML(html)

    url = page.css("h1[class=album_name] a")[0]['href'] unless page.css("h1[class=album_name] a").empty?
    if url == nil 
      return {}
    end

    splitted_url = url.split('/')
    id = splitted_url[splitted_url.length-1]

    title = page.css("h1[class=album_name] a")[0].text

    album_values = {}
    page.css('div#album_info').search('dt').each do |node|
      album_values[node.text] = node.next_element.text
    end

    songs = []
    page.css('table.table_lyrics').search('td.wrapWords').each do |element|
      title = element.text.strip || element.text
      song = {
        title: title.tr("\n", "").tr("\t", "")
      }
      songs.push song
    end

    cover_url = page.css("a.image#cover")[0]['href'] unless page.css("a.image#cover").empty?

    album = {
      _id: id,
      title: title,
      type: album_values['Type:'],
      release_date: album_values['Release date:'],
      catalog_id: album_values['Catalog ID:'],
      label: album_values['Label:'],
      format: album_values['Format:'],
      limitation: album_values['Limitation:'],
      songs: songs,
      cover_url: cover_url,
      year: album_values['Release date:'][-4..-1].to_i || nil
    }
    # TODO: lineup, reviews, song lengths, band(s)

    album
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
