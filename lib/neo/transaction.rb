module Neo
  # Represent a transaction on the Neo blockchain
  class Transaction
    attr_reader :type,
                :version,
                :attributes,
                :inputs,
                :outputs,
                :scripts

    def initialize
      @attributes = []
      @inputs = []
      @outputs = []
      @scripts = []
    end

    def read(io)
      @type = case Utils.read_uint8(io)
              when 0x00 then :miner_transaction
              when 0x01 then :issue_transaction
              when 0x02 then :claim_transaction
              when 0x20 then :enrollment_transaction
              when 0x40 then :register_transaction
              when 0x80 then :contract_transaction
              when 0xd0 then :publish_transaction
              when 0xd1 then :invocation_transaction
              end
      @version = Utils.read_uint8(io)
      read_exclusive_data(io)
      read_attributes(io)
      read_inputs(io)
      read_outputs(io)
      read_scripts(io)
      self
    end

    # TODO: Handle all the extra data types
    def read_exclusive_data(io)
      case type
      when :miner_transaction
        @nonce = Utils.read_uint32(io)
        singleton_class.send :attr_reader, :nonce
      when :claim_transaction
        count = Utils.read_variable_integer(io)
        @claims = []
        count.times do
          @claims << {
            previous_hash: Utils.read_hex_string(io, 32),
            previous_index: Utils.read_uint16(io)
          }
        end
        singleton_class.send :attr_reader, :claims
      end
    end

    # TODO: Refactor hash to object here
    def read_attributes(io)
      count = Utils.read_variable_integer(io)
      count.times do
        usage = Utils.read_uint8(io)
        case usage
        when 0x00, 0x02, 0x03, 0x30, 0xa1..0xaf
          @attributes << { usage: usage, data: Utils.read_hex_string(io, 32) }
        else
          length = Utils.read_uint8(io)
          # TODO: Parse into plain string?
          @attributes << { usage: usage, data: Utils.read_hex_string(io, length) }
        end
      end
    end

    # TODO: Refactor hash to input object
    def read_inputs(io)
      count = Utils.read_variable_integer(io)
      count.times do
        @inputs << {
          previous_hash: Utils.read_hex_string(io, 32),
          previous_index: Utils.read_uint16(io)
        }
      end
    end

    # TODO: Refactor hash to output object
    def read_outputs(io)
      count = Utils.read_variable_integer(io)
      count.times do
        @outputs << {
          asset_id: Utils.read_hex_string(io, 32),
          value: Utils.read_uint64(io),
          script_hash: Utils.read_hex_string(io, 20)
        }
      end
    end

    def read_scripts(io)
      count = Utils.read_variable_integer(io)
      count.times do
        @scripts << Script.read(io)
      end
    end

    class << self
      def read(io)
        tx = Transaction.new
        tx.read(io)
      end
    end
  end
end
