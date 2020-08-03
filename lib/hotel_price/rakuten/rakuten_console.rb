module HotelPrice::Rakuten
  class RakutenConsole
    def initialize params
      @config = {
        login_id: params[:login_id],
        login_pw: params[:login_pw],
        chain: params[:chain] ||= false,
        rakuten_hotel_id: params[:rakuten_hotel_id] ||= 0,
        mode: params[:mode] ||= :chrome
      }
      @wait = Selenium::WebDriver::Wait.new(timeout: 100)
      @driver = HotelPrice.get_selenium_driver @config[:mode]
      if @config[:chain]
        go_to_management_page_chain
      else
        go_to_management_page_single
      end
    end

    def go_to_management_page_chain
      @driver.get "https://manage.travel.rakuten.co.jp/portal/inn/ry_group.main"
      @driver.find_element(:name, "f_id").send_keys @config[:login_id].to_s
      @driver.find_element(:name, "f_pass").send_keys @config[:login_pw].to_s
      @driver.find_element(:xpath, "/html/body/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/form/table/tbody/tr[2]/td[3]/input").click
      begin
        @driver.find_element(:xpath, "/html/body/center/table/tbody/tr[5]/td[2]/form[3]/input[8]").click
      rescue StandardError
        @driver.find_element(:xpath, "/html/body/center/table/tbody/tr[7]/td[2]/form[3]/input[8]").click
      end
      @i = 0
      (2..21).each do |i|
        rakuten_hotel_id = @driver.find_element(:xpath, "/html/body/center[2]/table/tbody/tr[#{i}]/td[1]").text
        @i = i if @config[:rakuten_hotel_id].to_s == rakuten_hotel_id.to_s
        break if @i == i
      end
      until @i != 0
        @driver.find_element(:xpath, "/html/body/table/tbody/tr/td[2]/form/input[10]").click
        (2..21).each do |i|
          rakuten_hotel_id = @driver.find_element(:xpath, "/html/body/center[2]/table/tbody/tr[#{i}]/td[1]").text
          @i = i if @config[:rakuten_hotel_id].to_s == rakuten_hotel_id.to_s
          break if @i == i
        end
      end
      @driver.find_element(:xpath, "/html/body/center[2]/table/tbody/tr[#{@i}]/td[3]/form/input[10]").click
      @driver
    end

    def go_to_management_page_single
      @driver.get "https://manage.travel.rakuten.co.jp/portal/inn/mp_kanri_image_up.main"
      @driver.find_element(:name, "f_id").send_keys @config[:login_id]
      @driver.find_element(:name, "f_pass").send_keys @config[:login_pw]
      @driver.find_element(:xpath, "/html/body/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td/form/table/tbody/tr[2]/td[3]/input").click
      @driver
    end

    def go_to_plan_setting
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[3]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/input").click
      @wait.until { @driver.find_element(:link_text, "宿泊プラン") }
      @driver.find_element(:link_text, "宿泊プラン").click
      @plans = @driver.find_elements(:class, "h_top_pl_name")
      @driver
    end

    def get_plan_num
      go_to_plan_setting
      @driver.quit
      @plans.size
    end

    def save_plan_name
      go_to_plan_setting
      @data = {}
      @plans.each_with_index do |row, i|
        cells = row.find_elements(:css, "td")
        plan_info = row.text.split(":")
        @data[i] = {
          hotel_id: @hotel.id,
          manage_number: plan_info[0],
          plan_name: plan_info[1]
        }
        puts "saved" if RakutenPlan.create(@data[i]).valid?
      end
      @driver.quit
    end

    def edit_plan
      go_to_plan_setting
      @data = {}
      @plans.each_with_index do |row, i|
        cells = row.find_elements(:css, "td")
        plan_info = row.text.split(":")
        @data[i] = {
          hotel_id: @hotel.id,
          manage_number: plan_info[0],
          plan_name: plan_info[1]
        }
      end

      (0..@plans.size - 1).each do |i|
        plan = RakutenPlan.find_by(manage_number: @data[i][:manage_number])
        @driver.find_element(:link_text, @data[i][:plan_name]).click
        @driver.find_element(:xpath, "/html/body/form[4]/table[1]/tbody/tr/td/table/tbody[1]/tr[3]/td[2]").text
        flag = []
        flag[0] = "楽天トラベル[宿泊のみ]" if @driver.find_element(:name, "f_tabi_flg").selected?

        if @driver.find_element(:name, "f_dp_del_flg").selected?
          flag[1] = "ANA楽パック" if @driver.find_element(:name, "f_dp_ana_flg").selected?
          flag[2] = "JAL楽パック" if @driver.find_element(:name, "f_dp_jal_flg").selected?
        end
        flag[3] = "R-with" if @driver.find_element(:name, "f_kobetu_flg").selected?
        begin
          plan_name_p = @driver.find_element(:name, "f_dp_title").attribute("value")
          plan_body_p = @driver.find_element(:name, "f_dp_naiyo").attribute("value")

          plan_name_r = @driver.find_element(:name, "f_rw_title").attribute("value")
          plan_body_r = @driver.find_element(:name, "f_rw_naiyo").attribute("value")
        rescue StandardError => e
          plan_name_p = ""
          plan_body_p = ""

          plan_name_r = ""
          plan_body_r = ""
          puts "no dp"
          puts e
        end

        plan_body = @driver.find_element(:name, "f_naiyo").attribute("value")

        # inbound = @driver.find_element(:xpath, "/html/body/form[4]/table[1]/tbody/tr/td/table/tbody[1]/tr[11]/td[2]/table/tbody/tr[1]/td/label") if @driver.find_element(:name, "f_multi").selected?
        @room_types = @driver.find_elements(:name, "f_syu")
        @room_type = []
        @room_types.each_with_index do |row, i|
          if row.selected?
            @room_type[i - 1] = row.attribute("value")
          end
        end
        plan_start_y = @driver.find_element(:name, "f_k_nen1").attribute("value")
        plan_start_m = @driver.find_element(:name, "f_k_tuki1").attribute("value")
        plan_start_d = @driver.find_element(:name, "f_k_hi1").attribute("value")
        plan_end_y = @driver.find_element(:name, "f_k_nen2").attribute("value")
        plan_end_m = @driver.find_element(:name, "f_k_tuki2").attribute("value")
        plan_end_d = @driver.find_element(:name, "f_k_hi2").attribute("value")
        stay_start_y = @driver.find_element(:name, "f_nen1").attribute("value")
        stay_start_m = @driver.find_element(:name, "f_tuki1").attribute("value")
        stay_start_d = @driver.find_element(:name, "f_hi1").attribute("value")
        stay_end_y = @driver.find_element(:name, "f_nen2").attribute("value")
        stay_end_m = @driver.find_element(:name, "f_tuki2").attribute("value")
        stay_end_d = @driver.find_element(:name, "f_hi2").attribute("value")
        min_stay = @driver.find_element(:name, "f_min_hak").attribute("value")
        max_stay = @driver.find_element(:name, "f_max_hak").attribute("value")
        checkintime = @driver.find_element(:name, "f_lt_plan_in").attribute("value")
        checkouttime = @driver.find_element(:name, "f_lt_plan_in_limit").attribute("value")

        @driver.find_elements(:name, "f_credit").each_with_index do |f, i|
          next unless f.selected?

          @payment_method = if i == 0
                              "現金決済または事前カード決済"
                            elsif i == 1
                              "事前カード決済のみ"
                            elsif i == 2
                              "現金のみ"
                            else
                              ""
                            end
        end

        plan_hash = {
          plan_name_p: plan_name_p,
          plan_name_r: plan_name_r,
          plan_body: plan_body.gsub("\n", ""),
          plan_body_p: plan_body_p.gsub("\n", ""),
          plan_body_r: plan_body_r.gsub("\n", ""),
          # :inbound => inbound,
          room_type_ids: @room_type,
          plan_start: plan_start_y + "-" + plan_start_m + "-" + plan_start_d,
          plan_end: plan_end_y + "-" + plan_end_m + "-" + plan_end_d,
          stay_start: stay_start_y + "-" + stay_start_m + "-" + stay_start_d,
          stay_end: stay_end_y + "-" + stay_end_m + "-" + stay_end_d,
          payment_method: @payment_method,
          min_stay: min_stay,
          max_stay: max_stay,
          checkintime: checkintime,
          checkouttime: checkouttime
        }
        puts "plan saved!: #{plan_hash}" if plan.update_attributes(plan_hash)
        @driver.navigate.back
      end

      @driver.quit
    end

    def save_room_type
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[3]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/input").click
      @wait.until { @driver.find_element(:link_text, "宿泊") }
      @driver.find_element(:link_text, "宿泊").click
      @room_types = @driver.find_elements(:class, "h_top_rm_name")
      @data = {}
      @room_types.each_with_index do |row, i|
        cells = row.find_elements(:css, "td")
        room_type_info = row.text.split(":")
        @data[i] = {
          hotel_id: @hotel.id,
          room_type_id: room_type_info[0],
          room_type_name: room_type_info[1]
        }
        puts "saved" if RakutenRoom.create(@data[i]).valid?
      end
      @driver.quit
    end

    def edit_room_type
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[3]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/input").click
      @wait.until { @driver.find_element(:link_text, "宿泊") }
      @driver.find_element(:link_text, "宿泊").click
      @room_types = @driver.find_elements(:class, "h_top_rm_name")
      @data = {}
      @room_types.each_with_index do |row, i|
        cells = row.find_elements(:css, "td")
        room_type_info = row.text.split(":")
        @data[i] = {
          hotel_id: @hotel.id,
          room_type_id: room_type_info[0],
          room_type_name: room_type_info[1]
        }
      end
      (0..@data.size - 1).each do |room_types|
        @driver.find_element(:link_text, @data[room_types][:room_type_name]).click
        flag = []
        flag[0] = "楽天トラベル[宿泊のみ]" if @driver.find_element(:name, "f_tabimado_del_flg").selected?

        if @driver.find_element(:name, "f_dp_del_flg").selected?
          flag[1] = "楽天トラベルパッケージ"
          room_type_name_p = @driver.find_element(:name, "f_n_dp_syu").attribute("value")
          remark_p = @driver.find_element(:name, "f_r_dp_syu").attribute("value")
        else
          room_type_name_p = ""
          remark_p = ""
        end
        flag[2] = "R-with" if @driver.find_element(:name, "f_kobetu_del_flg").selected?
        flag[3] = "R-with［割引料金］" if @driver.find_element(:name, "f_vip_del_flg").selected?

        room_facility = []
        room_facility[0] = "トイレ" if @driver.find_element(:id, "view4_toilet") .selected?
        room_facility[1] = "バス" if @driver.find_element(:id, "view4_bath") .selected?
        room_facility[2] = "シャワーのみ" if @driver.find_element(:id, "view4_shower") .selected?
        img_url = @driver.find_element(:name, "f_img_url").attribute("value")
        @driver.find_elements(:name, "f_pic_flg").each do |f|
          img_url = if f.selected?
                      @driver.find_element(:name, "f_img_url").attribute("value")
                    else
                      ""
                    end
        end

        @driver.find_elements(:name, "f_credit").each_with_index do |f, i|
          next unless f.selected?

          @payment_method = if i == 0
                              "現金決済または事前カード決済"
                            elsif i == 1
                              "事前カード決済のみ"
                            elsif i == 2
                              "現金のみ"
                            else
                              ""
                            end
        end

        if @driver.find_element(:id, "nc_width1").selected?
          mm = @driver.find_element(:id, "su_width1").attribute("value")
          room_size = mm.to_s + "㎡"
          room_size_mm = mm.to_i
          room_size_tatami = ""
        elsif @driver.find_element(:id, "nc_width2").selected?
          mm = @driver.find_element(:id, "nc_width2").attribute("value")
          room_size = mm.to_s + "畳"
          room_size_mm = ""
          room_size_tatami = mm.to_i
        elsif @driver.find_element(:id, "nc_width3").selected?
          room_size = "客室により異なる"
          room_size_mm = ""
          room_size_tatami = ""
        end
        (0..5).each do |i|
          @driver.find_element(:id, "view2_type_#{i}").attribute("value") if @driver.find_element(:id, "view2_type_#{i}").selected?
        end

        # Pause sort
        # room_facility = %w(禁煙ルーム 喫煙ルーム インターネットができる部屋 露天風呂付き客室　ジャグジーのある客室 離れ客室 コーナールーム 二間以上 洗浄機付きトイレ 高層階 夜景が見える 海が見える 山が見える 湖が見える 川が見える)
        # sort = []
        # for i in 1 .. 13
        #   sort[i-1] = room_facility[i-1] if @driver.find_element(:id, "narrow#{i}").selected?
        # end
        # sort.compact!

        room_db = RakutenRoom.find_by(hotel_id: @hotel.id, room_type_id: @data[room_types][:room_type_id])
        room_type_data = {
          public: flag,
          room_type_name_p: room_type_name_p,
          capacity_min: @driver.find_element(:xpath, "/html/body/table[8]/tbody/tr/td/table[1]/tbody/tr[5]/td[2]").text.gsub(" 名～ 名", ""),
          capacity_max: @driver.find_element(:name, "f_max").attribute("value"),
          remark: @driver.find_element(:name, "f_bikou").attribute("value"),
          remark_p: remark_p,
          room_size: room_size,
          room_size_mm: room_size_mm,
          room_size_tatami: room_size_tatami,
          room_category: room_category,
          room_facility: room_facility,
          room_img: img_url,
          #:sort => sort,
          payment_method: @payment_method
        }
        puts "room type info updated: #{@hotel.id}" if room_db.update_attributes(room_type_data)
        @driver.navigate.back
      end
      @driver.quit
    end

    def login_check
      exp = @driver.find_element(:xpath, "/html/body/table[1]/tbody/tr[1]/td/table/tbody/tr/td[5]/table/tbody/tr[1]/td").text.gsub("次回パスワード更新日：", "").gsub("※事前にパスワードを変更されたい場合はこちらをご参照ください。\n", "")
      rakuten_hotel_id = @driver.find_element(:xpath, "/html/body/table[1]/tbody/tr[1]/td/table/tbody/tr/td[2]/table/tbody/tr/td").text.gsub("施設番号 : ", "").split("\n")[0]
      {
        status: "success",
        password_exp_date: exp,
        rakuten_hotel_id: rakuten_hotel_id
      }
    rescue StandardError => e
      {
        status: "error",
        error: e.to_s
      }
    end

    # def get_area_seo_rank
    #   @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[1]/tbody/tr[2]/td/table/tbody/tr[1]/td[5]/table/tbody/tr/td/table[1]/tbody/tr[5]/td[2]/font/b")
    #   rows = @driver.find_elements(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[1]/tbody/tr[2]/td/table/tbody/tr[1]/td[5]/table/tbody/tr/td/table[1]/tbody/tr[5]")
    #   rows.each do |f|
    #     cells = f.find_elements(:css, "td").map(&:text)
    #     return cells[1]
    #   end
    # end

    def degit2 num
      num = "0#{num}" if num.to_s.size == 1
      num
    end

    def get_reservation_info
      t = Time.now
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[3]/tbody/tr[2]/td[2]/table/tbody/tr[3]/td/input").click
      if t.day == 1
        last_month = degit2 t.prev_month.month.to_i
        yesterday = degit2 t.prev_month.end_of_month.day.to_i
        this_month = degit2 t.month.to_i
        today = degit2 t.day.to_i
        last_month_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_tuki1"))
        last_month_select.select_by(:value, last_month.to_s)
        yesterday_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_hi1"))
        yesterday_select.select_by(:value, yesterday.to_s)
        this_month_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_tuki2"))
        this_month_select.select_by(:value, this_month.to_s)
        today_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_hi2"))
        today_select.select_by(:value, today.to_s)
        search = @driver.find_element(:xpath, "/html/body/table[7]/tbody/tr[1]/td[4]/input").click
      else
        yesterday = degit2 t.yesterday.day.to_i
        today = degit2 t.day.to_i
        yesterday_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_hi1"))
        yesterday_select.select_by(:value, yesterday.to_s)
        today_select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_hi2"))
        today_select.select_by(:value, today.to_s)
        search = @driver.find_element(:xpath, "/html/body/table[7]/tbody/tr[1]/td[4]/input").click
      end

      @wait.until { @driver.find_elements(:xpath, "//tr") }
      sleep 10
      rows = @driver.find_elements(:xpath, "//tr")
      row_num = rows.size
      if row_num != 25
        rows[21..row_num - 4].each do |row|
          cells = row.find_elements(:css, "td").map { |a| a.text.strip.gsub(",", "") }
          point = cells[4].split("\n")[3].gsub("予定ポイント：", "").gsub(" ポイント", "") if cells[4].split("\n")[3].present?
          begin
            if cells[0].size < 7
              @reservation_date = {
                date: Time.now.strftime("%F"),
                reservation_status: cells[0],
                reservation_date: cells[1].split("\n")[2],
                checkindate: cells[1].split("\n")[0],
                checkoutdate: cells[1].split("\n")[1],
                room_type: cells[2].split("\n")[0],
                reservation_number: cells[2].split("\n")[2].split(":")[1],
                payment_on_cash: cells[3].gsub("円", "").to_i,
                price: cells[2].split("\n")[1].split(":")[0].gsub("円人数", ""),
                guest_name: cells[4].split("\n")[0],
                guest_tel: cells[4].split("\n")[1].gsub("(", "").gsub(")", ""),
                point: point
              }
            else
              plan_number = cells[2].split("\n")[0].scan(/\(.+?\)/).last
              @reservation_date = {
                date: Time.now.strftime("%F"),
                hotel_id: @hotel.id,
                reservation_status: cells[0].split("\n\n")[1],
                reservation_date: cells[1].split("\n")[2],
                checkindate: cells[1].split("\n")[0],
                checkoutdate: cells[1].split("\n")[1],
                plan_name: cells[2].split("\n")[0],
                plan_number: plan_number.to_s.gsub("(", "").gsub(")", ""),
                room_type: cells[2].split("\n")[1],
                price: cells[2].split("\n")[2].split(":")[0].gsub("円人数", ""),
                ppl_num: cells[2].split("\n")[2].split(":")[1].gsub("(", "").gsub(")", ""),
                reservation_number: cells[2].split("\n")[3].gsub("予約番号:", ""),
                payment_on_cash: cells[3].gsub("円", "").to_i,
                member_name: cells[4].split("\n")[0],
                guest_name: cells[4].split("\n")[1],
                guest_tel: cells[4].split("\n")[2].gsub("(", "").gsub(")", ""),
                point: point
              }
            end
            puts "saved:#{@reservation_date}" if RakutenReservation.create(@reservation_date).valid?
          rescue StandardError => e
            puts e
          end
        end
      end
      @driver.quit
    end

    # def daily_data_past
    #   @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[2]/tbody/tr[1]/td[1]/table/tbody/tr/td[3]/a/img").click
    #   @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[5]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr/td[1]/input").click
    #   sleep 3
    #   (0..13).each do |i|
    #     select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_date"))
    #     select.select_by(:index, i)
    #     display_data = @driver.find_element(:xpath, '//input[@value = "表示"]')
    #     display_data.click
    #     rows = @driver.find_elements(:xpath, "//tr")
    #     rows[27..58].map do |row|
    #       cells = row.find_elements(:css, "td[align=RIGHT]").map { |a| a.text.strip.gsub(",", "") }
    #       break unless cells[5] && cells[5].to_i > 1
    #       {
    #         date: cells[0],
    #         reservation_sales: cells[1],
    #         access_ppl: cells[2],
    #         cvr: cells[3],
    #         reservation_unit_price: cells[4],
    #         pv: cells[5],
    #         pc_retained: cells[6],
    #         pc_deliveries: cells[7],
    #         pc_total_delivered: cells[8],
    #         sp_retained: cells[9],
    #         sp_deliveries: cells[10],
    #         sp_total_delivered: cells[11]
    #       }
    #     end
    #   end
    # end

    def daily_data
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[2]/tbody/tr[1]/td[1]/table/tbody/tr/td[3]/a/img").click
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[5]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr/td[1]/input").click
      sleep 3
      if Time.now.day == 1
      else
        value = if Time.now.month.to_s.size == 2
                  Time.now.year.to_s + Time.now.month.to_s + "01"
                else
                  Time.now.year.to_s + "0" + Time.now.month.to_s + "01"
                end
        select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "f_date"))
        select.select_by(:value, value)
      end
      @driver.find_element(:xpath, '//input[@value = "表示"]').click
      rows = @driver.find_elements(:xpath, "//tr")
      data = []
      rows[27..58].each do |row|
        cells = row.find_elements(:css, "td[align=RIGHT]").map { |a| a.text.strip.gsub(",", "") }
        break unless cells[5] && cells[5].to_i > 1
        data << {
          date: cells[0],
          reservation_sales: cells[1],
          access_ppl: cells[2],
          cvr: cells[3],
          reservation_unit_price: cells[4],
          pv: cells[5],
          pc_retained: cells[6],
          pc_deliveries: cells[7],
          pc_total_delivered: cells[8],
          sp_retained: cells[9],
          sp_deliveries: cells[10],
          sp_total_delivered: cells[11]
        }
      end
      data
    end

    def monthly_data_past
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[2]/tbody/tr[1]/td[1]/table/tbody/tr/td[3]/a/img").click
      @driver.find_element(:xpath, "/html/body/table[2]/tbody/tr/td[3]/table[5]/tbody/tr[2]/td[1]/table/tbody/tr[3]/td/table/tbody/tr/td[2]/input").click
      @driver.find_element(:xpath, "/html/body/center/table[1]/tbody/tr[2]/td/table/tbody/tr[2]/td/form/input[8]").click
      rows = @driver.find_elements(:xpath, "//tr")
      rows[19..31].map do |row|
        cells = row.find_elements(:css, "td").map { |a| a.text.strip.gsub(",", "") }
        break unless cells[9] && cells[9].to_i > 1
        {
          date: cells[0].gsub("/", "").to_s + "01",
          reservation_sales: cells[1],
          reservation_ppl: cells[2],
          access_ppl: cells[3],
          access_ppl_top_avg: cells[4],
          cvr: cells[5],
          cvr_top_avg: cells[6],
          reservation_unit_price: cells[7],
          reservation_unit_price_top_avg: cells[8],
          pv: cells[9],
          pv_top_avg: cells[10],
          rmail_list_num: cells[11],
          rmail_num: cells[12],
          rmail_delivery_num: cells[13],
          prize: cells[14]
        }
      end
    end
  end
end
