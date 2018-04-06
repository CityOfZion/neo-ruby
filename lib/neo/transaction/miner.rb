# frozen_string_literal: true

module Neo
  module Transaction
    module Miner
      attr_reader :nonce

      def read_exclusive_data(io)
        @nonce = Utils.read_uint32(io)
      end
    end
  end
end
