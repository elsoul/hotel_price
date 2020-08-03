RSpec.describe HotelPrice::Jalan::JalanScraper, type: :class do
  describe "Jalan Scraper" do
    it "should return min price" do
      scraper = HotelPrice::Jalan::JalanScraper.new(:firefox)
      a1 = scraper.get_price("366371", "20200630", 1)
      expect(a1[:min_price]).to be_a Integer
    end
  end
end
