RSpec.describe HotelPrice::Jalan::JalanAPI, type: :class do
  describe "Jalan API" do
    before(:each) do
      @a1 = HotelPrice::Jalan::JalanAPI.new(
        jalan_hotel_id: "394316",
        jalan_api_key: ENV["JALAN_API_KEY"]
      )
    end

    it "should set Jalan hotel ID" do
      expect(@a1.instance_variable_get(:@config)[:jalan_hotel_id]).to eq "394316"
    end

    it "should get min price" do
      ## Change date or jalan_hotel_id if there is no data.
      params = {
        checkin_date: (DateTime.now + 45).strftime("%Y%m%d"),
        breakfast: "",
        adult_num: 1
      }
      result = @a1.get_min_price(params)
      p result
      expect(result[:checkin_date]).to eq params[:checkin_date]
    end
  end
end
