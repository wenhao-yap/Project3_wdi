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
		browser = Watir::Browser.new(:chrome, headless:true)
		browser.goto('https://shopee.sg/search/?keyword=' + @input +'&page=0&sortBy=sales')
		data = Nokogiri::HTML.parse(browser.html)				
		items = data.css('div.shopee-search-item-result__item')
		output = items.each_with_index.map { |item, i| 
			origPrice = item.css('.shopee-item-card__original-price').text
			origPrice = "Not discounted" if origPrice.empty?
			home = 'https://shopee.sg/'
			imageLink = browser.divs(:class => 'lazy-image__image')[i].style('background-image')
			max = imageLink.length - 3
			imageLink = imageLink[5..max] if imageLink != 'none'

			{
				id: i+1,
				title: item.css('.shopee-item-card__text-name').text,
				currPrice: item.css('.shopee-item-card__current-price').text,
				origPrice: origPrice,
				link: home + item.css('a.shopee-item-card--link').attr('href'),
				imageLink: imageLink
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