#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::ResultList -- oddb.org -- 29.11.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::ResultList -- oddb.org -- 27.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::ResultList -- oddb.org -- 03.03.2003 -- aschrafl@ywesee.com

# require 'mathn'
require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/datevalue'
require 'htmlgrid/popuplink'
require 'htmlgrid/urllink'
require 'model/package'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/publictemplate'
require 'view/dataformat'
require 'view/resultcolors'
require 'view/descriptionvalue'
require 'view/lookandfeel_components'
require 'sbsm/user'

module HtmlGrid
	class List
		BACKGROUND_SUFFIX = ' bg' unless defined?(Minitest) && defined?(BACKGROUND_SUFFIX)
	end
end
module ODDB
	module View
		module Drugs
class User < SBSM::KnownUser; end
class UnknownUser < SBSM::UnknownUser; end
class RootUser < View::Drugs::User; end
class CompanyUser < View::Drugs::User; end
class AtcHeader < HtmlGrid::Composite
	include View::AdditionalInformation
  COMPONENTS = {
    [0,0,0]  => :atc_description,
    [0,0,2]  => :atc_ddd_link,
    [0,0,3]  => '&nbsp;',
    [0,0,4]  => :atc_optional_links,
    [1,0]    => :pages,
  }
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'atc list',
	}
  LEGACY_INTERFACE = false
	def init
    @link_separators = 0
		if(@session.allowed?('edit', 'org.oddb.model.!atc_class.*'))
			components.store([0,0,1], :edit)
		end
    if(@model.overflow? \
       && @session.cookie_set_or_get(:resultview) == "atc" \
       && @session.persistent_user_input(:code) == @model.code)
      @css_map = {
        [0,0,2] => 'migel-group list'
      }
    end
		super
	end
	def atc_description(model, session=@session)
    code = model.code
    link = HtmlGrid::Link.new(code, model, @session, self)
    link.value = [
			super,
			model.package_count,
			@lookandfeel.lookup(:products),
			nil,
		].join('&nbsp;')
    if(model.overflow?)
      args = []
      if(@session.persistent_user_input(:code) == code)
        args = [ :search_query, code ]
      else
        args = [
          :search_query, @session.persistent_user_input(:search_query).gsub('/', '%2F'),
          :search_type, @session.persistent_user_input(:search_type),
          :code, code
        ]
      end
      link.css_class = 'list'
      link.href = @lookandfeel._event_url(:search, args, code)
    end
    link
	end
  def atc_optional_links(model, session=@session)
    links = [
      :atc_drugbank_link,
      :atc_dosing_link,
    ].collect{ |link| self.send(link, *[model, session]) }.compact
    links.dup.each_with_index{ |l, i| links.insert(links.index(l), '&nbsp;-&nbsp;') unless i.zero? }
    links
  end
	def edit(model, session=@session)
		link = View::PointerLink.new(:code, model, session, self)
		link.value = @lookandfeel.lookup(:edit_atc_class) + "&nbsp;"
		link.attributes['class'] = 'small'
		link.href = @lookandfeel._event_url(:atc_class, {:atc_code => model.code})
		link
	end
	def pages(model, session=@session)
		state = @session.state
		if(@session.cookie_set_or_get(:resultview) == "pages" \
       && state.respond_to?(:pages) \
			 && (pages = state.pages) \
			 && pages.size > 1)
			args = {
				:search_query => @session.persistent_user_input(:search_query).gsub('/', '%2F'),
				:search_type => @session.persistent_user_input(:search_type),
			}
			View::Pager.new(pages, @session, self, :search, args)
		end
	end
end
class MailOrderPriceLogo < HtmlGrid::NamedComponent
  LOGO_PATH = "https://#{SERVER_NAME}/resources/zurrose/"
  def init
    super
    @index = 0 # latest one
  end
  def mail_order_index=(index)
    @index = index
  end
  def to_html(context)
    if @model.respond_to?(:mail_order_prices) and !@model.mail_order_prices.empty?
      price = @model.mail_order_prices[@index].price
      if price =~ /(Rab\.|Rabatt)$/u
        @attributes['src'] = LOGO_PATH + 'rose_orange.png'
        src = context.img(@attributes)
        src << "&nbsp;#{price}"
      else
        @attributes['src'] = LOGO_PATH + 'rose_gruen.png'
        src = context.img(@attributes)
        unless price.empty?
          src << '&nbsp;%.2f' % price.to_f
        end
      end
      src
    end
  end
