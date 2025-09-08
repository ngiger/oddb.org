#!/usr/bin/env ruby

# ODDB::Division -- oddb.org -- 29.06.2012 -- yasaka@ywesee.com

require "util/persistence"
require "model/sequence_observer"

module ODDB
  class Division
    class << self
      include AccessorCheckMethod
    end
    include Persistence
    include SequenceObserver
    attr_accessor :divisable, :dissolvable, :crushable, :openable, :notes,
      :source
    check_class_list = {
      divisable: ["String", "NilClass"],
      dissolvable: ["String", "NilClass"],
      crushable: ["String", "NilClass"],
      openable: ["String", "NilClass"],
      notes: ["String", "NilClass"],
      source: ["String", "NilClass"]
    }
    define_check_class_methods check_class_list
    def empty?
      [
        @divisable, @dissolvable, @crushable, @openable, @notes,
        @source
      ].select do |var|
        !var.nil? and !var.empty?
      end.empty?
    end
  end
end
