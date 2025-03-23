#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::CssTemplate -- oddb.org -- 04.10.2012 -- yasaka@ywesee.com

require 'fileutils'
require 'util/workdir'

module ODDB
  class CssTemplate
    RESOURCE_PATH = File.join(ODDB::RESOURCES_DIR)
    TEMPLATE = File.join(RESOURCE_PATH, 'data/css/template.css')
    FLAVORS = {
      :desitin => {
        :bg_dark                         => '#1b49a2',
        :bg_bright                       => '#d8e1f3',
        :bg_navigation                   => '#1b49a2',
        :rslt_bg                         => '#f6f8fc',
        :bg_dark_link_hover_color        => '#d8e1f3',
        :bg_dark_link_active_color       => '#d8e1f3',
        :navigation_font_color           => 'white',
        :subheading_link_color           => 'white',
        :subheading_link_active_color    => '#d8e1f3',
        :subheading_link_hover_color     => '#d8e1f3',
        :tabnavigation_link_active_color => 'white',
        :tabnavigation_link_color        => 'white',
      },
      :'just-medical' => {
        :bg                         => '#fdeeb8',
        :bg_bright                  => '#e5c237',
        :bg_bright_font_color       => 'black',
        :bg_dark                    => '#d4b126',
        :bg_dark_font_color         => 'black',
        :bg_dark_link_hover_color   => 'red',
        :bg_dark_link_active_color  => 'red',
        :bg_navigation              => '#d4b126',
        :home_link_color            => 'black',
        :home_link_hover_color      => 'red',
        :list_font_color            => 'black',
        :list_link_hover_color      => 'blue',
        :navigation_font_color      => 'black',
        :navigation_link_font_color => 'black',
        :rslt_bg                    => '#fae596',
      },
      :gcc => {
      },
      :generika => {
      },
      :mobile => {
        :explain_font_size => '12px',
        :infos_height      => '16px',
      },
      :swissmedic => {
      },
      :swissmedinfo => {
        :bg_dark                  => '#A04',
        :bg_bright                => '#ECC',
        :bg_navigation            => '#A04',
        :body_margin              => '4px',
        :explain_font_size        => '15px',
        :h3_font_size             => '20px',
        :h3_margin                => '6px',
        :pre_font_size            => '20px',
        :bg_dark_link_hover_color => '#999',
        :square_font_size         => '12px',
        :navigation_font_size     => '14px',
        :std_font_size            => '14px',
      },
      :anthroposophy => {
        :bg_bright                 => '#fcf',
        :bg_medium                 => '#e6f',
        :bg_dark                   => '#f0f',
        :bg_navigation             => '#f0f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#608',
        :bg_dark_link_active_color => '#608',
        :bg_medium_font_color      => 'black',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
      :homeopathy => {
        :bg_bright                 => '#ecf',
        :bg_medium                 => '#b6f',
        :bg_dark                   => '#90f',
        :bg_navigation             => '#90f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#304',
        :bg_dark_link_active_color => '#304',
        :bg_medium_font_color      => 'black',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
      :'phyto-pharma' => {
        :bg_bright                 => '#dcf',
        :bg_medium                 => '#a6f',
        :bg_dark                   => '#60f',
        :bg_dark_font_color        => 'white',
        :bg_dark_link_hover_color  => '#dcf',
        :bg_dark_link_active_color => '#dcf',
        :bg_medium_font_color      => 'black',
        :bg_navigation             => '#60f',
        :home_link_color           => '#20b',
        :home_link_hover_color     => '#40d',
        :list_link_color           => 'black',
        :list_link_hover_color     => '#20b',
        :rslt_infos_bg_bright      => '#fff88f',
        :rslt_infos_bg_dark        => '#fff455',
      },
    }
    COLORS = { # for color_flavors()
      :blue  => {
        :atc_link_color                  => '#0000ff',
        :bg_bright                       => '#a0a0ff',
        :bg_dark                         => '#0000ff',
        :bg_dark_font_color              => 'white',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'black',
        :bg_medium                       => '#a0a0ff',
        :bg_medium_font_color            => 'black',
        :bg_navigation                   => '#0000ff',
        :home_link_hover_color           => 'red',
        :list_link_hover_color           => 'red',
        :rslt_bg                         => '#f0f8ff',
        :sidebar_color                   => '#f0f8ff',
        :navigation_link_font_color      => 'white',
        :navigation_font_color           => 'gray',
        :subheading_link_color           => 'black',
        :subheading_link_active_color    => 'silver',
        :subheading_link_hover_color     => 'red',
        :tabnavigation_link_active_color => 'black',
        :tabnavigation_link_color        => 'blue',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',
      },
      :red => {
        :atc_link_color                  => '#501616',
        :bg_bright                       => '#d35f5f',
        :bg_dark                         => '#501616',
        :bg_dark_font_color              => 'white',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'red',
        :bg_medium                       => '#d35f5f',
        :bg_medium_font_color            => 'black',
        :bg_navigation                   => '#501616',
        :home_link_hover_color           => '#501616',
        :list_link_hover_color           => '#501616',
        :rslt_bg                         => '#fff0f5',
        :sidebar_color                   => '#fff0f5',
        :navigation_link_font_color      => 'white',
        :navigation_font_color           => 'gray',
        :subheading_link_color           => 'black',
        :subheading_link_active_color    => 'silver',
        :subheading_link_hover_color     => 'black',
        :tabnavigation_link_active_color => 'black',
        :tabnavigation_link_color        => 'white',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',
      },
      :olive => {
        :atc_link_color                  => '#747400',
        :bg_bright                       => '#c2c261',
        :bg_dark                         => '#747400',
        :bg_dark_font_color              => 'white',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'blue',
        :bg_medium                       => '#c2c261',
        :bg_medium_font_color            => 'black',
        :bg_navigation                   => '#747400',
        :home_link_hover_color           => 'red',
        :list_link_hover_color           => 'red',
        :rslt_bg                         => '#f5f5dc',
        :sidebar_color                   => '#f5f5dc',
        :navigation_link_font_color      => 'white',
        :navigation_font_color           => 'white',
        :subheading_link_color           => 'black',
        :subheading_link_active_color    => 'silver',
        :subheading_link_hover_color     => 'red',
        :tabnavigation_link_active_color => 'red',
        :tabnavigation_link_color        => 'blue',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'black',
      },
      :purple => {
        :atc_link_color                  => '#19245c',
        :bg_bright                       => '#ddeeff',
        :bg_dark                         => '#19245c',
        :bg_dark_font_color              => 'white',
        :bg_dark_link_active_color       => 'black',
        :bg_dark_link_hover_color        => 'red',
        :bg_medium                       => '#ddeeff',
        :bg_medium_font_color            => 'black',
        :bg_navigation                   => '#19245c',
        :home_link_hover_color           => 'red',
        :list_link_hover_color           => 'red',
        :rslt_bg                         => '#f8f8ff',
        :sidebar_color                   => '#f8f8ff',
        :navigation_link_font_color      => 'white',
        :navigation_font_color           => 'gray',
        :subheading_link_color           => 'black',
        :subheading_link_active_color    => 'silver',
        :subheading_link_hover_color     => 'red',
        :tabnavigation_link_active_color => 'black',
        :tabnavigation_link_color        => 'blue',
        :tabnavigation_link_hover_color  => 'black',
        :tabnavigation_text_color        => 'gray',
      },
    }
    DEFAULT = {
      :align_center                    => 'center',
      :align_center_inputmargin        => '7px',
      :align_center_tablemargin        => 'auto',
      :atc_link_color                  => '#2ba476',
      :bg_bright                       => '#ccff99',
      :bg_bright_font_color            => 'black',
      :bg_dark                         => '#2ba476',
      :bg_dark_font_color              => 'white',
      :bg_dark_link_active_color       => 'red',
      :bg_dark_link_hover_color        => 'blue',
      :bg_feedback                     => '#ffbc6f',
      :bg_feedback_alternate           => '#ffbc22',
      :bg_google                       => '#184fca',
      :bg_medium                       => '#7bcf88',
      :bg_medium_font_color            => 'black',
      :bg_navigation                   => '#2ba476',
      :bg                              => 'white',
      :big_font_size                   => '14px',
      :body_margin                     => '8px',
      :button_background               => 'none',
      :button_font_color               => 'black',
      :button_font_size                => '12px',
      :explain_font_size               => '11px',
      :generic_font_color              => '#2ba476',
      :h3_font_size                    => '12px',
      :h3_margin                       => '2px',
      :home_link_color                 => 'blue',
      :home_link_hover_color           => '#2ba476',
      :infos_height                    => 'auto',
      :l1_font_size                    => '12px',
      :l2_font_size                    => '14px',
      :l3_font_size                    => '16px',
      :list_font_color                 => 'blue',
      :list_link_color                 => 'blue',
      :list_link_hover_color           => '#2ba476',
      :navigation_link_font_color      => 'white',
      :navigation_link_font_weight     => 'normal',
      :navigation_font_color           => 'white',
      :navigation_font_size            => '12px',
      :pre_font_size                   => '12px',
      :rslt_bg                         => '#ecffe6',
      :rslt_infos_bg_bright            => '#FFF88F',
      :rslt_infos_bg_dark              => '#FFF455',
      :rslt_link_active_color          => 'gold',
      :rslt_link_hover_color           => 'blue',
      :sidebar_color                   => '#ddffdd',
      :square_font_size                => '11px',
      :std_font_family                 => 'Roboto, Arial, Helvetica, sans-serif',
      :std_font_size                   => '12px',
      :subheading_link_color           => 'black',
      :subheading_link_active_color    => 'silver',
      :subheading_link_hover_color     => 'red',
      :tabnavigation_link_active_color => 'black',
      :tabnavigation_link_color        => 'blue',
      :tabnavigation_link_font_size    => '13px',
      :tabnavigation_link_font_weight  => 'bold',
      :tabnavigation_link_hover_color  => 'black',
      :tabnavigation_text_color        => 'black',
    }
    class << self
      def flavor_pathes(name)
        path = RESOURCE_PATH + "#{name}/oddb.css"
        [File.expand_path(path, File.dirname(__FILE__))]
      end
      def color_flavors # these flavors use color-changer in preferences
        %w[gcc mobile]
      end
      def color_pathes(name)
        %w[gcc mobile].map do |flavor|
          path = RESOURCE_PATH + "#{flavor}/oddb-#{name}.css"
          File.expand_path(path, File.dirname(__FILE__))
        end
      end
      def resolve(var, flavor)
        key = var.intern
        flavor.fetch(key) {
          DEFAULT.fetch(key) { raise "could not find default for #{key}" }
        }
      end
      def substitute(src, flavor)
        src.gsub(/\$([^\s;]+)/u) { |match|
          resolve($1, flavor)
        }
      end
      def write_css()
        {
          :flavor => FLAVORS,
          :color  => COLORS,
        }.each_pair do |type, css|
          css.each { |name, updates|
            src = File.read(TEMPLATE)
            self.send("#{type}_pathes".intern, name).each do |path|
              # merge color into base (overwrite)
              color_flavors.each do |flavor|
                if path.match(/#{flavor}\/oddb-(#{COLORS.keys.join("|")})/) and
                   base = FLAVORS[flavor.intern]
                  updates = base.merge(updates)
                end
              end
              FileUtils.mkdir_p(File.dirname(path))
              File.open(path, "w") { |fh|
                fh << substitute(src, updates)
              }
              File.chmod(0664, path)
            end
          }
        end
      end
    end
  end
end
