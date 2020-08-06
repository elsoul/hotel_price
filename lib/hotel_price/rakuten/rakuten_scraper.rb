module HotelPrice::Rakuten
  class RakutenScraper
    @mode

    def initialize(mode = :chrome)
      @mode = mode
    end

    def get_price(rakuten_hotel_id, checkin_date, num_adults)
      date = Time.now.strftime("%Y-%m-%d")

      query_string = make_query_string(checkin_date.to_s, num_adults)
      url = "https://hotel.travel.rakuten.co.jp/hotelinfo/plan/#{rakuten_hotel_id}?#{query_string}"
      driver = HotelPrice.get_selenium_driver @mode
      driver.get(url)
      sleep 2
      driver.find_elements(class_name: "planThumb").first rescue return ""
      first_plan = driver.find_elements(class_name: "planThumb").first
      hotel_name = driver.find_element(class_name: "rtconds").text
      price = first_plan.find_element(class_name: "vPrice").text.delete("^0-9").to_i
      room_name = first_plan.find_element(tag_name: "h6").text
      plan_name = first_plan.find_element(tag_name: "h4").text
      { date: date, min_price: price, hotel_name: hotel_name, room_name: room_name, plan_name: plan_name }
    rescue StandardError
      { date: date, min_price: 0 }
    end

    def make_query_string(checkin_date, num_adults)
      cd_args = make_date_args checkin_date
      na_args = make_num_adults_arg num_adults
      "f_teikei=quick&f_hizuke=&f_hak=&f_dai=japan&f_chu=tokyo&f_shou=nishi&f_sai=&f_tel=&f_target_flg=&f_tscm_flg=&f_p_no=&f_custom_code=&f_search_type=&f_camp_id=&f_static=1&f_rm_equip=&#{cd_args}&f_heya_su=1&#{na_args}"
    end

    def make_date_args checkin_date
      Date.parse checkin_date rescue return ""
      t = Date.parse(checkin_date)
      checkin_arg = t.strftime("f_hi1=%d&f_tuki1=%m&f_nen1=%Y")
      checkout_arg = (t + 1).strftime("f_hi2=%d&f_tuki2=%m&f_nen2=%Y")
      "#{checkin_arg}&#{checkout_arg}"
    end

    def make_num_adults_arg num_adults
      return "" if num_adults.to_i <= 1
      "f_otona_su=#{num_adults}&f_kin2=0&f_kin=&f_s1=0&f_s2=0&f_y1=0&f_y2=0&f_y3=0&f_y4=0"
    end
  end
end
