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
              when 0x24 then :vote_transaction
              when 0x40 then :register_transaction
              when 0x80 then :contract_transaction
              when 0xb0 then :agency_transaction
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

    # TODO: Refactor this mess
    def read_exclusive_data(io)
      case type
      when :miner_transaction, :issue_transaction
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
      when :enrollment_transaction
        # TODO: This should be parsed correctly (ec_point)
        @public_key = Utils.read_hex_string(io, 33)
        singleton_class.send :attr_reader, :public_key
      when :register_transaction
        @asset_type = Utils.read_uint8(io)
        @name = Utils.read_string(io)
        @amount = Utils.read_uint64(io)
        @issuer = Utils.read_hex_string(io, 33)
        @admin = Utils.read_hex_string(io, 20)
      when :publish_transaction
        # TODO: Refactor this into contract model?
        code_length = Utils.read_variable_integer(io)
        @function_code = Utils.read_hex_string(io, code_length)
        params_length = Utils.read_variable_integer(io)
        @params_list = Utils.read_hex_string(io, params_length)
        @return_type = Utils.read_hex_string(io, 1)
        @needs_storage = version >= 1 ? Utils.read_boolean(io) : false
        @name = Utils.read_string(io)
        @code_version = Utils.read_string(io)
        @author = Utils.read_string(io)
        @email = Utils.read_string(io)
        @description = Utils.read_string(io)
        singleton_class.send :attr_reader, :function_code, :needs_storage, :name, :code_version,
                             :author, :email, :description
      when :invocation_transaction
        @script = Script.read(io)
        @gas = Utils.read_fixed8(io)
      end
    end

    # TODO: Refactor hash to tx attribute model here
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

    # TODO: Refactor hash to input model
    def read_inputs(io)
      count = Utils.read_variable_integer(io)
      count.times do
        @inputs << {
          previous_hash: Utils.read_hex_string(io, 32),
          previous_index: Utils.read_uint16(io)
        }
      end
    end

    # TODO: Refactor hash to output model
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
