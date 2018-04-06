# frozen_string_literal: true

require 'neo/transaction/input'
require 'neo/transaction/output'

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

    def read(data)
      @type = case data.read_byte
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
      @version = data.read_byte
      read_exclusive_data(data)
      read_attributes(data)
      read_inputs(data)
      read_outputs(data)
      read_scripts(data)
      self
    end

    # TODO: Refactor this mess
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read_exclusive_data(data)
      case type
      when :miner_transaction, :issue_transaction
        @nonce = data.read_uint32
        singleton_class.send :attr_reader, :nonce
      when :claim_transaction
        count = data.read_vint
        @claims = []
        count.times do
          @claims << {
            previous_hash: data.read_hex(32),
            previous_index: data.read_uint16
          }
        end
        singleton_class.send :attr_reader, :claims
      when :enrollment_transaction
        # TODO: This should be parsed correctly (ec_point)
        @public_key = data.read_hex(33)
        singleton_class.send :attr_reader, :public_key
      when :register_transaction
        @asset_type = data.read_uint8
        @name = data.read_string
        @amount = data.read_uint64
        @issuer = data.read_hex 33
        @admin = data.read_hex 20
      when :publish_transaction
        # TODO: Refactor this into contract model?
        @function_code = data.read_hex
        @params_list = data.read_hex
        @return_type = data.read_hex 1
        @needs_storage = version >= 1 ? data.read_bool : false
        @name = data.read_string
        @code_version = data.read_string
        @author = data.read_string
        @email = data.read_string
        @description = data.read_string
        singleton_class.send :attr_reader, :function_code, :needs_storage, :name, :code_version,
                             :author, :email, :description
      when :invocation_transaction
        @script = Script.read(data)
        @gas = data.read_fixed8
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # TODO: Refactor hash to tx attribute model here
    def read_attributes(data)
      count = data.read_vint
      count.times do
        usage = data.read_uint8
        case usage
        when 0x00, 0x02, 0x03, 0x30, 0xa1..0xaf
          @attributes << { usage: usage, data: data.read_hex(32) }
        when 0x20
          @attributes << { usage: usage, data: data.read_hex(20) }
        else
          # TODO: Parse into plain string?
          @attributes << { usage: usage, data: data.read_hex }
        end
      end
    end

    def read_inputs(data)
      count = data.read_vint
      count.times do
        input = Transaction::Input.new
        input.previous_hash = data.read_hex 32
        input.previous_index = data.read_uint16
        @inputs << input
      end
    end

    def read_outputs(data)
      count = data.read_vint
      count.times do
        output = Transaction::Output.new
        output.asset_id = data.read_hex 32
        output.value = data.read_uint64
        output.script_hash = data.read_hex 20
        @outputs << output
      end
    end

    def read_scripts(data)
      count = data.read_vint
      count.times do
        @scripts << Script.read(data)
      end
    end

    class << self
      def read(data)
        tx = Transaction.new
        tx.read(data)
      end

      def mempool
        RemoteNode.mempool
      end

      # Returns the corresponding transaction information based on the specified hash value
      #
      # @param txid [String] Transaction ID
      # @return [Neo::Transaction]
      def get(txid)
        data = RemoteNode.rpc 'getrawtransaction', txid
        read Utils::DataReader.new(data, true)
      end
    end
  end
end
