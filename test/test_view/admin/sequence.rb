#!/usr/bin/env ruby

# ODDB::View::Admin::TestSequence -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "stub/cgi"
require "view/additional_information"
require "view/admin/sequence"
require "htmlgrid/span"
require "model/sequence"
require "view/admin/registration"

class TestRootActiveAgents < Minitest::Test
  def setup
    lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:lookup)
      l.should_receive(:attributes).and_return({})
      l.should_receive(:event_url)
    end
    model = flexmock("model") do |m|
      m.should_receive(:pointer)
      m.should_receive(:iksnr).and_return("iksnr")
      m.should_receive(:seqnr).and_return("seqnr")
    end
    state = flexmock("state") do |s|
      s.should_receive(:model).and_return(model)
    end
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:user_input)
      s.should_receive(:state).and_return(state)
      s.should_receive(:app)
    end
    active_agent = flexmock("active_agent") do |m|
      m.should_receive(:is_active_agent).and_return(true)
      m.should_receive(:chemical_substance).and_return("chemical_substance")
      m.should_receive(:dose)
      m.should_receive(:more_info)
      m.should_receive(:substance)
      m.should_receive(:parent)
    end
    @dose = flexmock("dose", qty: "qty")
    @model = [active_agent]
    @agents = ODDB::View::Admin::RootActiveAgents.new(@model, @session)
  end

  def test_add
    assert_kind_of(HtmlGrid::Link, @agents.add("model"))
  end

  def test_composition
    assert_nil(@agents.composition)
  end

  def test_css_id
    assert_equal("active-agents-", @agents.css_id)
  end

  def test_delete
    assert_kind_of(HtmlGrid::Link, @agents.delete("model"))
  end

  def test_delete_composition
    assert_kind_of(HtmlGrid::Link, @agents.delete_composition("model"))
  end

  def test_dose
    model = flexmock("model", dose: @dose, chemical_substance: nil)
    assert_kind_of(HtmlGrid::InputText, @agents.dose(model))
  end

  def test_galenic_form
    flexmock(@session, language: "language")
    galenic_form = flexmock("galenic_form", language: "language")
    model = flexmock("model", galenic_form: galenic_form)
    assert_kind_of(HtmlGrid::InputText, @agents.galenic_form(model))
  end

  def test_name
    assert_equal("part[][0]", @agents.name("part"))
  end

  def test_unsaved
    assert_nil(@agents.unsaved(nil))
  end
end

class TestSequencePackage < Minitest::Test
  def setup
    lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:lookup)
      l.should_receive(:attributes).and_return({})
      l.should_receive(:event_url)
      l.should_receive(:_event_url)
      l.should_receive(:disabled?)
      l.should_receive(:enabled?)
      l.should_receive(:language)
    end
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:app)
      s.should_receive(:language)
      s.should_receive(:state)
      s.should_receive(:event)
      s.should_receive(:allowed?).by_default
    end
    compose = flexmock("compose") do |c|
      c.should_receive(:galenic_form)
    end
    @pointer = flexmock("pointer", to_csv: "registration,31706,sequence,01,package,017")
    active_agent = flexmock("active_agent") do |a|
      a.should_receive(:substance)
      a.should_receive(:dose)
      a.should_receive(:parent).and_return(compose)
      a.should_receive(:ikscd).and_return("ikscd")
      a.should_receive(:commercial_forms).and_return([])
      a.should_receive(:size)
      a.should_receive(:empty?)
      a.should_receive(:price_exfactory)
      a.should_receive(:price_public)
      a.should_receive(:sl_entry)
      a.should_receive(:pointer).and_return(@pointer)
    end
    substance = flexmock("substance", language: "language")
    method = flexmock("method", arity: 1)
    @model = flexmock("model",
      empty?: false,
      ikscd: "ikscd",
      substance: substance,
      each_with_index: active_agent,
      first: active_agent,
      method: method).by_default
    @agents = ODDB::View::Admin::SequencePackages.new(@model, @session)
  end

  def test_ikscd
    flexmock(@session, allowed?: true)
    flexmock(@model, pointer: @pointer)
    assert_kind_of(ODDB::View::PointerLink, @agents.ikscd(@model))
  end
end

