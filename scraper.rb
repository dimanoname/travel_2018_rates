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
require 'watir'
require 'headless'
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
puts hname
puts hprice
ScraperWiki.save_sqlite(["name"], { "name" => hname, "price" => hprice})
ScraperWiki.select("* from data")

