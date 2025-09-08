#!/usr/bin/env ruby

# View::Drugs::RecentRegs -- oddb -- 01.09.2003 -- mhuggler@ywesee.com

require "view/drugs/result"

module ODDB
  module View
    module Drugs
      class DateChooser < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0, 0]	=>	:months,
          [0, 0, 1]	=>	"navigation_divider",
          [0, 0, 2]	=>	:years
        }
        CSS_CLASS = "composite"
        LEGACY_INTERFACE = false
        def years(model)
          date = @session.state.date
          cyear = date.year
          month = date.month
          separator = @lookandfeel.lookup(:dash_separator)
          @session.state.years.collect { |year|
            if cyear == year
              [year, separator]
            else
              link = HtmlGrid::Link.new(:recent_registrations, model, @session, self)
              args = {year: year, month: month}
              link.href = @lookandfeel._event_url(:recent_registrations, args)
              link.value = year.to_s
              link.css_class = "list"
              [link, separator]
            end
          }.flatten[0..-2]
        end

        def months(model)
          date = @session.state.date
          year = date.year
          cmonth = date.month
          months = @session.state.months
          separator = @lookandfeel.lookup(:dash_separator)
          (1..12).collect { |month|
            mstr = @lookandfeel.lookup("month_#{month}")
            if cmonth != month && months.include?(month)
              link = HtmlGrid::Link.new(:recent_registrations, model, @session, self)
              args = {year: year, month: month}
              link.href = @lookandfeel._event_url(:recent_registrations, args)
              link.value = mstr
              link.css_class = "list"
              [link, separator]
            else
              [mstr, separator]
            end
          }.flatten[0..-2]
        end
      end

      class DateHeader < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0]	=>	:date_packages
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0] => "atc list"
        }
        LEGACY_INTERFACE = false
        def date_packages(model)
          date = model.date
          [
            @lookandfeel.lookup("month_" + date.month.to_s),
            date.year.to_s,
            "-",
            model.package_count,
            @lookandfeel.lookup(:products)
          ].join(" ")
        end
      end

      class RootRecentRegsList < View::Drugs::RootResultList
        SUBHEADER = View::Drugs::DateHeader
        def init
          super
          @grid.insert_row(1, create(DateChooser))
          @grid.add_style("list atc date-chooser", 0, 1)
          @grid.set_colspan(0, 1)
        end
      end

      class RecentRegsList < View::Drugs::ResultList
        SUBHEADER = View::Drugs::DateHeader
        def init
          super
          @grid.insert_row(1, create(DateChooser))
          @grid.add_style("list atc date-chooser", 0, 1)
          @grid.set_colspan(0, 1)
        end
      end

      class RecentRegsComposite < View::Drugs::ResultComposite
        COMPONENTS = {
          [0, 1]	=>	"price_compare",
          [1, 1]	=>	SelectSearchForm
        }
        DEFAULT_LISTCLASS = View::Drugs::RecentRegsList
        ROOT_LISTCLASS = View::Drugs::RootRecentRegsList
        def breadcrumbs(model, session = @session)
          dv = HtmlGrid::Span.new(model, @session, self)
          dv.css_class = "breadcrumb"
          dv.value = "&lt;"
          span1 = HtmlGrid::Span.new(model, @session, self)
          span1.css_class = "breadcrumb bold"
          link1 = HtmlGrid::Link.new(:back_to_home, model, @session, self)
          link1.href = @lookandfeel._event_url(:home)
          link1.css_class = "list"
          span1.value = link1
          span2 = HtmlGrid::Span.new(model, @session, self)
          span2.css_class = "breadcrumb"
          span2.value = @lookandfeel.lookup(:recent_registrations)
          [span1, dv, span2]
        end
      end

      class RecentRegs < View::PrivateTemplate
        SEARCH_HEAD = ODDB::View::SelectSearchForm
        CONTENT = View::Drugs::RecentRegsComposite
      end
    end
  end
end
