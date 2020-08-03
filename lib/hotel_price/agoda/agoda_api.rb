require 'json'

module HotelPrice::Agoda
  class AgodaAPI
    def self.get_price(hotel_id, checkin_date, num_adults)
      @api_key = HotelPrice.configuration ? HotelPrice.configuration.agoda_api_key : nil
      if @api_key.nil?
        puts "Must specify agoda_api_key in configuration to use the Agoda API"
        return -1
      end

      endpoint_url = "http://affiliateapi7643.agoda.com/affiliateservice/lt_v1"
      # 検索条件の指定
      # cityId, checkInDate, checkOutDate は必須、ソレ以外はオプション。
      #
      checkin_date = checkin_date.to_s
      Date.parse checkin_date rescue return ""
      t = Date.parse(checkin_date)
      checkin_arg = t.strftime("%Y-%m-%d")
      checkout_arg = (t + 1).strftime("%Y-%m-%d")

      params = {
          "criteria": {
              "additional": {
                  "currency": "JPY",
                  "discountOnly": false,
                  "language": "ja-jp",
                  "occupancy": {
                      "numberOfAdult": num_adults,
                      "numberOfChildren": 0
                  }
              },
              "checkInDate": checkin_arg,
              "checkOutDate": checkout_arg,
              "hotelId": [hotel_id]
          }
      }

      url = URI.parse(endpoint_url)
      req = Net::HTTP::Post.new(url.path)
      req["Authorization"] = @api_key
      req["Content-Type"]  = "application/json"
      req.body = params.to_json
      res = Net::HTTP.new(url.host, url.port).start do |http|
        http.request(req)
      end

      parsed_body = JSON.parse(res.body)
      if parsed_body['results'].nil? || parsed_body['results'].empty?
        return "No rooms for search criteria - please confirm hotel ID"
      end
      parsed_body['results'][0]['dailyRate']
    end
  end
end
