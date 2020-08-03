require "date"

module HotelPrice::Booking
  class BookingScraper
    @mode

    def initialize(mode = :chrome)
      @mode = mode
    end

    def get_price(booking_hotel_id, checkin_date, num_adults)
      date = DateTime.now.strftime("%Y-%m-%d")

      query_string = make_query_string(checkin_date.to_s, num_adults)
      url = "https://www.booking.com/hotel/jp/#{booking_hotel_id}.ja.html?#{query_string}"
      driver = HotelPrice.get_selenium_driver @mode
      driver.get(url)
      sleep 2

      data = driver.find_elements(:class_name, "hprt-table")
      return { date: date, min_price: 0 } if data.empty?
      price_box = data.first.find_elements(:class_name, "bui-price-display__value")
      return { date: date, min_price: 0 } if price_box.empty?
      price = price_box.first.text.delete("^0-9").to_i

      hotel_name = ""
      room_name = ""

      hotel_name_element = driver.find_elements(:class_name, "hp__hotel-type-badge")
      hotel_name = hotel_name_element.first.text unless hotel_name_element.empty?
      room_name_element = driver.find_elements(:class_name, "hprt-ws-roomtype-link")
      room_name = room_name_element.first.text unless room_name_element.empty?

      { checkin_date: checkin_date, min_price: price, hotel_name: hotel_name, room_name: room_name }
    end

    def make_query_string(checkin_date, num_adults)
      cd_args = make_date_args checkin_date
      na_args = make_num_adults_arg num_adults
      "#{cd_args}&#{na_args}&dist=0&do_availability_check=1&hp_avform=1&hp_group_set=0&no_rooms=1&origin=hp&sb_price_type=total&src=hotel&tab=1&type=total&lang=ja&selected_currency=JPY"
    end

    def make_date_args checkin_date
      Date.parse checkin_date rescue return ""
      t = Date.parse(checkin_date)
      checkin_arg = t.strftime("checkin_monthday=%d&checkin_year_month=%Y-%m")
      checkout_arg = (t + 1).strftime("checkout_monthday=%d&checkout_year_month=%Y-%m")
      "#{checkin_arg}&#{checkout_arg}"
    end

    def make_num_adults_arg num_adults
      return "" if num_adults.to_i <= 1
      "group_adults=#{num_adults}&group_children=0"
    end
  end
end
