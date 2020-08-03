require_relative "./rakuten/rakuten_api"
require_relative "./rakuten/rakuten_console"
require_relative "./rakuten/rakuten_scraper"

module HotelPrice
  module Rakuten
    def self.review rakuten_hotel_id
      driver = self.get_selenium_driver
      driver.get("https://travel.rakuten.co.jp/HOTEL/#{rakuten_hotel_id}/review.html")
      sleep 2
      comment_area = driver.find_elements(:class_name, "commentBox")
      data = comment_area.map do |f|
        {
          date: f.find_element(class_name: "time").text,
          rakuten_hotel_id: rakuten_hotel_id,
          comment: f.find_element(class_name: "commentSentence").text
        }
      end
      driver.quit
      data
    end
  end
end
