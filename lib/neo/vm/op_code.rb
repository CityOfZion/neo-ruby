# frozen_string_literal: true

require 'yaml'

module Neo
  module VM
    # Neo VM OpCodes
    module OpCode
      @codes = YAML.load_file File.join(__dir__, 'op_codes.yml')

      # 0x01-0x4B The next opcode bytes is data to be pushed onto the stack
      (0x01..0x4B).each do |n|
        @codes["PUSHBYTES#{n}".to_sym] = n
      end

      @codes.each { |name, code| const_set name, code }

      def self.[](code)
        @codes.key code
      end
    end
  end
end
