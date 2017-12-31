module Neo
  module Network
    class Payload
      def write
        data = Neo::Utils::DataWriter.new
        serialize(data)
        data.io.string.force_encoding(Neo::Utils::BINARY)
      end

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
