#!/usr/bin/env ruby
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "stub/odba"
require "minitest/autorun"
require "flexmock/minitest"
require "stub/cgi"
require "view/drugs/fachinfo"
require "view/drugs/ddd"
require "model/text"

module ODDB
  module View
    module Drugs
      class FiChangelogLink < HtmlGrid::Link
        attr_reader :grid
      end

      class FiChapterChooser < HtmlGrid::Composite
        attr_reader :grid
      end
    end
  end
end

class TestFiChapterChooserLink < Minitest::Test
  def teardown
    ODBA.storage = nil
    super
  end

  def setup
    @lookandfeel = flexmock("lookandfeel",
      lookup: "lookup",
      _event_url: "_event_url").by_default
    @session = flexmock("session",
      language: "de",
      lookandfeel: @lookandfeel,
      user_input: "user_input")
    @chapter = flexmock("chapter", heading: "title", has_photo?: false).by_default
    @document = flexmock("document",
      amzv: "amzv",
      name: @chapter,
      respond_to?: true)
    @pointer = flexmock("pointer", skeleton: "skeleton").by_default
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model",
      de: @document,
      pointer: @pointer,
      registrations: [registration])
    @link = ODDB::View::Drugs::FiChapterChooserLink.new("name", @model, @session)
  end

  def test_init
    assert_equal("_event_url", @link.init)
  end

  def test_init__title_empty
    flexmock(@pointer, skeleton: [:create])
    flexmock(@lookandfeel, event_url: "event_url")
    section = flexmock("section", subheading: "subheading")
    flexmock(@chapter,
      heading: "",
      sections: [section])
    assert_equal("event_url", @link.init)
  end

  def test_init__title_lookup
    @document.should_receive(:name2)
    @link = ODDB::View::Drugs::FiChapterChooserLink.new("name2", @model, @session)
    assert_equal("_event_url", @link.init)
  end
end

class TestFiChapterChooser < Minitest::Test
  def teardown
    ODBA.storage = nil
    super
  end

  def setup
    @lookup = flexmock("lookandfeel",
      disabled?: false,
      resource: nil,
      enabled?: false,
      attributes: {},
      _event_url: "_event_url")
    @lookup.should_receive(:enabled?).and_return(true)
    @state = flexmock("state")
    @lookup.should_receive(:lookup).by_default.and_return("lookup")
    @state.should_receive(:allowed?).by_default.and_return(nil)
    @session = flexmock("session",
      state: @state,
      language: "language",
      user_input: "user_input",
      user_agent: "Mozilla",
      lookandfeel: @lookup)
    @pointer = flexmock("pointer", skeleton: "skeleton")
    @language = flexmock("language", chapter_names: ["chapter_names"], change_log: [])
    atc_class = flexmock("atc_class")
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model",
      pointer: @pointer,
      language: @language,
      atc_class: atc_class,
      iksnrs: ["IKSNR"],
      registrations: [registration])
    @composite = ODDB::View::Drugs::FiChapterChooser.new(@model, @session)
  end

  def test_init
    expected = {[1, 1] => "chapter-tab", [2, 0] => "chapter-tab bold", [3, 0] => "chapter-tab bold", [0, 0, 2] => "chapter-tab", [0, 1] => "chapter-tab"}
    result = @composite.init
    assert_equal(expected.keys.sort, result.keys.sort)
    assert_equal(expected.values.sort, result.values.sort)
    assert_equal(expected, result)
  end

  def test_init__status_allowed
    @state.should_receive(:allowed?).and_return(true)
    expected = {[1, 1] => "chapter-tab", [2, 0] => "chapter-tab bold", [3, 0] => "chapter-tab bold", [0, 0, 2] => "chapter-tab", [0, 1] => "chapter-tab"}
    result = @composite.init
    assert_equal(expected.keys.sort, result.keys.sort)
    assert_equal(expected.values.sort, result.values.sort)
    assert_equal(expected, result)
  end

  def test_full_text
    @pointer = flexmock("pointer", skeleton: [:create])
    assert_equal(HtmlGrid::Link, @composite.full_text(@model, @session).class)
  end

  def test_document_print
    text = @composite.to_html(CGI.new)
    assert_match(/name="print"/, text)
    # assert_match(/Drucken/, text) # Don't know how to to mock this without spending time
  end
