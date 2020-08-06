module HotelPrice::Rakuten
  class RakutenAPI
    def initialize params
      @config = {
        rakuten_hotel_id: params[:rakuten_hotel_id].to_s ||= 0,
        rakuten_api_key: params[:rakuten_api_key] ||= ENV["RT_API_KEY"]
      }
    end

    def get_price(rakuten_hotel_id, checkin_date, num_adults)
      query_string = make_query_string(rakuten_hotel_id, checkin_date.to_s, num_adults)
      url = "https://app.rakuten.co.jp/services/api/Travel/VacantHotelSearch/20131024?#{query_string}"
      json = Net::HTTP.get(URI.parse(url))
      result = JSON.parse(json)
      if result["error"] == "not_found"
        {
          date: Time.now.strftime("%Y-%m-%d"),
          checkin_date: checkin_date,
          rakuten_hotel_id: @config[:rakuten_hotel_id],
          adult_num: num_adults,
          breakfast: "",
          plan_num: 0,
          min_price: 0
        }
      elsif result["error"] == "wrong_parameterd"
        "入力した値が正しくありません。"
      else
        {
          date: DateTime.now.strftime("%Y-%m-%d"),
          checkin_date: checkin_date,
          rakuten_hotel_id: rakuten_hotel_id,
          hotel_name: result["hotels"][0]["hotel"][0]["hotelBasicInfo"]["hotelName"],
          adult_num: num_adults,
          breakfast: "",
          plan_num: result["pagingInfo"]["recordCount"],
          room_name: result["hotels"][0]["hotel"][1]["roomInfo"][0]["roomBasicInfo"]["roomName"],
          plan_name: result["hotels"][0]["hotel"][1]["roomInfo"][0]["roomBasicInfo"]["planName"],
          min_price: result["hotels"][0]["hotel"][1]["roomInfo"][1]["dailyCharge"]["rakutenCharge"]
        }
      end
    end

    def make_query_string(rakuten_hotel_id, checkin_date, num_adults)
      checkout_date = (Date.parse(checkin_date) + 1).strftime("%Y-%m-%d")
      "format=json&sort=%2BroomCharge&searchPattern=1&applicationId=#{@config[:rakuten_api_key]}&hotelNo=#{rakuten_hotel_id}&adultNum=#{num_adults}&checkinDate=#{checkin_date}&checkoutDate=#{checkout_date}&squeezeCondition="
    end

  end
end
