# frozen_string_literal: true

require 'digest'

# rubocop:disable Naming/MethodName, Metrics/ModuleLength
module Neo
  module VM
    # Implementations of specific VM operations
    module Operations
      (0x00..0x10).each do |number|
        define_method "PUSH#{number}" do
          evaluation_stack.push number
        end
      end

      (0x01..0x4B).each do |length|
        define_method "PUSHBYTES#{length}" do
          evaluation_stack.push current_context.read_bytes(length)
        end
      end

      def PUSHF
        evaluation_stack.push 0
      end

      def PUSHT
        evaluation_stack.push 1
      end

      def PUSHDATA1
        length = current_context.read_byte
        evaluation_stack.push current_context.read_bytes(length)
      end

      def PUSHDATA2
        length = current_context.read_bytes(2).to_uint16
        evaluation_stack.push current_context.read_bytes(length)
      end

      def PUSHDATA4
        length = current_context.read_bytes(4).to_int32
        evaluation_stack.push current_context.read_bytes(length)
      end

      def PUSHM1
        evaluation_stack.push(-1)
      end

      # Flow control

      def NOP; end

      def JMP
        offset = current_context.read_bytes(2).to_int16
        offset = current_context.instruction_pointer + offset - 3
        fault! unless offset.between? 0, current_context.script.length
        result = block_given? ? yield : true
        current_context.instruction_pointer = offset if result
      end

      def JMPIF
        JMP do
          result = unwrap_boolean evaluation_stack.pop
          result = !result if __callee__ == :JMPIFNOT
          result
        end
      end

      alias JMPIFNOT JMPIF

      def CALL
        original_context = current_context
        invocation_stack.push(current_context.clone)
        original_context.instruction_pointer += 2
        perform :JMP
      end

      def RET
        invocation_stack.pop
        halt! if invocation_stack.empty?
      end

      def APPCALL
        script_hash = current_context.read_bytes(20).to_hex_string
        invocation_stack.pop if __callee__ == :TAILCALL
        script = SDK::Script.table[script_hash]
        load_script script
      end

      alias TAILCALL APPCALL

      def SYSCALL
        length = current_context.read_byte
        invoke current_context.read_bytes(length).to_string
      end

      # Stack

      def DUPFROMALTSTACK
        evaluation_stack.push alt_stack.peek
      end

      def TOALTSTACK
        alt_stack.push evaluation_stack.pop
      end

      def FROMALTSTACK
        evaluation_stack.push alt_stack.pop
      end

      def XDROP
        index = unwrap_integer evaluation_stack.pop
        fault! if n.negative?
        evaluation_stack.remove(index)
      end

      def XSWAP
        index = unwrap_integer evaluation_stack.pop
        fault! if index.negative?
        return if index.zero?
        item = evaluation_stack.peek index
        evaluation_stack.set index, evaluation_stack.peek
        evaluation_stack.set 0, item
      end

      def XTUCK
        index = unwrap_integer evaluation_stack.pop
        fault! if index <= 0
        evaluation_stack.insert index, evaluation_stack.peek
      end

      def DEPTH
        evaluation_stack.push evaluation_stack.size
      end

      def DROP
        evaluation_stack.pop
      end

      def DUP
        evaluation_stack.push evaluation_stack.peek
      end

      def NIP
        item = evaluation_stack.pop
        evaluation_stack.pop
        evaluation_stack.push item
      end

      def OVER
        x2 = evaluation_stack.pop
        x1 = evaluation_stack.peek
        evaluation_stack.push x1
        evaluation_stack.push x2
      end

      def PICK
        index = unwrap_integer evaluation_stack.pop
        fault! if index.negative!
        evaluation_stack.push evaluation_stack.peek(index)
      end

      def ROLL
        index = unwrap_integer evaluation_stack.pop
        fault! if index.negative?
        evaluation_stack.push evaluation_stack.remove(index) unless index.zero?
      end

      def ROT
        x3 = evaluation_stack.pop
        x2 = evaluation_stack.pop
        x1 = evaluation_stack.pop
        evaluation_stack.push x2
        evaluation_stack.push x3
        evaluation_stack.push x1
      end

      def SWAP
        x2 = evaluation_stack.pop
        x1 = evaluation_stack.pop
        evaluation_stack.push x2
        evaluation_stack.push x1
      end

      def TUCK
        x2 = evaluation_stack.pop
        x1 = evaluation_stack.pop
        evaluation_stack.push x2
        evaluation_stack.push x1
        evaluation_stack.push x2
      end

      # Splice

      def CAT
        rhs = evaluation_stack.pop
        lhs = evaluation_stack.pop
        evaluation_stack.push lhs + rhs
      end

      def SUBSTR
        count = unwrap_integer evaluation_stack.pop
        index = unwrap_integer evaluation_stack.pop
        fault! if count.negative? || index.negative?
        bytes = unwrap_byte_array evaluation_stack.pop
        evaluation_stack.push bytes.skip(index).take(count)
      end

      def LEFT
        count = unwrap_integer evaluation_stack.pop
        fault! if count.negative?
        bytes = unwrap_byte_array evaluation_stack.pop
        evaluation_stack.push bytes.take(count)
      end

      def RIGHT
        count = unwrap_integer evaluation_stack.pop
        fault! if count.negative?
        bytes = unwrap_byte_array evaluation_stack.pop
        evaluation_stack.push bytes.skip(bytes.size - count)
      end

      def SIZE
        bytes = unwrap_byte_array evaluation_stack.pop
        evaluation_stack.push bytes.length
      end

      # Bitwise logic

      def INVERT
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push ~operand
      end

      def AND
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs & rhs
      end

      def OR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs | rhs
      end

      def XOR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs ^ rhs
      end

      def EQUAL
        rhs = evaluation_stack.pop
        lhs = evaluation_stack.pop
        evaluation_stack.push lhs == rhs
      end

      # Arithmetic

      # NOTE: Ruby does not support ++, and the neon compiler doesn't output this opcode either.
      def INC
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push operand + 1
      end

      # NOTE: Ruby does not support --, and the neon compiler doesn't output this opcode either.
      def DEC
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push operand - 1
      end

      def SIGN
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push 0 && return if operand.zero?
        evaluation_stack.push operand.negative? ? -1 : 1
      end

      def NEGATE
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push(-operand)
      end

      def ABS
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push operand.abs
      end

      def NOT
        operand = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push !operand
      end

      def NZ
        operand = unwrap_integer evaluation_stack.pop
        evaluation_stack.push !operand.zero?
      end

      def ADD
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs + rhs
      end

      def SUB
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs - rhs
      end

      def MUL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs * rhs
      end

      def DIV
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs / rhs
      end

      def MOD
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs % rhs
      end

      def SHL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs << rhs
      end

      def SHR
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs >> rhs
      end

      def BOOLAND
        rhs = unwrap_boolean evaluation_stack.pop
        lhs = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push lhs && rhs
      end

      def BOOLOR
        rhs = unwrap_boolean evaluation_stack.pop
        lhs = unwrap_boolean evaluation_stack.pop
        evaluation_stack.push lhs || rhs
      end

      def NUMEQUAL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs == rhs
      end

      def NUMNOTEQUAL
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs != rhs
      end

      def LT
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs < rhs
      end

      def GT
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs > rhs
      end

      def LTE
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs <= rhs
      end

      def GTE
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs >= rhs
      end

      def MIN
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push [lhs, rhs].min
      end

      def MAX
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        evaluation_stack.push [lhs, rhs].max
      end

      def WITHIN
        rhs = unwrap_integer evaluation_stack.pop
        lhs = unwrap_integer evaluation_stack.pop
        opx = unwrap_integer evaluation_stack.pop
        evaluation_stack.push lhs <= opx && opx < rhs
      end

      # Crypto

      def SHA1
        bytes = unwrap_byte_array evaluation_stack.pop
        evaluation_stack.push ByteArray.new(Digest::SHA1.digest(bytes.data))
      end

      def SHA256
        bytes = unwrap_byte_array evaluation_stack.pop
        sha256 = Digest::SHA256.digest bytes.data
        evaluation_stack.push ByteArray.new(sha256)
      end

      def HASH160
        bytes = unwrap_byte_array evaluation_stack.pop
        sha256 = Digest::SHA256.digest bytes.data
        rmd160 = Digest::RMD160.digest sha256
        evaluation_stack.push ByteArray.new(rmd160)
      end

      def HASH256
        bytes = unwrap_byte_array evaluation_stack.pop
        sha256 = Digest::SHA256.digest Digest::SHA256.digest(bytes.data)
        evaluation_stack.push ByteArray.new(sha256)
      end

      def CHECKSIG
        public_key = unwrap_byte_array evaluation_stack.pop
        signature = unwrap_byte_array evaluation_stack.pop
        message = script_container.get_message
        valid = SDK::Simulation.verify_signature message, signature, public_key
        evaluation_stack.push valid
      end

      # LOL rubocop :(
      # TODO: Test and refactor
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def CHECKMULTISIG
        public_keys = []
        items_or_count = evaluation_stack.pop
        if items_or_count.is_a? Array
          public_keys = items_or_count.map { |item| unwrap_byte_array item }
          fault! if public_keys.length.zero?
        else
          count = unwrap_integer items_or_count
          fault! if count.zero? || count > evaluation_stack.size
          count.times do
            public_keys.push unwrap_byte_array(evaluation_stack.pop)
          end
        end
        signatures = []
        items_or_count = evaluation_stack.pop
        if items_or_count.is_a? Array
          signatures = items_or_count.map { |item| unwrap_byte_array item }
          fault! if signatures.length.zero? || signatures.length > public_keys.length
        else
          count = unwrap_integer items_or_count
          fault! if count < 1 || signatures.length > public_keys.length || signatures.length > evaluation_stack.size
          count.times do
            signatures.push unwrap_byte_array(evaluation_stack.pop)
          end
        end
        message = script_container.get_message
        success = true
        i = 0
        j = 0
        while success && i < signatures.length && j < public_keys.length
          i += 1 if SDK::Simulation.verify_signature message, signatures[i], public_keys[j]
          j += 1
          success = false if signatures.length - i > public_keys.length - j
        end
        evaluation_stack.push success
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      # Array

      def ARRAYSIZE
        items = unwrap_array evaluation_stack.pop
        evaluation_stack.push items.length
      end

      def PACK
        length = unwrap_integer evaluation_stack.pop
        fault! if length.negative? || length > evaluation_stack.size
        items = Array.new(length)
        length.times do |i|
          items[i] = evaluation_stack.pop
        end
        evaluation_stack.push items
      end

      def UNPACK
        items = unwrap_array evaluation_stack.pop
        items.each do |item|
          evaluation_stack.push item
        end
        evaluation_stack.push items.length
      end

      def PICKITEM
        index = unwrap_integer evaluation_stack.pop
        items = unwrap_array evaluation_stack.pop
        fault! if index.negative? || index >= items.length
        evaluation_stack.push items[index]
      end

      def SETITEM
        item = evaluation_stack.pop
        # TODO: Clone struct?
        index = unwrap_integer evaluation_stack.pop
        items = unwrap_array evaluation_stack.pop
        fault! if index.negative? || index >= items.length
        items[index] = item
      end

      def NEWARRAY
        length = unwrap_integer evaluation_stack.pop
        evaluation_stack.push Array.new(length)
      end

      # TODO: VM::Types::Struct.new(items) ?
      def NEWSTRUCT
        count = unwrap_integer evaluation_stack.pop
        items = Array.new(count, false)
        evaluation_stack.push items
      end

      def APPEND
        item = evaluation_stack.pop
        items = unwrap_array evaluation_stack.pop
        items.push item
      end

      def REVERSE
        items = unwrap_array evaluation_stack.pop
        items.reverse!
      end

      # Exceptions

      def THROW
        fault!
      end

      def THROWIFNOT
        condition = unwrap_boolean evaluation_stack.pop
        fault! unless condition
      end
    end
  end
end
# rubocop:enable Naming/MethodName, Metrics/ModuleLength
