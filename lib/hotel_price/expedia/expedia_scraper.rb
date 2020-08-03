require "date"

module HotelPrice::Expedia
  class ExpediaScraper
    @mode

    def initialize(mode = :chrome)
      @mode = mode
    end

    def get_price(expedia_hotel_id, checkin_date, num_adults)
      date = DateTime.now.strftime("%Y-%m-%d")

      query_string = make_query_string(checkin_date.to_s, num_adults)
      url = "https://www.expedia.co.jp/ja/#{expedia_hotel_id}.Hotel-Information?#{query_string}"
      driver = HotelPrice.get_selenium_driver @mode
      driver.get(url)
      sleep 2

      data = driver.find_elements(:xpath, "//span[@data-stid='content-hotel-lead-price']")
      return { date: date, min_price: 0 } if data.empty?
      price = data.first.text.delete("^0-9").to_i

      hotel_name = ""
      room_name = ""

      hotel_name_element = driver.find_elements(:xpath, "//h1[@data-stid='content-hotel-title']")
      hotel_name = hotel_name_element.first.text unless hotel_name_element.empty?
      room_name_element = driver.find_elements(:xpath, "//h3[@data-stid='room-info-title-heading']")
      room_name = room_name_element.first.text unless room_name_element.empty?

      { checkin_date: checkin_date, min_price: price, hotel_name: hotel_name, room_name: room_name }
    end

    def make_query_string(checkin_date, num_adults)
      cd_args = make_date_args checkin_date
      na_args = make_num_adults_arg num_adults
      "#{cd_args}&#{na_args}&x_pwa=1&rfrr=HSR&pwa_ts=1583335742618&swpToggleOn=true&regionId=3250&destination=Sapporo%2C+Hokkaido%2C+Japan&destType=MARKET&neighborhoodId=6290332&selected=5224778&sort=recommended&top_dp=5686&top_cur=JPY"
    end

    def make_date_args checkin_date
      Date.parse checkin_date rescue return ""
      t = Date.parse(checkin_date)
      checkin_arg = t.strftime("chkin=%Y-%m-%d")
      checkout_arg = (t + 1).strftime("chkout=%Y-%m-%d")
      "#{checkin_arg}&#{checkout_arg}"
    end

    def make_num_adults_arg num_adults
      return "" if num_adults.to_i <= 1
      "rm1=a#{num_adults}"
    end
  end
end
