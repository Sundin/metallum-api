class Album

  def self.show_album_page(html)
    page = Nokogiri::HTML(html)

    puts page

    album_values = {}
    album_keys = {0 => "type", 1 => "release", 2 => "catalog_id", 3 => "label", 4 => "format", 5 => "limitation", 6 => "reviews"}
    page.css('div#album_info dd').each_with_index do |item, index|
      album_values[album_keys[index]] = item.content.strip.split.join " "
    end
    album_values['reviews'] = show_album_reviews page.css('table#review_list')
    album_values

    url = page.css("h1[class=album_name] a")[0]['href']
    splitted_url = url.split('/')
    id = splitted_url[splitted_url.length-1]

    album = {
      _id: id,
      type: album_values['type'],
      release: album_values['release'],
      catalog_id: album_values['catalog_id'],
      label: album_values['label'],
      format: album_values['format'],
      limitation: album_values['limitation'],
      reviews: album_values['reviews']
    }

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