end

class TestFachinfoInnerComposite < Minitest::Test
  def test_init
    lookandfeel = flexmock("lookandfeel", lookup: "lookup")
    @session = flexmock("session", lookandfeel: lookandfeel)
    @model = flexmock("model", chapter_names: ["name"])
    @composite = ODDB::View::Drugs::FachinfoInnerComposite.new(@model, @session)
    expected = [[[0, 0], "name"]]
    assert_equal(expected, @composite.init)
  end
end

class TestFachinfoPreviewComposite < Minitest::Test
  def test_fachinfo_name
    lookandfeel = flexmock("lookandfeel", lookup: "lookup")
    @session = flexmock("session", lookandfeel: lookandfeel)
    @model = flexmock("model",
      name: "name",
      chapter_names: ["name"])
    @composite = ODDB::View::Drugs::FachinfoPreviewComposite.new(@model, @session)
    assert_equal("lookup", @composite.fachinfo_name(@model, @session))
  end
end

class TestFachinfoComposite < Minitest::Test
  def teardown
    ODBA.storage = nil
    super
  end

  def setup
    flexmock("attributes", chapter: nil, name: "Namen")
    lookandfeel = flexmock("lookandfeel",
      lookup: "lookup",
      resource: nil,
      enabled?: false,
      disabled?: false,
      attributes: {chapter: nil, name: "Namen"},
      _event_url: "_event_url")
    state = flexmock("state", allowed?: nil)
    @session = flexmock("session",
      lookandfeel: lookandfeel,
      language: "language",
      state: state,
      user_input: "user_input",
      user_agent: "Mozilla").by_default
    language = flexmock("language",
      name: "name",
      chapter_names: ["name"],
      links: {},
      change_log: [])
    pointer = flexmock("pointer", skeleton: "skeleton")
    @atc_clas = flexmock("atc_class").by_default
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model", ODDB::Fachinfo.new,
      language: language,
      pointer: pointer,
      atc_class: @atc_class,
      registrations: [registration],
      links: ["links"],
      has_photo?: false)
    @composite = ODDB::View::Drugs::FachinfoComposite.new(@model, @session)
    skip("Don't know hot to mock @composite.document")
  end

  def test_chapter_chooser
    assert_kind_of(ODDB::View::Drugs::FiChapterChooser, @composite.chapter_chooser(@model, @session))
  end

  def test_document__chapter_ddd
    flexmock(@atc_class, parent_code: "parent_code")
    flexmock(@session, user_input: "ddd")
    assert_kind_of(ODDB::View::Drugs::DDDTree, @composite.document(@model, @session))
  end

  def test_document__chapter_else
    assert_kind_of(ODDB::View::Chapter, @composite.document(@model, @session))
  end

  def test_document__chapter_nil
    flexmock(@session, user_input: nil)
    assert_kind_of(ODDB::View::Drugs::FachinfoInnerComposite, @composite.document(@model, @session))
  end
end

class TestEditFiChapterChooser < Minitest::Test
  def test_display_names
    photos = flexmock("photos", has_photo?: false)
    lookandfeel = flexmock("lookandfeel",
      lookup: "lookup",
      disabled?: false,
      resource: nil,
      enabled?: false,
      attributes: {},
      _event_url: "_event_url")
    state = flexmock("state", allowed?: nil)
    @session = flexmock("session",
      state: state,
      language: "language",
      lookandfeel: lookandfeel,
      photos: photos,
      user_input: "user_input")
    pointer = flexmock("pointer", skeleton: "skeleton")
    chapter = flexmock("chapter")
    language = flexmock("language",
      chapters: [chapter],
      change_log: [])
    atc_class = flexmock("atc_class")
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model",
      pointer: pointer,
      language: language,
      atc_class: atc_class,
      registrations: [registration],
      iksnrs: ["IKSNR"])
    @composite = ODDB::View::Drugs::EditFiChapterChooser.new(@model, @session)
    document = flexmock("document", chapters: "chapters")
    skip("Don't know how to TestEditFiChapterChooser")
    assert_equal("chapters", @composite.display_names(document))
  end
