
require 'open-uri'
require 'json'
class Scraper
  attr_reader :sale_page_1, :sale_page_2, :rent_page_1, :rent_page_2
  attr_accessor :html_1, :html_2, :html_3, :html_4

  def initialize
    @sale_page_1 = "http://streeteasy.com/for-sale/soho?sort_by=price_desc"
    @sale_page_2 = "http://streeteasy.com/for-sale/soho?page=2&sort_by=price_desc"
    @rent_page_1 = "http://streeteasy.com/for-rent/soho?sort_by=price_desc"
    @rent_page_2 = "http://streeteasy.com/for-rent/soho?page=2&sort_by=price_desc"
    @html_1 = Nokogiri::HTML(open(sale_page_1))
    @html_2 = Nokogiri::HTML(open(sale_page_2))
    @html_3 = Nokogiri::HTML(open(rent_page_1))
    @html_4 = Nokogiri::HTML(open(rent_page_2))
  end

  def fetch_data(html)
    doc = html
    collection = []

    doc.css('.left-two-thirds > div').map do |data|
        hash = {listing_class: "", address: "", unit: "", url: "", price: ""}
        hash[:listing_class] = listing_class(data)
        hash[:address] = address(data)
        hash[:unit] = unit(data)
        hash[:url] = url(data)
        hash[:price] = price(data)
      collection << hash

    end
    collection
  end

  def url(data)
    unless data.css('.details > .details-title > a[href]')[0] == nil
      data.css('.details > .details-title > a[href]')[0].attributes["href"].value
      relative = data.css('.details > .details-title > a[href]')[0].attributes["href"].value
      absolute = "http://streeteasy.com/nyc#{relative}"
      absolute
    end
  end

  def featured_check(data)
    if url(data).include?("featured")
      false
    end
  end

  def listing_class(data)
    unless data.css('.details > .details-title > a[href]')[0] == nil
      data.css('.details > .details-title > a[href]')[0].attributes["data-gtm-listing-type"].value.capitalize
    end
  end

  def address(data)
    data.css('.details > .details-title > a[href]').text
  end

  def unit(data)
    if data.css('.details > .details-title > a').text.include?("#")
      data.css('.details > .details-title > a').text.split("#")[1]
    else
      "unavailable for this listing"
    end
  end

  def price(data)
    data.css('.details > .price-info > .price').text.gsub(/[$,]/, "")
  end

  def self.sale_data
    scraper = Scraper.new
    data_set_1 = scraper.fetch_data(scraper.html_1)
    data_set_2 = scraper.fetch_data(scraper.html_2)
    data_set_1.shift(2)
    data_set_1.pop(3)
    data_set_2.shift(2)
    data_set_2.pop(3)
    merged = data_set_1 << data_set_2
    combined = merged.flatten[0...20]
    puts "Top 20 Most Expensive Properties for Sale in SoHo"
    puts JSON(combined)
  end

  def self.rent_data
    scraper = Scraper.new
    data_set_1 = scraper.fetch_data(scraper.html_3)
    data_set_2 = scraper.fetch_data(scraper.html_4)
    data_set_1.shift(2)
    data_set_1.pop(3)
    data_set_2.shift(2)
    data_set_2.pop(3)
    merged = data_set_1 << data_set_2
    combined = merged.flatten[0...20]
    puts "Top 20 Most Expensive Rental Properties in SoHo"
    puts JSON(combined)
  end
end
