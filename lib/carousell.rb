require 'mechanize'
require 'json'

class CarousellScraper

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
	end

	# ===================================
	# BestSellers
	# ===================================

	def bestSellers
		url = 'https://sg.carousell.com/special/recommended-sellers/'
		page = @agent.get(url)
		data = Nokogiri::HTML(page.body)
		items = data.css('.q-_a')
		output = items[0..9].each_with_index.map { |item, i|
			{
				id: i+1,
				name: item.css('.q-l').text
			}
		}
		JSON.pretty_generate(output)
	end

	# ===================================
	# Search Results
	# ===================================

	def scrap
		url = 'https://sg.carousell.com/search/products/?query=' + @input
    	page = @agent.get(url)
		@searchData = Nokogiri::HTML(page.body)
	end

	def results
		items = @searchData.css('.e-_a > div')
		output = items[0..9].each_with_index.map { |item, i|
			url = 'https://sg.carousell.com'
			{
				id: i+1,
				name: item.css('.q-l').text,
				price: item.css('dd')[0].text,
				url: url + item.css('.q-e').attr('href'),
				img:  item.css('img')[1].attr('src')
			}
		}
		JSON.pretty_generate(output)
	end

	def average_price
		JSON.parse(results, object_class: OpenStruct).each do |result|
			price = result["price"].split('S$')[1].to_f
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
end

# ===================================
# Sample Execution
# ===================================
# carousell = CarousellScraper.new('wireless mouse')
# carousell.scrap
# carousell.average_price
