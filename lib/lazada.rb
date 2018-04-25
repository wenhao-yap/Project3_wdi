require 'mechanize'
require 'json'
require 'byebug'

class LazadaScraper

  # ===================================
  # Initialize all the necessary attributes
  # ===================================
  def initialize(query_input)
    @input = query_input
    @url = 'https://www.lazada.sg/catalog/?q='
    @products = []
    @keys = [:id, :name, :price, :availability, :image, :url]
    @search_data = nil
  end

  # ===================================
  # Scrap out the necessary product data from lazada
  # ===================================
  def scrap
    agent = Mechanize.new

    # Execute the crawling
    url = @url + @input
    page = agent.get(url)

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
      product_details[:image] = product.split(',')[4].split('":"')[1].split('"')[0]
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
  # Get the number of products scraped
  # ===================================
  def total_results
    @products.count
    # puts "\n#{@products.count} products found..."
  end

  # ===================================
  # Get the top 10 cheapest products
  # ===================================
  def cheapest_products
    top_products = @products.sort_by { |hsh| hsh[:price] }

    JSON.pretty_generate(top_products[0 .. 10])
    # puts "Best Seller products => #{JSON.pretty_generate(top_products[0 .. 10])}"
  end
end

# ===================================
# Execution
# ===================================
# lazada = LazadaScraper.new('pencil')
# lazada.scrap
# lazada.total_results
# lazada.cheapest_products