end
class ResultList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
  include View::LookandfeelComponents
	COMPONENTS = {}
	REVERSE_MAP = {
		:company_name			=> false,
		:most_precise_dose=> false,
		:dsp							=> false,
		:galenic_form			=> false,
		:ikscat						=> false,
		:name_base				=> false,
		:price_exfactory	=> false,
		:price_public			=> false,
		:registration_date=> true,
		:size							=> false,
		:substances				=> true,
	}
	CSS_MAP = {}
  CSS_KEYMAP = {
    :active_agents      => 'list italic',
    :comarketing        => 'list',
    :company_name       => 'list italic',
    :comparable_size    => 'list right',
    :complementary_type => 'list',
    :compositions       => 'list italic',
    :ddd_price          => 'list bold right',
    :deductible         => 'list bold right',
    :fachinfo           => 'list',
    :feedback           => 'list right',
    :galenic_form       => 'list',
    :google_search      => 'list right',
    :ikscat             => 'list italic',
    :limitation_text    => 'list',
    :minifi             => 'list',
    :most_precise_dose  => 'list right',
    :name_base          => 'list big',
    :narcotic           => 'list',
    :notify             => 'list right',
    :patent             => 'list',
    :patinfo            => 'list',
    :price_exfactory    => 'list right',
    :price_public       => 'list pubprice',
    :registration_date  => 'list italic',
    :substances         => 'list italic',
    :twitter_share      => 'list right',
    :mail_order_price   => 'list bold',
    'nbsp'              => 'list',
  }
  CSS_HEAD_KEYMAP = {
    :active_agents      => 'th',
    :company_name       => 'th',
    :comparable_size    => 'th right',
    :complementary_type => 'th',
    :compositions       => 'th',
    :ddd_price          => 'th right',
    :deductible         => 'th right',
    :fachinfo           => 'th',
    :feedback           => 'th right',
    :galenic_form       => 'th',
    :google_search      => 'th right',
    :ikscat             => 'th',
    :limitation_text    => 'th',
    :minifi             => 'th',
    :most_precise_dose  => 'th right',
    :name_base          => 'th',
    :narcotic           => 'th',
    :notify             => 'th right',
    :patinfo            => 'th',
    :price_exfactory    => 'th right',
    :price_public       => 'th right',
    :registration_date  => 'th',
    :substances         => 'th',
    :twitter_share      => 'th',
    'nbsp'              => 'th',
  }
	CSS_HEAD_MAP = {}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	SUBHEADER = View::Drugs::AtcHeader
	SYMBOL_MAP = {
		:galenic_form				=>	View::DescriptionValue,
		:ikskey							=>	View::PointerLink,
	}
  LOOKANDFEEL_MAP = {
    :limitation_text => :ltext,
    :narcotic        => '', # plugin needs :th_narcotic
  }
  class << self
    def add_additional_mail_order_price_method(n)
      n.times do |i|
        define_method(('additional_mail_order_price'+i.to_s).to_sym) do |model, session|
          if model.mail_order_prices and model.mail_order_prices[i+1]
            link = HtmlGrid::Link.new(:mail_order_price, model, session, self)
            link.href = model.mail_order_prices[i+1].url
            link.target = '_blank'
            link.value = MailOrderPriceLogo.new(:mail_order_price, model, @session, self)
            link.value.mail_order_index = i+1
            link
          end
        end
      end
    end
  end
	def init
		reorganize_components(:result_list_components)
		super
	end
=begin
  def price_exfactory(model, session)
    'price_exfactory'
  end
  def price_public(model, session)
    'price_public'
  end
