RSpec.describe HotelPrice do

  it "has a version number" do
    expect(HotelPrice::VERSION).not_to be nil
  end

  describe "Rakuten Travel Review" do
    ## Scraper Test
    # it "Get All Reviews" do
    #   a1 = HotelPrice::RakutenTravel.review "128552"
    #   expect(a1[0][:rakuten_hotel_id]).to eq "128552"
    # end
  end

  describe "Rakuten Travel API" do
    before(:each) do
      @a1 = HotelPrice::Rakuten::RakutenAPI.new(
        rakuten_hotel_id: "128552"
      )
    end

    it "Test" do
      expect(@a1.instance_variable_get(:@config)[:rakuten_hotel_id]).to eq "128552"
    end
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      HotelPrice.configure do |config|
        config.agoda_api_key = "abc123"
      end

      expect(HotelPrice.configuration.agoda_api_key).to eq "abc123"
    end
  end

end
