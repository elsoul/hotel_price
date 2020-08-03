RSpec.describe HotelPrice::Agoda::AgodaAPI, type: :class do
  describe "Agoda API" do
    it "should error without API key" do
      res = HotelPrice::Agoda::AgodaAPI.get_price(407854, "2020-04-30", 2)
      expect(res).to eq -1
    end

    it "should send request with set API key" do
      HotelPrice.configure do |config|
        config.agoda_api_key = "abc123"
      end

      res = HotelPrice::Agoda::AgodaAPI.get_price(407854, "2020-04-30", 2)
      expect(res).not_to eq -1
    end
  end
end
