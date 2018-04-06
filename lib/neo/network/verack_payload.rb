# frozen_string_literal: true

module Neo
  module Network
    class VerackPayload < Message
      def initialize
        @command = 'verack'
      end
    end
  end
end
