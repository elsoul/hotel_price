require "hotel_price/version"
require "hotel_price/rakuten"
require "hotel_price/jalan"
require "hotel_price/agoda"
require "hotel_price/booking"
require "hotel_price/expedia"
require "hotel_price/configuration"
require "selenium-webdriver"
require "net/http"
require "active_support/all"

module HotelPrice
  class Error < StandardError; end
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.rakuten_travel
    driver = self.get_selenium_driver
    rakuten_travel_hotel_id = 128552
    driver.get("https://travel.rakuten.co.jp/HOTEL/#{rakuten_travel_hotel_id}/review.html")
    sleep 2
    comment_area = driver.find_elements(:class_name, "commentReputationBoth")
    comment_area.map do |f|
      {
        status: "success",
        date: f.find_element(class_name: "time").text,
        rakuten_hotel_id: rakuten_travel_hotel_id,
        comment: f.find_element(class_name: "commentSentence").text
      }
    end
  end

  protected

  def self.get_selenium_driver(mode = :chrome)
    case mode
    when :firefox_remote_capabilities
      firefox_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      Selenium::WebDriver.for(:remote, url: "http://hub:4444/wd/hub", desired_capabilities: firefox_capabilities)
    when :firefox
      Selenium::WebDriver.for :firefox
    else
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--ignore-certificate-errors")
      options.add_argument("--disable-popup-blocking")
      options.add_argument("--disable-translate")
      options.add_argument("-headless")
      Selenium::WebDriver.for :chrome, options: options
    end
  end

  private

  class Configuration
    # Agoda API key
    # @param [String]
    attr_accessor :agoda_api_key
    attr_accessor :selenium_driver

    def initialize
      @agoda_api_key = nil
    end
  end
end
