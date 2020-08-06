RSpec.describe HotelPrice::Booking::BookingScraper, type: :class do
  describe "Booking Scraper" do

    it "should return integer" do
      scraper = HotelPrice::Booking::BookingScraper.new(:firefox)
      a1 = scraper.get_price "sunroute-sapporo", (Date.today + 30).to_s, 2
      puts a1
      expect(a1[:min_price]).to be >= 0
    end
  end
end
