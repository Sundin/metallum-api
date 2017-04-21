require 'nokogiri'
require_relative 'parse'

class Band

  def self.show_band_page(html)
    page = Nokogiri::HTML(html)

    band_keys = {0 => "country", 1 => "location", 2 => "status", 3 => "active_since", 4 => "genre", 5 => "themes", 6 => "label", 7 => "years_active"}
    band_values = {}
    members = {}

    page.css('div#band_stats dd').each_with_index do |item, index|
      band_values[band_keys[index]] = item.content.strip.split.join " "
    end

    page.css("div#band_disco ul li:eq(1) a").map { |link|
      band_values['discography'] = show_band_discography link['href']
    }

    members['current'] = show_band_members page, "current"
    members['past'] = show_band_members page, "past"
    members['live'] = show_band_members page, "live"
    band_values['members'] = members

    page.css("div#band_tab_discography").map do |prev_elem|
      prev_elem.previous_element.css('li:eq(4) a').map do |link|
        band_values['similar'] = show_similar_bands "#{link['href']}?showMoreSimilar=1"
      end
    end

    page.css("div#band_tab_discography").map do |prev_elem|
      prev_elem.previous_element.css('li:eq(5) a').map do |link|
        band_values['links'] = show_band_links link['href']
      end
    end

    photo_url = page.css('a[id=photo]').first.attr('href') unless page.css('a[id=photo]').empty?
    logo_url = page.css('a[id=logo]').first.attr('href') unless page.css('a[id=logo]').empty?

    band_name = page.css("h1[class=band_name]")[0].text

    url = page.css("h1[class=band_name] a")[0]['href']
    splitted_url = url.split('/')
    id = splitted_url[splitted_url.length-1].to_i

    band = {
      band_name: band_name,
      _id: id,
      country: band_values["country"],
      location: band_values["location"],
      status: band_values["status"],
      active_since: band_values["active_since"],
      genre: band_values["genre"],
      themes: band_values["themes"],
      label: band_values["label"],
      years_active: band_values["years_active"],
      url: url,
      photo_url: photo_url,
      logo_url: logo_url,
      members: members,
      discography: band_values["discography"],
      links: band_values["links"],
      similar: band_values["similar"]
    }

    band
  end

  def self.show_band_discography(url)
    res = Nokogiri::HTML Parse.get_url url
    discography = []
    discog_keys = {0 => "name", 1 => "type", 2 => "year", 3 => "reviews"}
    album_numer = 0
    res.css('tbody tr').each do |album|
      disc = {}
      album.css('td').map.with_index do |item, index|        
        disc[discog_keys[index]] = item.content.strip.split.join " "
      end
      url = album.css('a').first.attr('href') unless album.css('a').empty?
      splitted_url = url.split('/')
      disc['url'] = url
      disc['_id'] = splitted_url[splitted_url.length-1]
      discography.push disc
      album_numer = album_numer + 1
    end
    discography
  end

  def self.show_band_members(page, type)
    members = []
    member = {}
    member_keys = {0 => "name", 1 => "instrument"}
    page.css("div#band_tab_members_#{type} div table tr.lineupRow td").each_with_index do |item, i|
      member[member_keys[((i+2)%2)]] = item.content.strip.split.join " "
      if (i+2)%2 == 1
        members.push member
        member = {}
      end
    end
    members
  end

  def self.show_similar_bands(url)
    res = Nokogiri::HTML Parse.get_url url
    bands, band = [], {}
    band_keys = {0 => "name", 1 => "country", 2 => "genre", 3 => "score"}
    res.css('tbody tr td').each_with_index do |item, i|
      band[band_keys[((i+4)%4)]] = item.content.strip.split.join " "
      if (i+4)%4 == 3
        bands.push band
        band = {}
      end
    end
    bands
  end

  def self.show_band_links(url)
    res = Nokogiri::HTML Parse.get_url url
    links, link = [], {}
    res.css("table tr td a").each_with_index do |item, i|
      link[item['title'].gsub("Go to: ", "").tr("§", "").tr(".", " ")] = item['href']
      links.push link
      link = {}
    end
    links
  end

end
