module Neo
  module Network
    module Events
      def on_connected(&block)
        @callbacks[:connected] << block
      end

      def on_block(&block)
        @callbacks[:block] << block
      end
    end
  end
end
