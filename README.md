# Hotel Price
WebCrawler for checking booking price of travel agencies.

<p align="center">

  <a aria-label="Ruby logo" href="https://el-soul.com">
    <img src="https://badgen.net/badge/icon/Made%20by%20ELSOUL?icon=ruby&label&color=black&labelColor=black">
  </a>
  <br/>

  <a aria-label="Ruby Gem version" href="https://rubygems.org/gems/hotel_price">
    <img alt="" src="https://badgen.net/rubygems/v/hotel_price/latest">
  </a>
  <a aria-label="Downloads Number" href="https://rubygems.org/gems/hotel_price">
    <img alt="" src="https://badgen.net/rubygems/dt/hotel_price">
  </a>
  <a aria-label="License" href="https://github.com/elsoul/hotel_price/blob/master/LICENSE">
    <img alt="" src="https://badgen.net/badge/license/Apache/blue">
  </a>
</p>

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hotel_price"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install hotel_price
```

## Usage
Initialize Agent Scraper with agent's name and browser mode.

You can choose browser mode below;<br>
`:chrome`<br>
`:firefox`<br>
`:firefox_remote_capabilities`<br>
(remote_url: "http://hub:4444/wd/hub")<br>
<br>

### Install Chronium for Chrome browser (Mac Homebrew)
  `brew cask install chromium`

### Install Geckodriver for Firefox browser
Download from Mozilla Geckodriver Github<br>
[https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases)
<br>

<br>

## Agent Availability and Agent Name (at August 2020)
<br>
1. Rakuten Travel -> Rakuten<br>
2. Jalan          -> Jalan<br>
3. Expedia        -> Expedia<br>
4. Booking.com    -> Booking<br>
5. Agoda          -> Agoda<br>
<br><br>

Argments : `agent_hotel_id`, `YYYY-MM-DD`, `adult_nums`
<br>

`.get_price`

method will run web crawler and return minimum price.

You can get `agent_hotel_id` from each agent's Official Website.

```ruby
scraper = HotelPrice::[AgentName]::[AgentName]Scraper.new(:chrome)
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```

### Sample Response
```ruby
{
	:date => "2020-08-03",
 	:min_price => 5023,
 	:hotel_name => "相鉄フレッサイン新橋烏森口（旧：ホテルサンルート新橋）",
 	:room_name => "シングル【禁煙】12.7平米120センチ幅シモンズ社製ベッド",
 	:plan_name => "NEW 【楽天限定2020】スペシャルサマープラン＜食事なし＞"
}
```

### Rakuten Travel Scraper
Official Website<br>
[https://travel.rakuten.co.jp/](https://travel.rakuten.co.jp/)

```ruby
scraper = HotelPrice::Rakuten::RakutenScraper.new(:chrome)
agent_hotel_id = "128552" # e.g 料理旅館 富久潮
checkin_date = (Date.today + 30.day).to_s
adult_nums = 1
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```


### Jalan Scraper
Official Website<br>
[https://www.jalan.net/](https://www.jalan.net/)

```ruby
scraper = HotelPrice::Jalan::JalanScraper.new(:chrome)
agent_hotel_id = "366371" # e.g　相鉄ホテル
checkin_date = (Date.today + 30.day).to_s
adult_nums = 1
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```


### Expedia Scraper
Official Website<br>
[https://www.expedia.co.jp/](https://www.expedia.co.jp/)

```ruby
scraper = HotelPrice::Expedia::ExpediaScraper.new(:chrome)
agent_hotel_id = "Sapporo-Hotels-Hotel-Sunroute-Sapporo.h5224778" # e.g　相鉄ホテル
checkin_date = (Date.today + 30.day).to_s
adult_nums = 1
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```


### Booking.com Scraper
Official Website<br>
[http://booking.com/](http://booking.com/)

```ruby
scraper = HotelPrice::Booking::BookingScraper.new(:chrome)
agent_hotel_id = "sunroute-sapporo" # e.g　相鉄ホテル
checkin_date = (Date.today + 30.day).to_s
adult_nums = 1
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```


### Agoda Scraper
Official Website<br>
[https://www.agoda.com/](https://www.agoda.com/)

```ruby
scraper = HotelPrice::Agoda::AgodaScraper.new(:chrome)
agent_hotel_id = "hotel-sunroute-new-sapporo/hotel/sapporo-jp" # e.g　相鉄ホテル
checkin_date = (Date.today + 30.day).to_s
adult_nums = 1
scraper.get_price(agent_hotel_id, checkin_date, adult_nums)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/hotel_price).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/hotel_price. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/hotel_price/blob/master/CODE_OF_CONDUCT.md).
