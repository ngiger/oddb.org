#!/usr/bin/env ruby

# SequenceObserver -- oddb -- 22.05.2013 -- yasaka@ywesee.com
# SequenceObserver -- oddb -- 28.11.2003 -- rwaltert@ywesee.com

module ODDB
  module SequenceObserver
    attr_accessor :sequences
    def initialize
      @sequences = []
      super
    end

    def add_sequence(seq)
      @sequences ||= [] # needed for some unit test
      unless @sequences.include?(seq)
        @sequences.push(seq)
        @sequences.odba_isolated_store
      end
      odba_isolated_store # rewrite indices
      seq
    end

    def remove_sequence(seq)
      @sequences ||= [] # needed for some unit test
      ## failsafe-code
      @sequences.delete_if { |s| s.odba_instance.nil? }
      ##
      if @sequences.delete(seq)
        @sequences.odba_isolated_store
      end
      odba_isolated_store # rewrite indices
      seq
    end

    def empty?
      @sequences.empty?
    end
  end
end
