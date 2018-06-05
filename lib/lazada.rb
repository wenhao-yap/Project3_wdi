require 'mechanize'
require 'json'
require 'byebug'

class LazadaScraper

  # ===================================
  # Initialize all the necessary attributes
  # ===================================
  def initialize
    @url = 'https://www.lazada.sg/catalog/?q='
    @glossary_url = 'https://www.lazada.sg/glossary/'
    @products = []
    @popular_products = []
    @popular_products_to_be_displayed = []
    @product_prices = []
    @popular_products_keys = [:name, :platform]
    @keys = [:id, :name, :price, :availability, :img, :url]
    @search_data = nil
    @avg_price = 0
    @total_items = 0
  end

  # ===================================
  # Scrap out the popular products from lazada glossary
  # ===================================
  def scrap_popular_products
    agent = Mechanize.new

    # Execute the crawling of popular products from lazada glossary page
    page = agent.get(@glossary_url)
    data = Nokogiri::HTML(page.body)
    data.css('.series-container').css('div.wrapper a').each do |product|
      @popular_products << product.content
    end

    # Extract 10 popular products randomly
    10.times do
      popular_product = Hash[@popular_products_keys.map {|x| [x,1]}]
      popular_product[:name] = @popular_products[rand(@popular_products.length-1)]
      popular_product[:platform] = "Lazada"
      @popular_products_to_be_displayed << popular_product
    end
  end

  # ===================================
  # Display popular products
  # ===================================
  def popular_results
    JSON.pretty_generate(@popular_products_to_be_displayed)
  end

  # ===================================
  # Scrap out the necessary product data from lazada based on the query input
  # ===================================
  def scrap(query_input)
    agent = Mechanize.new

    # Execute the crawling
    url = @url + query_input
    page = agent.get(url)

    # Extract the total number of items found for the query_input
    @total_items = agent.page.search("script")[2].text.split('"resultTips":')[1].split(',')[1].split(':')[1].split('"')[1].split(' ')[0]

    # Extract out relevant details regarding product details
    element = agent.page.search("script")[-1]
    @search_data = element.text.split('{"offers":{')[2 .. element.text.length-1]

    extract
  end

  # ===================================
  # Extract out the necessary fields required to be stored into the database
  # ===================================
  def extract
    # Create summarized product details object for all the products crawled & add it to the array
    @search_data.each do |product|
      # Create a new hash with default values 1
      product_details = Hash[@keys.map {|x| [x,1]}]

      # Populate hash with the appropriate values
      product_details[:id] = @products.length + 1
      product_details[:name] = product.split(',')[6].split(':')[1].split('"')[1]
      product_details[:price] = product.split(',')[0].split(':')[1].split('"')[1] + " " + product.split(',')[2].split(':')[1].split('"')[1]
      product_details[:availability] = product.split(',')[3].split('":"')[1].split('"}')[0].split('/')[3]
      product_details[:img] = product.split(',')[4].split('":"')[1].split('"')[0]
      if product_details[:id] != 39
        product_details[:url] = product.split(',')[7].split('":"')[1]
      else
        product_details[:url] = product.split(',')[7].split('":"')[1].split('"}]}')[0]
      end

      # Push populated hash into the array
      @products << product_details
    end

    @products.each do |product|
      if product[:url] == nil
      elsif product[:url].include? '"}'
        product[:url] = product[:url].split('"}')[0]
      end
    end
  end

  # ===================================
  # Display the results to the web page
  # ===================================
  def results
    JSON.pretty_generate(@products)
    # puts "Product details => #{JSON.pretty_generate(@products)}"
  end

  # ===================================
  # Get the total number of items found for the search query
  # ===================================
  def total_results
    @total_items
    # puts "\n#{@total_items} items found..."
  end

  # ===================================
  # Get the average price based on 30 products
  # ===================================
  def average_price
    @products.each do |product|
      price = product[:price].split(" ")[1]
      @product_prices << price
    end

    total_price = 0
    @product_prices.each do |price|
      total_price += price.to_f
    end
    @avg_price = total_price/@product_prices.length
    @avg_price = "SGD " + "%.2f" % @avg_price
    # puts "Average price => #{@avg_price}"
  end

  # ===================================
  # Get the top 10 cheapest products
  # ===================================
  def cheapest_products
    top_products = @products.sort_by { |hsh| hsh[:price] }

    JSON.pretty_generate(top_products[0 .. 9])
    # puts "Best Seller products => #{JSON.pretty_generate(top_products[0 .. 9])}"
  end
end


# ===================================
# Execution
# ===================================
# lazada = LazadaScraper.new
# lazada.scrap_popular_products
# puts "10 Popular Products => #{lazada.scrap_popular_products}"
# lazada.scrap('pencil')
# lazada.average_price
# lazada.total_results
# lazada.cheapest_products
