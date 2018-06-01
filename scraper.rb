# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

# require 'scraperwiki'
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
require "capybara"
require "selenium-webdriver"
require 'httparty'
require 'nokogiri'
require 'mechanize'
require 'scraperwiki'
require 'date'

ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }

page = HTTParty.get('https://booking.melia.com/booking/rates/C_Rates.jsp?IdPrm=TRIVAGO&utm_adg=trivago&utm_medium=metasearch&divisaPresentacion=EUR&hotelCode=3831&childrenRoom1Age2=5&idPartner=TRIVAGO_RU&rooms=1&childrenRoom1=2&adultsRoom1=2&month=08&utm_content=3831&utm_campaign=trivago_RU&cvosrc=cse.trivago.metasearch_trivago_RU-trivago_3831&nights=14&market=RU&childrenRoom1Age1=0&idLang=en&day=18&year=2018&utm_source=trivago&flexDates=false&currency=EUR')
nokogiri_page = Nokogiri::HTML(page)
fam_div = nokogiri_page.css("div[data-category=FAM]")
hname = 'Sol Arona Tenerife'
hprice = fam_div.css('span.price-regimen')[3].text.delete('€').delete(',').strip.to_i
hdate = DateTime.now.strftime("%d-%m-%Y %H-%M")
ScraperWiki.save_sqlite(["name", "date"], { "date" => hdate,"name" => hname, "price" => hprice})

capybara = Capybara::Session.new(:selenium_chrome_headless)
# Start scraping
capybara.visit("https://www.booking.com/hotel/es/santa-barbara-golf-and-ocean-club.ru.html?label=gen173nr-1FCAEoggJCAlhYSDNYBGjCAYgBAZgBIbgBB8gBDNgBAegBAfgBC5ICAXmoAgM;sid=6411abf698a6e8add1caa961b1846f07;age=0;age=5;all_sr_blocks=18875801_89758350_0_0_0;checkin=2018-08-25;checkout=2018-09-01;dest_id=-401188;dest_type=city;group_adults=2;group_children=2;hapos=1;highlighted_blocks=18875801_89758350_0_0_0;hpos=1;no_rooms=1;room1=A%2CA%2C0%2C5;sb_price_type=total;srepoch=1527772281;srfid=0c6ad07b6f24d4446e290d410a42800df8d75c7bX1;srpvid=e6425cbc25650165;type=total;ucfs=1&;selected_currency=EUR;changed_currency=1;top_currency=1")
hprice = capybara.first(:css, '.hprt-price-price-standard').text.delete('€').strip.to_i
hname = 'Santa barbara golf and ocean club'

ScraperWiki.save_sqlite(["name", "date"], { "date" => hdate,"name" => hname, "price" => hprice})

agent = Mechanize.new
page  = agent.get("https://www.pluscar-tenerife.com/booking.php")
frm = page.form('frm')
frm.start_date = "2018/08/18"
frm.end_date = "2018/09/01"
frm.start_hour_hour = 18
frm.end_hour_hour = 18
page = agent.submit(frm)


cars = page.search("div.cars.panel").map do |car|  
	car_name = car.css("div.cars_name").text
	car_price = car.css("div.cars_price").text.delete('€').strip.to_i
	{car: car_name, 
	price: car_price}
end


cars.each {|car| if car[:car] == "Toyota Auris" then ScraperWiki.save_sqlite(["name", "date"], { "date" => hdate,"name" => car[:car], "price" => car[:price]})  end}



