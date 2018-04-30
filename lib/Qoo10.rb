require 'mechanize'
require 'json'

class Qoo10Scraper

	def initialize(input)
		@input = input
		@agent = Mechanize.new { |agent|
			aliases = ['Windows Firefox', 'Windows Chrome', 'Mac Safari']
			#prevent blacklist by randoming selecting browser
			agent.user_agent_alias = aliases.sample
		}
		@searchData = ''
		@product_prices = []
		@avg_price = 0
		@total_items = 0
	end

	# ===================================
	# BestSellers
	# ===================================

	def bestSellers
		data = Nokogiri::HTML(homePage.body)
		items = data.css('#div_bestseller').css('li[group_code="0"]')
		output = items.each_with_index.map { |item, i|
			{
				id: i+1,
				img: item.css('img').attr('gd_src'),
				name: item.css('img').attr('alt'),
				price: item.css('strong').text
			}
		}
		JSON.pretty_generate(output)
	end

	# ===================================
	# Search Results
	# ===================================

	# submit search on home page to prevent blacklist
	def search
		searchForm = homePage.form(:action => "https://www.qoo10.sg/gmkt.inc/Search/Default.aspx")
		searchForm.field_with(:name => "keyword").value = @input
		searchPage = @agent.submit(searchForm)
		@searchData = Nokogiri::HTML(searchPage.body)
	end

	# Get the search results in JSON format
	def results
		items = @searchData.css('tbody > tr')
		output = items[0..9].each_with_index.map { |item, i|
			{
				id: i+1,
				name: item.css('.sbj').text,
				price: item.css('.prc > strong').text,
				url: item.css('.lnk_vw').attr('href'),
				img:  item.css('.td_thmb> .inner > a > img').attr('gd_src')
			}
		}
		JSON.pretty_generate(output)
	end

	# Get the total number of items found based on the search query
	def total_results
		results = @searchData.css('li.itm a').text
		total_items_found = results.split('Store Pickup')[0].split(':')[1].split('')[1..-1]
		total_items_string = ''
		total_items_found.each do |item|
			next if item == ','
			total_items_string.concat(item)
		end
		@total_items = total_items_string.to_i
		return @total_items
		# puts "Total items found => #{@total_items}"
		# puts "Is total items an integer => #{@total_items.is_a?(Integer)}"
	end

	# Get the average price of all items found
	def average_price(results)
		results = JSON.parse(results, object_class: OpenStruct)

		results.each do |result|
			price = result["price"].split('$')[1].to_f
			@product_prices << price
		end

		total_price = 0
    @product_prices.each do |price|
      total_price += price
    end
    @avg_price = total_price/@product_prices.length
    @avg_price = "SGD " + "%.2f" % @avg_price
    # puts "Average price => #{@avg_price}"
	end

	# Get the total number of sellers selling searched item
	def totalSellers
		total = @searchData.css('#div_global_domestic_tab').css('span')[0].text
		total = total.gsub(/[^\d\.]/, '')
	end

	private
	def homePage
		page = @agent.get('https://www.qoo10.sg/')
	end
end

# ===================================
# Execution
# ===================================
# qoo10 = Qoo10Scraper.new('pencil')
# qoo10.search
# qoo10.average_price(qoo10.results)
# qoo10.total_results
# puts qoo10.bestSellers
