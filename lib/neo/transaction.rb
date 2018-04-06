require 'neo/transaction/attribute'
require 'neo/transaction/input'
require 'neo/transaction/output'
require 'neo/utils/entity'

module Neo
  # Represent a transaction on the Neo blockchain
  class Transaction
    include Neo::Utils::Entity

    attr_reader :version,
                :attributes,
                :inputs,
                :outputs,
                :scripts

    class << self
      def read(data)
        byte = data.read_byte
        subclass = subclasses.find { |klass| klass::BYTE_ID == byte }
        raise UnknownTransactionTypeError unless subclass
        attrs = {version: subclass.read_version(data)}
        attrs.merge! subclass.read_type_attributes(data, attrs[:version])
        attrs.merge!(
          attributes: subclass.read_attributes(data),
          inputs: subclass.read_inputs(data),
          outputs: subclass.read_outputs(data),
          scripts: subclass.read_scripts(data)
        )
        subclass.new(**attrs)
      end

      def read_version(data)
        data.read_byte
      end

      # Provides a hook for subclasses to provide attributes that are specific
      # to each transaction type. Should return a hash of attributes.
      def read_type_attributes(_data, _version)
        {}
      end

      def read_attributes(data)
        Array.new(data.read_vint) do
          Transaction::Attribute.new(data.read_uint8, data)
        end
      end

      def read_inputs(data)
        Array.new(data.read_vint) do
          Transaction::Input.new(data.read_hex(32), data.read_uint16)
        end
      end

      def read_outputs(data)
        Array.new(data.read_vint) do
          Transaction::Output.new(
            data.read_hex(32),
            data.read_uint64,
            data.read_hex(20)
          )
        end
      end

      def read_scripts(data)
        Array.new(data.read_vint) { Script.read(data) }
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

      def subclasses
        [
          MinerTransaction, IssueTransaction, ClaimTransaction,
          EnrollmentTransaction, VoteTransaction, RegisterTransaction,
          ContractTransaction, AgencyTransaction, PublishTransaction,
          InvocationTransaction
        ]
      end
    end
  end

  class MinerTransaction < Transaction
    BYTE_ID = 0x00

    attr_reader :nonce

    class << self
      def read_type_attributes(data, _version)
        { nonce: data.read_uint32 }
      end
    end
  end

  class IssueTransaction < Transaction
    BYTE_ID = 0x01

    attr_reader :nonce

    class << self
      def read_type_attributes(data, _version)
        { nonce: data.read_uint32 }
      end
    end
  end

  class ClaimTransaction < Transaction
    BYTE_ID = 0x02

    attr_reader :claims

    class << self
      def read_type_attributes(data, _version)
        {
          claims: Array.new(data.read_vint) do
            {
              previous_hash: data.read_hex(32),
              previous_index: data.read_uint16
            }
          end
        }
      end
    end
  end

  class EnrollmentTransaction < Transaction
    BYTE_ID = 0x20

    attr_reader :public_key

    class << self
      def read_type_attributes(data, _version)
        # TODO: This should be parsed correctly (ec_point)
        { public_key: data.read_hex(33) }
      end
    end
  end

  class VoteTransaction < Transaction
    BYTE_ID = 0x24
  end

  class RegisterTransaction < Transaction
    BYTE_ID = 0x40

    class << self
      def read_type_attributes(data, _version)
        {
          asset_type: data.read_uint8,
          name: data.read_string,
          amount: data.read_uint64,
          issuer: data.read_hex(33),
          admin: data.read_hex(20)
        }
      end
    end
  end

  class ContractTransaction < Transaction
    BYTE_ID = 0x80
  end

  class AgencyTransaction < Transaction
    BYTE_ID = 0xb0
  end

  class PublishTransaction < Transaction
    BYTE_ID = 0xd0

    attr_reader :function_code, :needs_storage, :name, :code_version, :author,
                :email, :description

    class << self
      def read_type_attributes(data, version)
        # TODO: Refactor this into contract model?
        {
          function_code: data.read_hex,
          params_list: data.read_hex,
          return_type: data.read_hex(1),
          needs_storage: version >= 1 ? data.read_bool : false,
          name: data.read_string,
          code_version: data.read_string,
          author: data.read_string,
          email: data.read_string,
          description: data.read_string
        }
      end
    end
  end

  class InvocationTransaction < Transaction
    BYTE_ID = 0xd1

    class << self
      def read_type_attributes(data, _version)
        {
          script: Script.read(data),
          gas: data.read_fixed8,
        }
      end
    end
  end

  class UnknownTransactionTypeError < RuntimeError; end
end
