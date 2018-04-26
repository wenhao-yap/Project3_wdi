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

	def results
		items = @searchData.css('tbody > tr')
		output = items.each_with_index.map { |item, i| 
			shipping = item.css('.ship').text
			shipping.include?('$') ?
				(shipping = "$" + shipping.gsub(/[^\d\.]/, '')) : 
				(shipping.include?('Free') ? (shipping = "Free") : (shipping = "N.A."))
			origPrice = item.css('.dc_prc > del').text
			origPrice = "Not discounted" if origPrice.empty?
			rating = item.css('.rate_v').text
			rating = rating.gsub(/[aA-zZ:\s()]/,''); 

			{
				id: i+1,
				title: item.css('.sbj').text,
				currPrice: item.css('.prc > strong').text,
				origPrice: origPrice,
				shipping: shipping,
				rating: rating,
				seller: item.css('.lnk_sh').attr('title'),
				link: item.css('.lnk_vw').attr('href'),
				imageLink:  item.css('.td_thmb> .inner > a > img').attr('gd_src')
			}
		}
		JSON.pretty_generate(output)
	end

	def totalSellers
		total = @searchData.css('#div_global_domestic_tab').css('span')[0].text
		total = total.gsub(/[^\d\.]/, '')
	end

	private
	def homePage
		page = @agent.get('https://www.qoo10.sg/')
	end
end