end

class TestRootFachinfoComposite < Minitest::Test
  def teardown
    ODBA.storage = nil
    super
  end

  def setup
    @table = ODDB::Text::Table.new
    @table.next_row!
    @table.next_cell!
    @table << "cell1"
    @table.next_cell!
    @table << "cell2"

    @lookup = flexmock("lookup", to_s: @table,
      gsub: nil)
    @lookandfeel = flexmock("lookandfeel",
      attributes: {},
      lookup: @lookup,
      enabled?: false,
      disabled?: false,
      base_url: "base_url",
      _event_url: "_event_url")
    state = flexmock("state", allowed?: nil)
    @session = flexmock("session",
      state: state,
      language: "language",
      lookandfeel: @lookandfeel,
      error: "error",
      user_input: "user_input")
    pointer = flexmock("pointer", skeleton: "skeleton")
    flexmock("language",
      name: "name")
    chapter = flexmock("chapter")
    language = flexmock("language",
      chapters: [chapter],
      chapter_names: [],
      name: "name",
      change_log: [])
    @company = flexmock("company",
      invoiceable?: nil,
      pointer: pointer)
    atc_class = flexmock("atc_class")
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model",
      name: "name",
      pointer: pointer,
      chapter: @model_chapter,
      company: @company,
      language: language,
      atc_class: atc_class,
      links: {},
      has_photo?: false,
      iksnrs: ["IKSNR"],
      registrations: [registration])
    @composite = ODDB::View::Drugs::RootFachinfoComposite.new(@model, @session)
  end

  def test_init
    assert_empty(@composite.init)
  end

  def test_chapter_view
    flexmock(@company, invoiceable?: true)
    chapter = flexmock("chapter")
    flexmock("document", chapter: chapter)
    flexmock(@session, error: nil)
    flexmock(@lookandfeel, base_url: "base_url")
    assert_equal(ODDB::View::Chapter, @composite.chapter_view("chapter").class)
  end

  def test_table_fachinfos
    skip("Don't know how to mock @composite.to_html")
    html = @composite.to_html(CGI.new)
    File.open("fachinfo.html", "w+") { |x|
      x.puts("<HTML><BODY>")
      x.write(html)
      x.puts("</HTML></BODY>")
    }
    expected = [
      "<br>",
      "name_base",
      "cell1",
      "cell2",
      "<br>xxxxx"
    ]
    expected.each { |line|
      assert(html.index(line), "missing: #{line}\nin:\n#{html}")
    }
  end
end

class TestFI_ChangeLogs < Minitest::Test
  def teardown
    ODBA.storage = nil
    super
  end

  def setup
    @lookup = flexmock("lookandfeel",
      disabled?: false,
      resource: nil,
      enabled?: false,
      attributes: {},
      _event_url: "_event_url")
    @lookup.should_receive(:enabled?).and_return(true)
    @state = flexmock("state")
    @lookup.should_receive(:lookup).by_default.and_return("lookup")
    @state.should_receive(:allowed?).by_default.and_return(nil)
    @session = flexmock("session",
      state: @state,
      language: "language",
      user_input: "user_input",
      user_agent: "Mozilla",
      lookandfeel: @lookup)
    @pointer = flexmock("pointer", skeleton: "skeleton")
    @text_item = ODDB::FachinfoDocument.new
    @text_item.add_change_log_item("Old_first_Text", "new_text")
    @text_item.add_change_log_item("Old_second_Text", "new_second_text")
    language = flexmock("language", chapter_names: ["chapter_names"], change_log: [@text_item.change_log])
    atc_class = flexmock("atc_class")
    registration = flexmock("registration", iksnr: "iksnr")
    @model = flexmock("model",
      pointer: @pointer,
      language: language,
      atc_class: atc_class,
      iksnrs: ["IKSNR"],
      registrations: [registration])
    @composite = ODDB::View::Drugs::FiChapterChooser.new(@model, @session)
  end

  def test_document_change_log
    text = @composite.to_html(CGI.new)
    assert_match(/name="change_log"/, text)
  end

  def test_document_change_log
    text = @composite.to_html(CGI.new)
    assert_match(/href/, text)
  end
end