class TestSequenceInnerComposite < Minitest::Test
  def setup
    lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup)
      l.should_receive(:language)
      l.should_receive(:event_url)
    end
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(lookandfeel)
      s.should_receive(:error)
    end
    @model = flexmock("model") do |m|
      m.should_receive(:atc_class)
    end
    @composite = ODDB::View::Admin::SequenceInnerComposite.new(@model, @session)
  end

  def test_atc_class
    assert_kind_of(HtmlGrid::Value, @composite.atc_class(@model, @session))
  end

  def test_atc_descr
    atc_class = flexmock("atc_class", description: "desc")
    flexmock(@model, atc_class: atc_class)
    assert_kind_of(NilClass, @composite.atc_descr(@model, @session))
  end

  def test_atc_request
    flexmock(@model, atc_request_time: Time.now - 60 * 60 * 24 * 3 - 100)
    assert_equal("3 ", @composite.atc_request(@model, @session))
  end

  def test_atc_request__within_today
    flexmock(@model, atc_request_time: Time.now - 60 * 60 * 20 - 100)
    assert_equal("20 ", @composite.atc_request(@model, @session))
  end

  def test_atc_request__else
    flexmock(@model, atc_request_time: nil)
    assert_kind_of(HtmlGrid::Button, @composite.atc_request(@model, @session))
  end
end

class TestSequenceForm < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup)
      l.should_receive(:language)
      l.should_receive(:event_url)
      l.should_receive(:_event_url)
    end
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
    end
    @model = flexmock("model") do |m|
      m.should_receive(:atc_class).by_default
      m.should_receive(:seqnr).by_default
    end
    @composite = ODDB::View::Admin::SequenceForm.new(@model, @session)
  end

  def test_reorganize_components__regulatory_email
    company = flexmock("company", regulatory_email: nil)
    flexmock(@model) do |m|
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:company).and_return(company)
    end
    assert_equal(:regulatory_email, @composite.reorganize_components)
  end

  def test_reorganize_components__atc_request
    company = flexmock("company", regulatory_email: "email")
    flexmock(@model) do |m|
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:company).and_return(company)
    end
    assert_equal(:atc_request, @composite.reorganize_components)
  end

  def test_reorganize_components__no_company
    flexmock(@model) do |m|
      m.should_receive(:is_a?).and_return(true)
      m.should_receive(:company)
    end
    assert_equal(:no_company, @composite.reorganize_components)
  end

  def test_reorganize_components__submit
    assert_equal(:submit, @composite.reorganize_components)
  end

  def test_assign_patinfo
    flexmock(@model, has_patinfo?: true)
    assert_kind_of(HtmlGrid::Link, @composite.assign_patinfo(@model, @session))
  end

  def test_assing_patinfo__else
    flexmock(@model, has_patinfo?: false)
    assert_kind_of(HtmlGrid::Link, @composite.assign_patinfo(@model, @session))
  end

  def test_atc_descr_error?
    atc_class = flexmock("atc_class", description: "")
    flexmock(@model, atc_class: atc_class)
    assert(@composite.atc_descr_error?)
  end

  def test_atc_descr
    atc_class = flexmock("atc_class", description: "")
    flexmock(@model, atc_class: atc_class)
    assert_kind_of(HtmlGrid::InputText, @composite.atc_descr(@model, @session))
  end

  def test_delete_item
    assert_kind_of(HtmlGrid::Button, @composite.delete_item(@model, @session))
  end

  def test_delete_patinfo
    flexmock(@model, has_patinfo?: true)
    assert_kind_of(HtmlGrid::Button, @composite.delete_patinfo(@model, @session))
  end

  def test_language_select
    assert_kind_of(ODDB::View::Admin::FachinfoLanguageSelect, @composite.language_select(@model, @session))
  end

  def test_seqnr
    assert_kind_of(HtmlGrid::InputText, @composite.seqnr(@model, @session))
  end

  def test_seqnr__else
    flexmock(@model, seqnr: "seqnr")
    assert_kind_of(HtmlGrid::Value, @composite.seqnr(@model, @session))
  end

  def test_patinfo
    flexmock(@model) do |m|
      # The following methods are defined in additional_information.rb
      m.should_receive(:has_patinfo?).and_return(true)
      m.should_receive(:pdf_patinfo).and_return("pdf_patinfo")
    end
    flexmock(@lookandfeel) do |l|
      l.should_receive(:resource_global)
    end
    assert_kind_of(HtmlGrid::PopupLink, @composite.patinfo(@model, @session))
  end

  def test_patinfo_else
    patinfo = flexmock("patinfo", pointer: "pointer")
    flexmock(@model) do |m|
      # The following methods are defined in additional_information.rb
      m.should_receive(:has_patinfo?).and_return(true)
      m.should_receive(:pdf_patinfo).and_return(false)
      m.should_receive(:patinfo).and_return(patinfo)
      m.should_receive(:iksnr).and_return("iksnr")
      m.should_receive(:seqnr).and_return("seqnr")
    end
    flexmock(@lookandfeel) do |l|
      l.should_receive(:resource_global)
    end
    assert_kind_of(HtmlGrid::Link, @composite.patinfo(@model, @session))
  end

  def test_patinfo__nil
    flexmock(@model) do |m|
      m.should_receive(:has_patinfo?)
    end
    assert_nil(@composite.patinfo(@model, @session))
  end

  def test_profile_link
    company = flexmock("company", pointer: "pointer")
    flexmock(@model, company: company)
    assert_kind_of(HtmlGrid::Link, @composite.profile_link(@model, @session))
  end

  def test_patinfo_label
    assert_kind_of(HtmlGrid::LabelText, @composite.patinfo_label(@model, @session))
  end

  def test_patinfo_upload
    pointer = flexmock("pointer", to_csv: "pointer")
    company = flexmock("company") do |c|
      c.should_receive(:invoiceable?)
      c.should_receive(:pointer).and_return(pointer)
    end
    flexmock(@model, company: company)
    assert_kind_of(ODDB::View::PointerLink, @composite.patinfo_upload(@model, @session))
  end

  def test_patinfo_upload__invoiceable
    company = flexmock("company") do |c|
      c.should_receive(:invoiceable?).and_return(true)
    end
    flexmock(@model, company: company)
    assert_kind_of(HtmlGrid::InputFile, @composite.patinfo_upload(@model, @session))
  end
