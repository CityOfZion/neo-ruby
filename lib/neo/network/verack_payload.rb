module Neo
  module Network
    class VerackPayload < Message
      def initialize
        @command = 'verack'
      end
    end
  end
end
