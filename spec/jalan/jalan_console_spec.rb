RSpec.describe HotelPrice::Jalan::JalanConsole, type: :class do
  describe "Jalan Console" do
    before(:each) do
      @a1 = HotelPrice::Jalan::JalanConsole.new(
        login_id: "login-id",
        login_pw: "login-pw",
        jalan_hotel_id: "128552",
        chain: false,
      )
    end

    it "should set Jalan hotel ID" do
      expect(@a1.instance_variable_get(:@config)[:jalan_hotel_id]).to eq "128552"
    end
  end
end