end

class TestSequenceComposite < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return("lookup")
      l.should_receive(:language)
      l.should_receive(:event_url)
      l.should_receive(:_event_url)
      l.should_receive(:disabled?)
      l.should_receive(:enabled?)
    end
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:language).and_return("language")
      s.should_receive(:app)
      s.should_receive(:state)
      s.should_receive(:event)
      s.should_receive(:allowed?)
    end
    substance = flexmock("substance") do |s|
      s.should_receive(:language).and_return("language")
    end
    active_agent = flexmock("active_agent") do |a|
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:is_active_agent).and_return true
      a.should_receive(:more_info)
      a.should_receive(:dose)
      a.should_receive(:parent)
    end
    excipiens = flexmock("excipiens") do |a|
      a.should_receive(:substancexx)
    end
    galenic_form = flexmock("galenic_form") do |g|
      g.should_receive(:language).and_return("language")
    end
    composition = flexmock("composition") do |c|
      c.should_receive(:galenic_form).and_return(galenic_form)
      c.should_receive(:corresp).and_return("corresp")
      c.should_receive(:source).and_return("source")
      c.should_receive(:label).and_return("label")
      c.should_receive(:excipiens).and_return(excipiens)
      c.should_receive(:active_agents).and_return([active_agent])
      c.should_receive(:inactive_agents).and_return([])
    end
    commercial_form = flexmock("commercial_form")
    pointer = flexmock("pointer", to_csv: "pointer")
    @package = flexmock("package") do |p|
      p.should_receive(:ikscd).and_return("ikscd")
      p.should_receive(:pointer).and_return(pointer)
      p.should_receive(:commercial_forms).and_return([commercial_form])
      p.should_receive(:parts).and_return([])
      p.should_receive(:price_exfactory)
      p.should_receive(:price_public)
      p.should_receive(:sl_entry)
    end
    division = flexmock("division",
      divisable: "divisable",
      dissolvable: "dissolvable",
      crushable: "crushable",
      openable: "openable",
      notes: "notes",
      empty?: true,
      source: "source")
    @model = flexmock("model") do |m|
      m.should_receive(:atc_class)
      m.should_receive(:seqnr)
      m.should_receive(:company)
      m.should_receive(:name)
      m.should_receive(:division).and_return(division)
      m.should_receive(:compositions).and_return([composition])
      m.should_receive(:packages).and_return({"key" => @package})
      m.should_receive(:pointer)
      m.should_receive(:bag_compositions).and_return([])
    end
    @composite = ODDB::View::Admin::SequenceComposite.new(@model, @session)
  end

  def test_division
    result = @composite.division(@model, @session)
    assert_kind_of(ODDB::View::Drugs::DivisionComposite, result)
    assert(/<TD>divisable<\/TD>/.match(result.to_html(CGI.new)))
  end

  def test_compositions
    assert_kind_of(ODDB::View::Admin::Compositions, @composite.compositions(@model, @session))
  end

  def test_source
    flexmock(@package) do |p|
      p.should_receive(:swissmedic_source)
    end
    flexmock(@model) do |m|
      m.should_receive(:source)
    end
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end

