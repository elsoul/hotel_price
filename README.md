[![HotelPrice](https://firebasestorage.googleapis.com/v0/b/el-quest.appspot.com/o/mediaLibrary%2F1574151922089_elsoul.png?alt=media&token=bbbcb9a4-a226-4c68-bdab-6310a9af4b02)](https://rubygems.org/gems/hotel_price/)

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
# HotelPrice
This Gem is made for ppl who work at travel industry

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

### Rakuten Travel

#### Rakuten API
Initialize with `rakuten_hotel_id` and `Rakuten Travel API key`
Rakuten Travel API Reference : https://webservice.rakuten.co.jp/api/simplehotelsearch/


```ruby
hotel = HotelPrice::Rakuten::RakutenAPI.new(
  rakuten_hotel_id: "128552",
  rakuten_api_key: "api_key"
)
```

Get Hotel Info

```ruby
puts hotel.hotel_info
```


### RakutenScraper
Argments : `rakuten_hotel_id`, `YYYY-MM-DD`, `adult_nums`

```ruby
HotelPrice::Rakuten::RakutenScraper.get_price("128552", (Date.today + 45.day).to_s, 1)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/hotel_price).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/hotel_price. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/el-fudo/hotel_price/blob/master/CODE_OF_CONDUCT.md).
