# frozen_string_literal: true

module Neo
  module Network
    class BlockPayload < Message
      attr_accessor :block

      def initialize(block = nil)
        @block = block
        @command = 'block'
      end

      def deserialize(data)
        @block = Block.read data
      end

      def serialize(data)
        @block.serialize data
      end
    end
  end
end