class TestRootSequenceForm < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return("lookup")
      l.should_receive(:event_url)
      l.should_receive(:base_url)
    end
    state = flexmock("state")
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:language).and_return("language")
      s.should_receive(:state).and_return(state)
      s.should_receive(:app)
    end
    agent = flexmock("agent") do |a|
      a.should_receive(:is_active_agent).and_return(true)
      a.should_receive(:dose)
      a.should_receive(:substance)
      a.should_receive(:more_info)
      a.should_receive(:parent)
    end
    excipiens = flexmock("excipiens")
    galenic_form = flexmock("galenic_form", language: "language")
    composition = flexmock("composition") do |c|
      c.should_receive(:excipiens).and_return(excipiens)
      c.should_receive(:galenic_form).and_return(galenic_form)
      c.should_receive(:label).and_return("label")
      c.should_receive(:corresp).and_return("corresp")
      c.should_receive(:inactive_agents).and_return([agent])
      c.should_receive(:active_agents).and_return([agent])
      c.should_receive(:excipiens).and_return(excipiens)
    end
    division = flexmock("division",
      divisable: "divisable",
      dissolvable: "dissolvable",
      crushable: "crushable",
      openable: "openable",
      notes: "notes",
      source: "source")
    @model = flexmock("model") do |m|
      m.should_receive(:atc_class)
      m.should_receive(:seqnr)
      m.should_receive(:compositions).and_return([composition])
      m.should_receive(:iksnr).and_return("iksnr")
      m.should_receive(:seqnr).and_return("seqnr")
      m.should_receive(:division).and_return(division)
    end
    flexmock(state, model: @model)
    @form = ODDB::View::Admin::RootSequenceForm.new(@model, @session)
  end

  def test_compositions
    assert_kind_of(ODDB::View::Admin::RootCompositions, @form.compositions(@model, @session))
  end

  def test_hidden_fields
    flexmock(@lookandfeel) do |l|
      l.should_receive(:flavor)
      l.should_receive(:language)
    end
    flexmock(@session, zone: "zone")
    context = flexmock("context", hidden: "hidden")
    expected = "hiddenhiddenhiddenhiddenhiddenhidden"
    assert_equal(expected, @form.hidden_fields(context))
  end
end

class TestResellerSequenceComposite < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel") do |l|
      l.should_receive(:attributes).and_return({})
      l.should_receive(:lookup).and_return("lookup")
      l.should_receive(:language)
      l.should_receive(:event_url)
      l.should_receive(:_event_url)
      l.should_receive(:disabled?)
      l.should_receive(:enabled?)
      l.should_receive(:base_url)
    end
    state = flexmock("state")
    @session = flexmock("session") do |s|
      s.should_receive(:lookandfeel).and_return(@lookandfeel)
      s.should_receive(:error)
      s.should_receive(:warning?)
      s.should_receive(:error?)
      s.should_receive(:info?)
      s.should_receive(:language).and_return("language")
      s.should_receive(:app)
      s.should_receive(:state).and_return(state)
      s.should_receive(:event)
      s.should_receive(:allowed?)
    end
    substance = flexmock("substance") do |s|
      s.should_receive(:language).and_return("language")
    end
    active_agent = flexmock("active_agent") do |a|
      a.should_receive(:is_active_agent).and_return(true)
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:dose)
      a.should_receive(:more_info)
      a.should_receive(:parent)
    end
    excipiens = flexmock("excipiens") do |a|
      a.should_receive(:substancexx)
    end
    galenic_form = flexmock("galenic_form", language: "language")
    composition = flexmock("composition") do |c|
      c.should_receive(:active_agents).and_return([active_agent])
      c.should_receive(:inactive_agents).and_return([])
      c.should_receive(:excipiens).and_return(excipiens)
      c.should_receive(:galenic_form).and_return(galenic_form)
      c.should_receive(:label).and_return("label")
      c.should_receive(:corresp).and_return("corresp")
    end
    commercial_form = flexmock("commercial_form")
    pointer = flexmock("pointer", to_csv: "pointer")
    @package = flexmock("package") do |p|
      p.should_receive(:ikscd).and_return("ikscd")
      p.should_receive(:pointer).and_return(pointer)
      p.should_receive(:commercial_forms).and_return([commercial_form])
      p.should_receive(:parts).and_return([])
      p.should_receive(:price_exfactory)
      p.should_receive(:price_public)
      p.should_receive(:sl_entry)
      p.should_receive(:swissmedic_source)
    end
    @model = flexmock("model") do |m|
      m.should_receive(:atc_class)
      m.should_receive(:seqnr)
      m.should_receive(:company)
      m.should_receive(:name)
      m.should_receive(:compositions).and_return([composition])
      m.should_receive(:packages).and_return({"key" => @package})
      m.should_receive(:pointer)
      m.should_receive(:source)
      m.should_receive(:division).and_return("division")
      m.should_receive(:iksnr).and_return("iksnr")
      m.should_receive(:seqnr).and_return("seqnr")
    end
    flexmock(state, model: @model)
    @composite = ODDB::View::Admin::ResellerSequenceComposite.new(@model, @session)
  end

  def test_compositions
    assert_kind_of(ODDB::View::Admin::RootCompositions, @composite.compositions(@model, @session))
  end
end
