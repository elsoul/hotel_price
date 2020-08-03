module HotelPrice::Jalan
  require "nokogiri"
  require "open-uri"
  class JalanAPI
    def initialize params
      @config = {
        jalan_hotel_id: params[:jalan_hotel_id] ||= 0,
        jalan_api_key: params[:jalan_api_key] ||= ENV["JALAN_API_KEY"]
      }
    end

    def test
      @config[:jalan_api_key]
    end

    def get_min_price params
      url = "http://jws.jalan.net/APIAdvance/StockSearch/V1/?key=#{@config[:jalan_api_key]}&h_id=#{@config[:jalan_hotel_id]}&stay_date=#{params[:checkin_date]}&stay_count=1&adult_num=#{params[:adult_num]}&count=1"
      doc = Nokogiri::XML(open(url))
      if doc.css("NumberOfResults").text == "0"
        {
          date: DateTime.now.strftime("%Y-%m-%d"),
          jalan_hotel_id: @config[:jalan_hotel_id],
          checkin_date: params[:checkin_date],
          plan_num: 0,
          min_price: 0
        }
      else
        {
          date: DateTime.now.strftime("%Y-%m-%d"),
          jalan_hotel_id: @config[:jalan_hotel_id],
          checkin_date: params[:checkin_date],
          hotel_name: doc.css("Plan").css("Hotel HotelName").text,
          room_name: doc.css("Plan").css("RoomName").text,
          plan_name: doc.css("Plan").css("PlanName").text,
          plan_num: doc.css("NumberOfResults").text,
          min_price: doc.css("Plan").css("Stay Rate").text
        }
      end
    end
  end
end