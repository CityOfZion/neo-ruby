module Neo
  module Utils
    module VarInt
      def encode(length)
        case length
        when 0...0xfc                         then [length].pack('C')
        when 0xfd...0xffff                    then [0xfd, value].pack('Cv')
        when 0x1000000...0xffffffff           then [0xfe, value].pack('CV')
        when 0x100000000...0xffffffffffffffff then [0xff, value].pack('CQ')
        else raise 'Too Large' # TODO: Raise a better error?
        end
      end

      module_function :encode
    end
  end
end
