# frozen_string_literal: true

module Neo
  module Network
    class VersionPayload < Message
      attr_accessor :version, :services, :timestamp, :port, :nonce, :user_agent, :start_height, :relay

      def initialize(port = nil, nonce = nil, start_height = 0)
        @command = 'version'
        @version = 0
        @services = 1
        @timestamp = Time.now
        @port = port.to_i
        @nonce = nonce
        @user_agent = Neo.user_agent
        @start_height = start_height
        @relay = false
      end

      def deserialize(data)
        @version = data.read_uint32
        @services = data.read_uint64
        @timestamp = data.read_time
        @port = data.read_uint16
        @nonce = data.read_uint32
        @user_agent = data.read_string
        @start_height = data.read_uint32
        @relay = data.read_bool
      end

      def serialize(data)
        data.write_uint32 @version
        data.write_uint64 @services
        data.write_time @timestamp
        data.write_uint16 @port
        data.write_uint32 @nonce
        data.write_string @user_agent
        data.write_uint32 @start_height
        data.write_bool @relay
      end
    end
  end
end
