#!/usr/bin/env ruby

# Remote::GalenicForm -- de.oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# Remote::GalenicForm -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require "remote/object"
require "remote/galenic_group"
require "remote/migel/util/multilingual"

module ODDB
  module Remote
    class GalenicForm < Remote::Object
      def equivalent_to?(other)
        other && (other.has_description?(@remote.description.de) \
          || galenic_group&.equivalent_to?(other.galenic_group))
      end

      def galenic_group
        @group ||= if (group = @remote.group)
          Remote::GalenicGroup.new(group)
        end
      end
    end
  end
end
