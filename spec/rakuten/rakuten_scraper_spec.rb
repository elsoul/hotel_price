RSpec.describe HotelPrice::Rakuten::RakutenScraper, type: :class do
  describe "Rakuten Scraper" do
    scraper = HotelPrice::Rakuten::RakutenScraper.new(:chrome)
    it "should return min price" do
      a1 = scraper.get_price("68565", (Date.today + 45.day).to_s, 1)
      puts a1
      expect(a1[:min_price]).to be_a Integer
    end
  end
end
