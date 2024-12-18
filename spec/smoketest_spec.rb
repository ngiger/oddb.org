#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'paypal_helper'

@workThread = nil

describe "ch.oddb.org" do
  VALID_ONLY_TRADEMARK_EXAMPLE = 'canesten'

  before :all do
    @idx = 0
    @all_search_limitations = ["search_limitation_A", "search_limitation_B", "search_limitation_C", "search_limitation_D", "search_limitation_E",
            "search_limitation_SL_only", "search_limitation_valid"]
    waitForOddbToBeReady(@browser, ODDB_URL)
    @browser.link(name: 'search_instant').click unless   @browser.link(name: 'search_instant').text.eql?('Instant')
    @direktvergleich = 'Für den Direktvergleich klicken Sie'
  end

  before :each do
    @browser.goto ODDB_URL
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
  end

  def check_nutriflex_56091(text)
    expect(text).to match /Bezeichnung/i
    expect(text).to match /Galenische Form/i
    expect(text).to match /Excipiens/i
    expect(text).to match /Wirkstoff/i
    expect(text).to match /Isoleucin/i
    expect(text).to match /Hilfsstoff/i
    expect(text).to match /Citratsäure/i
  end

  describe "admin" do
    before :all do
    end
    before :each do
      skip "We do not run these tests when testing_ch_oddb_org" unless testing_ch_oddb_org
      @browser.goto ODDB_URL
      logout
      login(ADMIN_USER, ADMIN_PASSWORD)
    end
    after :all do
      logout
    end
  it "admin should edit package info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    text = @browser.text.clone
    skip 'check_nutriflex_56091 only works with sequence, not with package'
    check_nutriflex_56091(text)
    expect(text).to match /Patinfo aktivieren/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match ODDB_URL
  end

  it "admin should edit sequence info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091/seq/02"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    text = @browser.text.clone
    expect(text).to match /Patinfo aktivieren/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(text).to match /Wirkstoffe.+Arginin.+Isoleucin/im # correct sort order
    check_nutriflex_56091(text)
    expect(@browser.url).to match ODDB_URL
  end

  it "admin should edit registration info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/drug/reg/56091"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    text = @browser.text.clone
    expect(text).to match /Fachinfo-Upload/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match ODDB_URL
  end
  end
  describe 'desitin' do
    before :each do
      login
    end
  it "should display the correct color Pethidin" do
    @browser.select_list(name: "search_type").select("Markenname")
    @browser.text_field(name: "search_query").set('Pethidin')
    sleep(0.1)
    @browser.button(name: "search").click
    @browser.element(id: 'ikscat_1').wait_until(&:present?)
    expect(@browser.element(id: 'ikscat_1').text).to eq 'A+ / SL'
    expect(@browser.link(visible_text: 'FI').exists?).to eq true
    expect(@browser.link(visible_text: 'PI').exists?).to eq true
    expect(@browser.td(visible_text: 'A+').exists?).to eq true
    expect(@browser.td(visible_text: 'C').exists?).to eq false
    expect(@browser.link(visible_text: 'FB').exists?).to eq true
    td = @browser.td(visible_text: /Pethidin/i)
    expect(td.style('background-color')).to match /0, 0, 0, 0/
    selbstbehalt =   @browser.span(:text => /A+.+\/.+SL/).present?
    selbstbehalt =   @browser.span(:text => /A+.+\/.+SL/).wait_until(&:present?)
  end

  it "should display a limitation link for Sevikar" do
    @browser.select_list(name: "search_type").select("Markenname")
    @browser.text_field(name: "search_query").set('Sevikar')
    sleep(0.1)
    @browser.button(name: "search").click
    @browser.element(id: 'ikscat_1').wait_until(&:present?)
    td = @browser.td(:class =>/^list/, visible_text: /^Sevikar/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(@browser.element(id: 'ikscat_1').text).to eq 'B / SL / SO'
    expect(@browser.link(visible_text: 'L').exists?).to eq true
    expect(@browser.link(visible_text: 'L').href).to match /limitation_text\/reg/
    expect(@browser.link(visible_text: 'FI').exists?).to eq true
    expect(@browser.link(visible_text: 'PI').exists?).to eq true
    expect(@browser.td(visible_text: 'A').exists?).to eq false
    expect(@browser.td(visible_text: 'C').exists?).to eq false
#    @browser.link(visible_text: '10%').exists?.should eq true
    expect(@browser.link(visible_text: 'FB').exists?).to eq true
  end

  it "should display lamivudin with SO and SG in category (price comparision)" do
    @browser.select_list(name: "search_type").select("Preisvergleich")
    @browser.text_field(name: "search_query").set('lamivudin')
    sleep(0.1)
    @browser.button(name: "search").click
    @browser.element(id: 'ikscat_1').wait_until(&:present?)
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SO')}.exists?).to eq true
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SG')}.exists?).to eq true

    # Check link to price history for price publie
    td = @browser.td(:class => /pubprice/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(td.links.first.href).to match /\/price_history\//

    # Check link to price history for ex factory price
    td = @browser.td(:class => /list right/, visible_text: /\d+\.\d+/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(td.links.first.href).to match /\/price_history\//
  end

  it "should display Für den Preisvergleich in search result at the bottom" do
    medi = 'lamivudin'
    select_product_by_trademark(medi)
    inhalt = @browser.text.clone
    expect(/#{@direktvergleich}[^\n]*\nWillkommen #{A_USER_FIRST_NAME} #{A_USER_NAME}/i).to match(inhalt)
    expect(/#{medi}.*#{@direktvergleich}/im).to match(inhalt)
    expect(/#{@direktvergleich}.*#{medi}/im).not_to match(inhalt)
  end

  it "should display Für den Preisvergleich in the price comparision" do
    medi = 'lamivudin'
    select_product_by_trademark(medi)
    expect(@browser.link(name: 'best_result').present?).to be true
    @browser.link(name: 'best_result').click
    inhalt = @browser.text.clone
    expect(/#{@direktvergleich}[^\n]*\nWillkommen #{A_USER_FIRST_NAME} #{A_USER_NAME}/i).to match(inhalt)
    expect(/#{medi}.*#{@direktvergleich}/im).to match(inhalt)
    expect(/#{@direktvergleich}.*#{medi}/im).not_to match(inhalt)
  end

  it "should display two differnt prices for 55717 daTSCAN TM 123 I-Ioflupane " do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/price_history/reg/55717/seq/01/pack/002"
    inhalt = @browser.text.clone
    first_index  = inhalt.index(/01.03.2012.*936.61.*1149.20/)
    second_index = inhalt.index(/01.03.2010.*1070.00.*1294.25/)
    expect(first_index).not_to be nil
    expect(second_index).not_to be nil
    expect(first_index < second_index)
  end

  it "should show a registration info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    text = @browser.text.clone
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match ODDB_URL
  end

  it "should show a sequence info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091/seq/02"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    check_nutriflex_56091(@browser.text.clone)
    expect(@browser.url).to match ODDB_URL
  end

  it "should show a package info" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    check_nutriflex_56091(@browser.text.clone)
    expect(@browser.url).to match ODDB_URL
  end

  it "should contain Open Drug Database" do
    waitForOddbToBeReady(@browser, ODDB_URL)
    expect(@browser.url).to match    ODDB_URL      unless ['just-medical'].index(Flavor)
    expect(@browser.title).to match /Open Drug Database/i
  end

  it "should not be offline" do
    expect(@browser.text).not_to match /Es tut uns leid/
  end

  it "should have a link to the migel" do
    @browser.link(visible_text: 'MiGeL').click
    @browser.link(name: 'migel_alphabetical').wait_until(&:present?)
    expect(@browser.text).to match /Pflichtleistung/
    expect(@browser.text).to match /Mittel und Gegenst/ # Mittel und Gegenstände
  end unless ['just-medical'].index(Flavor)

  it "should find Aspirin" do
    @browser.text_field(name: "search_query").set("Aspirin")
    @browser.button(name: "search").click
    @browser.link(name: 'name').wait_until(&:present?)
    expect(@browser.text).to match /Aspirin 500|ASS Cardio Actavis 100 mg|Aspirin Cardio 300/
  end

  it "should find inderal" do
    @browser.text_field(name: "search_query").set("inderal")
    @browser.button(name: "search").click; sleep(1)
    expect(@browser.text).to match /Inderal 10 mg/
    expect(@browser.text).to match /Inderal 40 mg/
  end

  it "should display plus/minus signs for feedbacks" do
    # Found an example with + and - sign via bin/admin
    # sorted_feedbacks.find_all{ |x| !x.experience && x.time.year > 2010}.first.item.sequence
    @browser.goto(ODDB_URL+'/de/gcc/feedbacks/reg/62126/seq/02/pack/005')
    text = @browser.text.dup
    expect(text).to match /Persönliche Erfahrung.+\-.+Empfehlung/m
    expect(text).to match /Empfehlung.+\+.+Persönlicher Eindruck/m
  end

  # TODO: Niklaus: 2024.02.29 I do not have the energy to setup the watri chrome correctly
  it "should find redirect an iphone to the mobile flavor" do
    begin
      iphone_ua =  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
      new_options = @browser_options.clone
      new_options.args << "--user-agent=#{iphone_ua}"
      iphone_browser = Watir::Browser.new  :chrome, options: new_options
      iphone_browser.goto 'http://www.useragentstring.com/';
      txt = iphone_browser.text.clone
      expect(iphone_browser.textarea(id: "uas_textfeld").value).to eql iphone_ua
      expect(txt).to match /AppleWebKit/
      expect(txt).to match /Mobile/
      expect(txt).not_to match(/Fachinfo-Online/)
      expect(txt).not_to match(/Feedback/)
      iphone_browser.goto ODDB_URL
    ensure
      iphone_browser.close if iphone_browser
    end
  end

  it "should trigger the limitation after maximal 5 queries" do
    begin
      logout
      names = [ 'ipramol', 'inderal', 'Sintrom', 'Prolia', 'Certican', 'Marcoumar', 'Augmentin']
      res = false
      saved = @idx
      names.each {
        |name|
          waitForOddbToBeReady(@browser, ODDB_URL)
          @browser.select_list(name: "search_type").select("Markenname")
          @browser.text_field(name: "search_query").set(name)
          @browser.button(name: "search").click
          @browser.link(name: 'name').wait_until(&:present?)
          createScreenshot(@browser, '_'+@idx.to_s)
          if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match(@browser.text)
            res = true
            break
          end
          @idx += 1
      }
      expect(res).to eql true
    ensure
      login
    end
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the english language versions" do
    @browser.goto ODDB_URL
    english = @browser.link(visible_text: 'English')
    english.wait_until(&:present?)
    english.click
    @browser.button(name: "search").wait_until(&:present?)
    expect(@browser.text).to match /Search for your favorite drug fast and easy/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the french language versions" do
    @browser.link(visible_text: /Français|French/i).wait_until(&:visible?)
    @browser.link(visible_text: /Français|French/i).click
    @browser.button(name: "search").wait_until(&:present?)
    expect(@browser.text).to match /Comparez simplement et rapidement les prix des médicaments/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the german language versions" do
    @browser.link(visible_text: /Deutsch|German/).click
    @browser.link(text: 'Abmelden').wait_until(&:present?)
    @browser.link(name: 'name').wait_until(&:present?)
    expect(@browser.text).to match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end unless ['just-medical'].index(Flavor)

  it "should open print patinfo in a new window" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/patinfo/reg/51795/seq/01"
    @browser.link(text: 'PI').wait_until(&:present?)
    windowSize = @browser.windows.size
    expect(@browser.url).to match ODDB_URL
    @browser.link(visible_text: 'Drucken').click
    @browser.link(name: 'name').wait_until(&:present?)
    expect(@browser.windows.size).to eq(windowSize + 1)
    # avoid indexing not reliable on WindowCollection
    @browser.switch_window
    expect(@browser.text).to match /^Ausdruck.*Patienteninformation/im
    expect(@browser.url).to match ODDB_URL
    @browser.window(url: ODDB_URL).close
  end

  it "should open a sequence specific patinfo" do # 15219 Zymafluor
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/15219"
    @browser.link(visible_text: 'PI').wait_until(&:present?)
    expect(@browser.link(visible_text: 'PI').exist?).to eq true
    @browser.link(visible_text: 'PI').click
    @browser.link.wait_until(&:present?)
    expect(@browser.url).to match /patinfo/i
  end

  it "should have a valid link for a Preis Anfrage" do
    login
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/45572/seq/01/pack/013"
    @browser.link(visible_text: 'PA').wait_until(&:present?)
    @browser.link(visible_text: 'PA').click
    expect(is_link_valid?(@browser.link(visible_text: 'PA').href)).to eq true
  end

  it "should open a package specific patinfo" do # 43788 Tramal
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/019"
    @browser.link(visible_text: 'PI').wait_until(&:present?)
    expect(@browser.link(visible_text: 'PI').exist?).to eq true
    @browser.link(visible_text: 'PI').click
    # As this opens a new window we must focus on it
    @browser.windows.last.use if @browser.windows.size > 1
    expect(@browser.url).to match /patinfo/i
    expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
    @browser.windows.last.close if @browser.windows.size > 1
  end

  it 'should work for two patinfo in two different registration' do
    ['/de/gcc/patinfo/reg/57489/seq/01',
     '/de/gcc/patinfo/reg/55297/seq/04',
     ].each do  |pi_url|
        @browser.goto "#{ODDB_URL}/#{pi_url}"
        expect(/NoMethodError/i.match(@browser.text)).to be nil
        expect(@browser.link(name: 'effects').present?).to be true
        expect(@browser.link(name: 'change_log').present?).to be true
        expect(@browser.link(name: 'print').present?).to be true
        @browser.link(name: 'effects').click
        @browser.back
        @browser.link(name: 'change_log').click

    end
  end
  it "should show correct Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe (4788/01/035)" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/035";
    @browser.link(visible_text: 'PI').wait_until(&:present?)
    expect(@browser.link(visible_text: 'PI').exist?).to eq true
    @browser.link(visible_text: 'PI').click;
    @browser.link.wait_until(&:present?)
    expect(@browser.url).to match /patinfo/i
    text = @browser.text.clone
    expect(text).to match /Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/
    expect(text).not_to match /Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/
  end

  it "should show correct Tramal Tropfen Lösung zum Einnehmen ohne Dosierpumpe(4788/01/086)" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/show/reg/43788/seq/01/pack/086"
    @browser.link(visible_text: 'PI').wait_until(&:present?)
    expect(@browser.link(visible_text: 'PI').exist?).to eq true
    @browser.link(visible_text: 'PI').click
    @browser.link.wait_until(&:present?)
    expect(@browser.url).to match /patinfo/i
    text = @browser.text.clone
    expect(text).to match /Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/
    expect(text).not_to match /Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/
  end

  it "should open print fachinfo in a new window" do
    @browser.goto "#{ODDB_URL}/de/#{Flavor}/fachinfo/reg/51795"
    @browser.link(visible_text: /Drucken/i).wait_until(&:present?)
    expect(@browser.url).to match ODDB_URL
    windowSize = @browser.windows.size
    @browser.link(visible_text: /Drucken/i).click
    expect(@browser.windows.size).to eq(windowSize + 1)
    @browser.switch_window
    expect(@browser.text[0..200]).to match /^Ausdruck.*Fachinformation/im
    expect(@browser.url).to match ODDB_URL
    @browser.window(url: ODDB_URL).close
  end

  it "should be possible to request a new password" do
    @browser.link(visible_text: 'Abmelden').click if @browser.link(visible_text: 'Abmelden').visible?
    @browser.link(visible_text: 'Anmeldung').wait_until(&:present?)
    @browser.link(visible_text: 'Anmeldung').click
    @browser.link(name: 'password_lost').wait_until(&:present?)
    @browser.link(name: 'password_lost').click
    @browser.text_field(name: 'email').wait_until(&:present?)
    @browser.text_field(name: 'email').set 'ngiger@ywesee.com'
    @browser.button(name: 'password_request').click
    url = @browser.url
    text = @browser.text
    expect(url).not_to match /error/i
    expect(text).to match /Bestätigung/
    expect(text).to match /Vielen Dank. Sie erhalten in Kürze ein E-Mail mit weiteren Anweisungen./
  end

  it "should download the results of a search after paying with PayPal" do
    skip("Paypal login page is no longer usable with Watir")
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.text_field(name: "search_query").set(test_medi)
    @browser.button(name: "search").click
    @browser.button(value: "Resultat als CSV Downloaden").wait_until(&:present?)
    @browser.button(value: "Resultat als CSV Downloaden").click
    @browser.text_field(name: /name_last/i).value= "Mustermann"
    @browser.text_field(name: /name_first/i).wait_until(&:present?)
    @browser.text_field(name: /name_first/i).value= "Max"
    paypal_user = PaypalUser.new
    @browser.button(name: PaypalUser::CheckoutName).click
    expect(paypal_user.paypal_buy(@browser)).to eql true
    expect(@browser.url).not_to match  /errors/
    @browser.link(name: 'download').wait_until(&:present?)
    @browser.link(name: 'download').click
    sleep(1) # Downloading might take some time
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
  end unless ['just-medical'].index(Flavor)

  def check_search_with_type
    query =  @browser.text_field(name: "search_query")
    expect(query.exists?).to eq true
    search_type = @browser.select_list(name: "search_type")
    expect(search_type.exists?).to eq true
  end

  it "should display search and search_type for fachinfo diff of 28.11.2015" do
    diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff/28.11.2015"
    @browser.goto(ODDB_URL + '/de/gcc' + diff_url)
    check_search_with_type
  end

  it "should display search and search_type for fachinfo diff" do
    diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff"
    @browser.goto(ODDB_URL + '/de/gcc' + diff_url)
    check_search_with_type
    link =  @browser.link(name: "change_log")
    expect(link.exists?).to eq true
    link.click
    check_search_with_type
  end

  it 'should display the correct calculation for Bicalutamid Sandoz' do
    @browser.goto(ODDB_URL + '/de/gcc/search/zone/drugs/search_query/Bicalutamid%20Sandoz/search_type/st_sequence?#best_result')
    tageskosten =  @browser.trs.find{|x| /^Tageskosten/.match(x.text)}.text
    expect(tageskosten).to match 'Tagesdosis 50 mg'
    expect(tageskosten).to match 'Publikumspreis 615.95 CHF'
    expect(tageskosten).to match '6.16 CHF / Tag'
    expect(tageskosten).to match 'Stärke 150 mg Packungsgrösse 100 Tablette'
    expect(tageskosten).to match /Berechnung \d+\.\d+.+= \d+\.\d+.CHF \/ Tag/
  end

    # this is very tricky!`
  def select_medi_via_instant(medi)
      @browser.link(visible_text: 'Instant').click if @browser.link(visible_text: 'Instant').exists?
      expect(@browser.text).to match /Art der Suche:\s*$\s*Plus/im
      0.upto(10).each{ |idx|
                      begin
                        chooser = @browser.text_field(id: 'searchbar')
                        chooser.set(medi)
                        sleep idx*0.1
                        chooser.send_keys(:down)
                        sleep idx*0.1
                        value = chooser.value
                        res = medi.match(value)
                        sleep 0.5
                        break if /#{medi}/i.match(value) and value.length > medi.length
                      rescue StandardError => e
                        puts "in rescue"
                        createScreenshot(@browser, "rescue_#{medi}_#{__LINE__}")
                        puts e.inspect
                        puts caller[0..5]
                        next
                      end
                      }
  end

  ['Inderal',
   'Augmentin'
   ].each do |medi|
    it "should have a working instant search for #{medi} and going back" do
      skip("backtrace does not work with Augmentin which contains ( in the link") if /Augmentin/i.match(medi)
      select_medi_via_instant(medi)
      url = @browser.url
      inhalt = @browser.text
      expect(inhalt).to match(/Preisvergleich für/i)
      expect(inhalt).to match(/#{medi}/i)
      expect(inhalt).to matgbgch(/Zusammensetzung/i)
      back_to_list = @browser.link(visible_text: /Liste/)
      old_text = @browser.text.clone
      expect(back_to_list.present?)
      # visit price_history
      price_history =  @browser.link(:href => /price_history/)
      price_history.click
      back_to_list = @browser.link(visible_text: /Liste/)
      expect(back_to_list.present?)
      back_to_list.click
      expect(@browser.text).to match medi
      expect(@browser.text).not_to match LeeresResult
    end
  end

  [ 'status_oddb',
   ].each do | name |
    it "should have a working status page #{name}" do
      @browser.goto(ODDB_URL + '/resources/downloads/'+ name)
      url = @browser.url
      inhalt = @browser.text
      m = /sessions:\s+(\d+).+threads:\s+(\d+).+memory:\s+(\d+)/.match(inhalt)
      expect(m).not_to be nil
      expect(m[1].to_i).to be >= 0 # sessions can be 0
      expect(m[2].to_i).to be > 0 # we must have at least one thread
      expect(m[3].to_i).to be > 0 # memory
      m2 = /^\s*(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+):/.match(inhalt)
      expect(m2).not_to be nil
      time = Time.parse(m2[0])
      diff_seconds = Time.now.to_i - time.to_i
      # * less than 5 minutes
      # require 'debug'; binding.break unless diff_seconds < 310
      puts "status page #{url} is too old #{time}" unless diff_seconds < 310
      expect(diff_seconds).to be < 310
    end
  end

  [ 'status_crawler',
   'status_google_crawler',
   'status_generika',
#   'status_just-medical',
   ].each do | name |
    it "should have a working status page #{name}" do
      @browser.goto(ODDB_URL + '/resources/downloads/'+ name)
      url = @browser.url
      inhalt = @browser.text
      m = /sessions:\s+(\d+).+threads:\s+(\d+).+memory:\s+(\d+)/.match(inhalt)
      skip("status page for #{name} may be absent when running under devenv") unless m
      expect(m).not_to be nil
      expect(m[1].to_i).to be >= 0 # sessions can be 0
      expect(m[2].to_i).to be > 0 # we must have at least one thread
      expect(m[3].to_i).to be > 0 # memory
      m2 = /^\s*(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+):/.match(inhalt)
      expect(m2).not_to be nil
      time = Time.parse(m2[0])
      diff_seconds = Time.now.to_i - time.to_i
      # * less than 5 minutes
      # require 'debug'; binding.break unless diff_seconds < 310
      puts "status page #{url} is too old #{time}" unless diff_seconds < 310
      expect(diff_seconds).to be < 310
    end
  end

  def verify_search_preferences(prefs)
    @user_pref_url = ODDB_URL + '/de/gcc/preferences'
    @browser.goto(@user_pref_url)
#    @all_search_limitations.each { |id|  @browser.checkbox(id: id).clear }
    for limitation in prefs do
      @browser.checkbox(id: limitation.to_s).set(true)
    end
    @browser.button(name: 'update').click
  end
  def set_search_preferences(prefs)
    @user_pref_url = ODDB_URL + '/de/gcc/preferences'
    @browser.goto(@user_pref_url)
    @all_search_limitations.each { |id|  @browser.checkbox(id: id).clear }
    for limitation in prefs do
      @browser.checkbox(id: limitation.to_s).set(true)
    end
    @browser.button(name: 'update').click
  end

  def get_nr_items
    return 0 if LeeresResult.match(@browser.text)
    list_title = @browser.span(:class => 'breadcrumb', visible_text: /\(.*\)/).text
    nr_items = /\((\d+)\)/.match(list_title)[1].to_i
  end
  # found using the following bin/admin (There are less < 1% of these cases)
  snippet1 = %(
    registrations.values.find{|x| x.active_packages.size > 0 && x.packages.size > x.active_packages.size }  # 48606 Gromazol
  )
  it 'should not display expired drugs, when search says active drugs only' do
    login
    set_search_preferences([])
    select_product_by_trademark(VALID_ONLY_TRADEMARK_EXAMPLE)
    nr_unrestricted_products = get_nr_items
    puts "found #{nr_unrestricted_products} unrestricted products for #{VALID_ONLY_TRADEMARK_EXAMPLE}"
    set_search_preferences([:search_limitation_valid])
    select_product_by_trademark(VALID_ONLY_TRADEMARK_EXAMPLE)
    nr_restricted_products = get_nr_items
    puts "found #{nr_restricted_products} restricted products for #{VALID_ONLY_TRADEMARK_EXAMPLE}"
    expect(nr_unrestricted_products).to be > 0
#    skip('Will probably fail if you did not search for one of the few examples via bin admin')
    expect(nr_unrestricted_products).to be > nr_restricted_products
    puts "Limit to only valid products succeeded for #{VALID_ONLY_TRADEMARK_EXAMPLE}" if nr_unrestricted_products > nr_restricted_products
  end

  # To find examples we used the following bin/admin snippet
  snippet = %(
  $cat = 'A';
  $examples = registrations.values.find_all{|x| x.packages.find_all{|pack| pack.ikscat && pack.ikscat.eql?($cat)}.size > 0 && x.packages.find_all{|pack|  pack.ikscat && !pack.ikscat.eql?($cat)}.size > 0  }
  # or SL onyl
  $examples = registrations.values.find_all{|x| x.packages.find_all{|pack| pack.sl_entry}.size > 0 && x.packages.find_all{|pack| !pack.sl_entry}.size > 0  }
  # 656
  )

  [
    [:search_limitation_A,  'Fosfolag', false],
    [:search_limitation_B,  'Allergo-X', true],
    # [:search_limitation_C,  'Allergo-X', true], #skipping per 22.1.2021
    [:search_limitation_D,  'Elmex', true],
    [:search_limitation_E,  'Holunder', true],
    [:search_limitation_SL_only,  'Soolantra 10 mg', true],
    [:search_limitation_SL_only,  'Methotrexat', true],
    [:search_limitation_SL_only,  'mephadolor', false],
    [:search_limitation_SL_only,  'Omeprazol MUT Sandoz', true],
    # Done in separate spec test, as one has to search often for an actual valid example
    #  :search_limitation_valid => VALID_ONLY_TRADEMARK_EXAMPLE,
    ].each do |example|
    limitation = example[0]
    drug_name  = example[1]
    must_be_greater  = example[2]
    it "limiting the search to #{limitation} using #{drug_name}" do
      login
      set_search_preferences([])
      select_product_by_trademark(drug_name)
      nr_unrestricted_first = get_nr_items
      expect(nr_unrestricted_first).to be > 0

      set_search_preferences([limitation])
      verify_search_preferences([limitation])
      @browser.goto(ODDB_URL)
      @browser.goto(@user_pref_url)
      expect(@browser.checkbox(id: limitation.to_s).set?).to be true
      select_product_by_trademark(drug_name)
      nr_restriced = get_nr_items
      categories =  @browser.elements(id: /ikscat_\d+$/).collect{|x| x.text}
      categories.each do |category| expect(/^|\sA[$|\s]/.match(category)).not_to be nil; end
      expect(categories.size).to eq nr_restriced
      expect(nr_restriced).to be > 0

      # Reset preferences to zer
      set_search_preferences([])
      select_product_by_trademark(drug_name)
      nr_unrestricted_second = get_nr_items
      puts "Testing nr items found with #{limitation} for #{drug_name} which returned #{nr_unrestricted_first}/#{nr_restriced}/#{nr_unrestricted_second} items. must_be_greater is #{must_be_greater}"
      expect(nr_unrestricted_second).to be > 0
      expect(nr_unrestricted_second).to eql nr_unrestricted_first
      expect(nr_unrestricted_first).to be > nr_restriced if must_be_greater
    end
  end
  it "should display a result for homeopathy Similasan Arnica" do
    url = ODDB_URL + "/de/homeopathy"
    @browser.goto(url)
    @browser.select_list(name: "search_type").select("Markenname")
    @browser.text_field(name: "search_query").set('Similasan Arnica')
    @browser.button(name: "search").click
    @browser.link(visible_text: 'PI').wait_until(&:visible?)
    text = @browser.text.clone
    expect(text[0..1000]).not_to match /traceback/i
    expect(text[0..1000]).to match /Homöopathika für Muskeln und Skelett/i
  end

  it "should display the ATC-Browser, way down to H05AA02" do
    @browser.link(name: 'atc_chooser').click
    text = @browser.text.clone
    expect(text[0..1000]).to match /\(A\)/
    expect(text[0..1000]).to match /\(V\)/
    @browser.link(:text => /.*\(H\)/).click
    @browser.link(:text => /.*\(H05\)/).click
    @browser.link(:text => /.*\(H05A\)/).click
    @browser.link(:text => /.*\(H05AA\)/).click
    @browser.link(:text => /.*\(H05AA02\)/).click
    text = @browser.text.clone
    expect(text[0..1000]).to match /Forsteo/
  end

  after :all do
    @browser.close if @browser
  end
  end
end
