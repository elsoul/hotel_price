module HotelPrice::Jalan
  class JalanConsole
    def initialize params
      @config = {
        login_id: params[:login_id],
        login_pw: params[:login_pw],
        chain: params[:chain] ||= false,
        jalan_hotel_id: params[:jalan_hotel_id] ||= 0
      }
    end
  end
end