# frozen_string_literal: true

module Neo
  module Network
    class Parser
      HEAD_SIZE = 24
      attr_reader :handler

      def initialize(handler)
        @handler = handler
        @buffer = ''
      end

      def buffer(data)
        @buffer += data
        while parse; end
        @buffer
      end

      # TODO: Add check for correct _magic
      def parse
        _magic, command, length, checksum = @buffer.unpack('a4A12Va4')
        payload = @buffer[HEAD_SIZE...HEAD_SIZE + length]
        if Digest::SHA256.digest(Digest::SHA256.digest(payload))[0...4] != checksum
          return if payload.size < length
          raise 'TODO: handle checksum error'
        end
        @buffer = @buffer[HEAD_SIZE + length..-1] || ''
        handler.send "handle_#{command}", payload
        !@buffer.empty?
      end
    end
  end
end
