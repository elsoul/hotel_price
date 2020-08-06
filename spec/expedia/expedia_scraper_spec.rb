RSpec.describe HotelPrice::Expedia::ExpediaScraper, type: :class do
  describe "Expedia Scraper" do

    it "should return integer" do
      scraper = HotelPrice::Expedia::ExpediaScraper.new(:firefox)
      a1 = scraper.get_price "Sapporo-Hotels-Hotel-Sunroute-Sapporo.h5224778", (Date.today + 30).to_s, 2
      puts a1
      expect(a1[:min_price]).to be >= 0
    end
  end
end
