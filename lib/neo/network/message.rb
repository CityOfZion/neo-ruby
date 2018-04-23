# frozen_string_literal: true

require 'digest'

module Neo
  module Network
    class Message
      attr_reader :command

      def payload
        data = Neo::Utils::DataWriter.new
        serialize data
        data.io.string.force_encoding Encoding.find('ASCII-8BIT')
      end

      def packet
        checksum = Digest::SHA256.digest(Digest::SHA256.digest(payload))[0...4]
        header = [
          Neo.config.magic_word,
          command,
          payload.bytesize,
          checksum
        ].pack 'a4a12Va4'

        header + payload
      end

      def deserialize(data); end

      def serialize(data); end

      class << self
        def read(data)
          payload = new
          payload.deserialize Neo::Utils::DataReader.new(data, false)
          payload
        end
      end
    end
  end
end