=end
  def mail_order_price(model, session=@session)
    if model.mail_order_prices and !model.mail_order_prices.empty?
      link = HtmlGrid::Link.new(:mail_order_price, model, session, self)
      link.href = model.mail_order_prices.first.url
      link.target = '_blank'
      link.value = MailOrderPriceLogo.new(:mail_order_price, model, @session, self)
      link
    end
  end
	def active_agents(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
		link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
		if model.active_agents.size > 1
			link.set_attribute('title', model.active_agents.join(', '))
			link.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
		else
			link.value = model.active_agents.to_s
		end
		link
	end
	def compose_list(model=@model, offset=[0,0])
    valid_search_types = []
    valid_search_types = @lookandfeel.search_type_selection if(@lookandfeel.respond_to?(:search_type_selection))
    if(model.respond_to?(:overflow?) && model.overflow?) &&
        (@lookandfeel.enabled?(:explain_atc) or valid_search_types.size > 1)
      x, y, = offset
      half = (full_colspan / 2).to_i
      @grid.add(explain_atc(model), x, y)
      @grid.add_style("list migel-group", x, y)
      @grid.set_colspan(x, y, half)
      @grid.add(resultview_switch(model), half, y)
      @grid.add_style("list migel-group right", half, y)
      @grid.set_colspan(half, y, full_colspan - half)
      offset = resolve_offset(offset, self::class::OFFSET_STEP)
    end

    code = @session.user_input(:code)
    if @session.get_cookie_input(:resultview) == 'atc'
        model = @model.model
    else # 'pages'
      if page = @session.user_input(:page)
        model = @session.state.pages[page]
      elsif code
        page = if code2page = @session.state.code2page
                 code2page[code]||0
               else
                 0
               end
        model = @session.state.pages[page]
      end 
    end

    code = @session.persistent_user_input(:code)
    if model
      model.sort{|x,y| x.code <=> y.code}.each { |atc|
        compose_subheader(atc, offset)
        offset = resolve_offset(offset, self::class::OFFSET_STEP)
        if(show_packages? || code == atc.code)
          packages = atc.packages
          super(packages, offset)
          offset[1] += packages.size
        end
      }
    end
	end
	def compose_subheader(atc, offset)
		subheader = self::class::SUBHEADER.new(atc, @session, self)
		@grid.add(subheader, *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
  def explain_atc(model)
    return nil unless @lookandfeel.enabled?(:explain_atc)
    link = HtmlGrid::Link.new(:explain_atc, model, @session, self)
    link.href = @lookandfeel.lookup(:explain_atc_url)
    link.css_class = 'list bold'
    link
  end
  def galenic_form(model, session=@session)
    lang = @session.language
    model.galenic_forms.collect { |gf| gf.send lang }.compact.join(' / ')
  end
	def fachinfo(model, session=@session)
		super(model, session, 'square important infos')
	end
	def registration_date(model, session=@session)
		span = HtmlGrid::Span.new(model, @session, self)
		span.value = HtmlGrid::DateValue.new(:registration_date,
																				 model, @session, self)
		if(exp = (model.inactive_date || model.expiration_date))
			span.set_attribute('title',
												 @lookandfeel.lookup(:valid_until, @lookandfeel.format_date(exp)))
		end
		span
	end
  def resultview_switch(model, session=@session)
    current = @session.cookie_set_or_get(:resultview)
    switched = (current == 'pages' ? 'atc' : 'pages')
    args = {
      :search_query => @session.persistent_user_input(:search_query).gsub('/', '%2F'),
      :search_type => @session.persistent_user_input(:search_type),
      :resultview  => switched,
    }
    link = HtmlGrid::Link.new("rv_#{switched}", model, @session, self)
    if @lookandfeel.disabled?(:best_result)
      link.href = @lookandfeel._event_url(:search, args)
    else
      link.href = @lookandfeel._event_url(:search, args, "best_result")
    end
    link.css_class = "list bold"
    link
  end
  def show_packages?
    !(@model.respond_to?(:overflow?) && @model.overflow?) \
      || @session.cookie_set_or_get(:resultview) == "pages"
  end
	def substances(model, session=@session)
		link = HtmlGrid::Link.new(:show, model, session, self)
    show_dose = @lookandfeel.disabled?(:show_substance_dose) ? false : true
    if reg = model.iksnr and seq = model.seqnr and pac = model.ikscd
		  link.href = @lookandfeel._event_url(:show, [:reg, reg, :seq, seq, :pack, pac])
    else
		  link.href = @lookandfeel._event_url(:show, {:pointer => model.pointer})
    end unless  @lookandfeel.disabled?(:substances_link)
    if (model.active_agents.size == 0)
      return nil
    elsif @lookandfeel.enabled?(:display_3_active_agents) and model.active_agents.size <= 3
      value = model.active_agents.collect{|x| show_dose ? x.to_s : x.substance.to_s }.join('<br>')
      link.value = value
    elsif model.active_agents.size == 1
      link.value = show_dose ? model.substances.first.to_s : model.substances.first.substance.to_s
    else
			#txt = HtmlGrid::Component.new(model, session, self)
			link.set_attribute('title', model.active_agents.join(', '))
			link.value = @lookandfeel.lookup(:active_agents, model.active_agents.size)
		end
		link
	end
end
		end
	end
end
