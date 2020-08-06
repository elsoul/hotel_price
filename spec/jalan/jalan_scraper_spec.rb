RSpec.describe HotelPrice::Jalan::JalanScraper, type: :class do
  describe "Jalan Scraper" do
    it "should return min price" do
      scraper = HotelPrice::Jalan::JalanScraper.new(:firefox)
      a1 = scraper.get_price "366371", (Date.today + 30).to_s, 1
      puts a1
      expect(a1[:min_price]).to be_a Integer
    end
  end
end
