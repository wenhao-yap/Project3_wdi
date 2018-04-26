require 'watir'
require 'nokogiri'

class ShopeeScraper

	def initialize(input)
		@input = input
	end

	# ===================================
	# BestSellers
	# ===================================


	# ===================================
	# Search Results
	# ===================================

	def results
		browser = Watir::Browser.new(:chrome,headless:true)
		browser.goto('https://shopee.sg/search/?keyword=' + @input)

		x = 0
		loop do
			browser.execute_script("window.scrollBy(0," + x.to_s + ")")
			x = x + 100
			sleep 1
			puts x
			break if x > 1000
		end

		data = Nokogiri::HTML.parse(browser.html)
		items = data.css('div.shopee-search-item-result__item')
		output = items[0..9].each_with_index.map { |item, i|
			home = 'https://shopee.sg/'
			img = browser.divs(:class => 'lazy-image__image')[i].style('background-image')
			max = img.length - 3
			img = imageLink[5..max] if imageLink != "none"

			{
				id: i+1,
				name: item.css('.shopee-item-card__text-name').text,
				price: item.css('.shopee-item-card__current-price').text,
				url: home + item.css('a.shopee-item-card--link').attr('href'),
				img: imageLink
			}
		}
		browser.close
		JSON.pretty_generate(output)
	end

	def totalSellers
		browser = Watir::Browser.new(:chrome, headless:true)
		browser.goto('https://shopee.sg/search/?keyword=' + @input +'&page=0&sortBy=sales')
		data = Nokogiri::HTML.parse(browser.html)
		categories = data.css('.shopee-facet-filter__facet--main')
		total = 0
		categories.each { |category|
			count = category.css('.shopee-facet-filter__count').text
			total = total + count.gsub(/[^\d\.]/, '').to_i
		}
		browser.close
		total
	end
end
