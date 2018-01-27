require 'neo/utils/entity'

module Neo
  class Script
    include Neo::Utils::Entity

    attr_reader :verify, :invoke

    class << self
      def read(data)
        new(invoke: data.read_hex, verify: data.read_hex)
      end
    end
  end
end
