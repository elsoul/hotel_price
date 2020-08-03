module HotelPrice::Jalan
  class JalanScraper
    @mode

    def initialize(mode = :chrome)
      @mode = mode
    end

    def get_price(jalan_hotel_id, checkin_date, num_adults)
      date = DateTime.now.strftime("%Y-%m-%d")

      query_string = make_query_string(checkin_date.to_s, num_adults)
      url = "https://www.jalan.net/yad#{jalan_hotel_id}/plan/?screenId=UWW3101&yadNo=#{jalan_hotel_id}&#{query_string}"
      driver = HotelPrice.get_selenium_driver @mode
      driver.get(url)
      sleep 2
      @price_box = []
      driver.find_elements(class_name: "p-planCassette").each do |f|
        rows = f.find_elements(:xpath, "//tr")
        rows.each do |e|
          @price_box << {
            date: date,
            min_price: e.find_element(class_name: "p-searchResultItem__total").text.delete("^0-9").to_i,
            hotel_name: driver.find_element(id: "yado_header_hotel_name").text,
            room_name: e.find_element(class_name: "p-searchResultItem__planName").text,
            plan_name: f.find_element(class_name: "p-planCassette__header").text
          }
        rescue StandardError
          { date: date, min_price: 0 }
        end
      end
      @price_box.sort_by { |_a, _b, c| c }.reverse.first || { date: date, min_price: 0 }
    rescue StandardError
      { date: date, min_price: 0 }
    end

    def make_query_string(checkin_date, num_adults)
      cd_args = make_date_args checkin_date
      na_args = make_num_adults_arg num_adults
      "rootCd=7701&callbackHistFlg=1&contHideFlg=1&reSearchFlg=1&roomCrack=100000&smlCd=121108&distCd=01&#{cd_args}&stayCount=1&roomCount=1&#{na_args}&minPrice=0&maxPrice=999999"
    end

    def make_date_args checkin_date
      Date.parse checkin_date rescue return ""
      Date.parse(checkin_date).strftime("stayYear=%Y&stayMonth=%m&stayDay=%d")
    end

    def make_num_adults_arg num_adults
      return "" if num_adults.to_i < 1
      "adultNum=#{num_adults}"
    end
  end
end
