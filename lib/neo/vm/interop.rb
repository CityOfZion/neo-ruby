# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Neo
  module VM
    # Interop service, state reader & state machine
    class Interop
      include Helper
      attr_reader :engine

      def initialize(engine)
        @engine = engine
      end

      # Get the balance of this asset in the account given the asset ID
      def neo_account_get_balance
        raise NotImplementedError
      end

      # Get the script hash of the contract account
      def neo_account_get_script_hash
        raise NotImplementedError
      end

      # Get information of the votes that this account has casted
      def neo_account_get_votes
        raise NotImplementedError
      end

      # Set the voting information of this account
      def neo_account_set_votes
        raise NotImplementedError
      end

      # Register a new asset
      def neo_asset_create
        raise NotImplementedError
      end

      # Obtain the administrator (contract address) of the asset
      def neo_asset_get_admin
        raise NotImplementedError
      end

      # Get the total amount of the asset
      def neo_asset_get_amount
        raise NotImplementedError
      end

      # Get ID of the asset
      def neo_asset_get_asset_id
        raise NotImplementedError
      end

      # Get the category of the asset
      def neo_asset_get_asset_type
        raise NotImplementedError
      end

      # Get the quantity of the asset that has been issued
      def neo_asset_get_available
        raise NotImplementedError
      end

      # Obtain the issuer (contract address) of the asset
      def neo_asset_get_issuer
        raise NotImplementedError
      end

      # Get the owner of the asset (public key)
      def neo_asset_get_owner
        raise NotImplementedError
      end

      # Get the number of divisions for this asset, the number of digits after the decimal point
      def neo_asset_get_precision
        raise NotImplementedError
      end

      # Renew an asset
      def neo_asset_renew
        raise NotImplementedError
      end

      # Get extra data outside of the purpose of transaction
      def neo_attribute_get_data
        raise NotImplementedError
      end

      # Get purpose of transaction
      def neo_attribute_get_usage
        raise NotImplementedError
      end

      # Get the transaction specified in the current block
      def neo_block_get_transaction
        raise NotImplementedError
      end

      # Get the number of transactions in the current block
      def neo_block_get_transaction_count
        raise NotImplementedError
      end

      # Get all transactions in the current block
      def neo_block_get_transactions
        raise NotImplementedError
      end

      # Get an account based on the script hash of the contract
      def neo_blockchain_get_account
        raise NotImplementedError
      end

      # Get asset based on asset ID
      def neo_blockchain_get_asset
        raise NotImplementedError
      end

      # Find block by block Height or block Hash
      def neo_blockchain_get_block
        raise NotImplementedError
      end

      # Get contract content based on contract hash
      def neo_blockchain_get_contract
        raise NotImplementedError
      end

      # Find block header by block height or block hash
      def neo_blockchain_get_header
        data = unwrap_byte_array engine.evaluation_stack.pop
        header = nil
        if data.length <= 5
          header = SDK::Simulation::Blockchain.get_header unwrap_integer(data)
        elsif data.length == 32
          header = SDK::Simulation::Blockchain.get_header data
        else return false
        end
        engine.evaluation_stack.push header
        true
      end

      # Get the current block height
      def neo_blockchain_get_height
        engine.evaluation_stack.push SDK::Simulation::Blockchain.get_height
        true
      end

      # Find transaction via transaction ID
      def neo_blockchain_get_transaction
        raise NotImplementedError
      end

      # Get the public key of the consensus node
      def neo_blockchain_get_validators
        raise NotImplementedError
      end

      # Publish a smart contract
      def neo_contract_create
        raise NotImplementedError
      end

      # Destroy a smart contract
      def neo_contract_destroy
        raise NotImplementedError
      end

      # Get the scripthash of the contract
      def neo_contract_get_script
        raise NotImplementedError
      end

      # Get the storage context of the contract
      def neo_contract_get_storage_context
        raise NotImplementedError
      end

      # Migrate/Renew a smart contract
      def neo_contract_migrate
        raise NotImplementedError
      end

      # Deprecated Replaced with Neo.Blockchain.GetValidators
      def neo_enrollment_get_public_key
        raise NotImplementedError
      end

      # Get consensus data for this block (pseudo-random number generated by consensus node)
      def neo_header_get_consensus_data
        raise NotImplementedError
      end

      # Get the hash of the block
      def neo_header_get_hash
        raise NotImplementedError
      end

      # Get the current block height
      def neo_header_get_index
        raise NotImplementedError
      end

      # Get the Merkle Tree root for all transactions in that block
      def neo_header_get_merkle_root
        raise NotImplementedError
      end

      # Get the hash value for the next bookkeeper contract
      def neo_header_get_next_consensus
        raise NotImplementedError
      end

      # Get the hash of the previous block
      def neo_header_get_prev_hash
        raise NotImplementedError
      end

      # Get the timestamp of the block
      def neo_header_get_timestamp
        header = engine.evaluation_stack.pop
        return false unless header
        engine.evaluation_stack.push header.timestamp
        true
      end

      # Get Block version number
      def neo_header_get_version
        raise NotImplementedError
      end

      # Get the hash of the referenced previous transaction
      def neo_input_get_hash
        raise NotImplementedError
      end

      # The index of the input in the output list of the referenced previous transaction
      def neo_input_get_index
        raise NotImplementedError
      end

      # Get Asset ID
      def neo_output_get_asset_id
        raise NotImplementedError
      end

      # Get the transaction amount
      def neo_output_get_script_hash
        output = engine.evaluation_stack.pop
        return false if output.nil?
        engine.evaluation_stack.push unwrap_byte_array(output.script_hash)
        true
      end

      # Get Script Hash
      def neo_output_get_value
        raise NotImplementedError
      end

      # Verifies that the calling contract has verified the required script hashes of the transaction/block
      def neo_runtime_check_witness
        hash_or_pubkey = unwrap_byte_array engine.evaluation_stack.pop
        result = SDK::Simulation.check_witness engine, hash_or_pubkey
        engine.evaluation_stack.push result
        true
      end

      # Notifies the client with a log message during smart contract execution
      def neo_runtime_log
        message = unwrap_string engine.evaluation_stack.pop
        SDK::Simulation::Runtime.log message
        true
      end

      # Notifies the client with a notification during smart contract execution
      def neo_runtime_notify
        raise NotImplementedError
      end

      # Deletes a value from the persistent store based off the given key
      def neo_storage_delete
        raise NotImplementedError
      end

      # Returns the value in the persistent store based off the key given
      def neo_storage_get
        context = engine.evaluation_stack.pop
        contract = SDK::Simulation::Blockchain.get_contract context.script_hash
        return false unless contract.storage?
        value = engine.evaluation_stack.pop
        key = unwrap_byte_array value
        item = SDK::Simulation::Storage.get context, key
        engine.evaluation_stack.push item || ByteArray.new([0])
        true
      end

      # Get the current store context
      def neo_storage_get_context
        storage_context = SDK::Simulation::Storage.get_context
        engine.evaluation_stack.push storage_context
        true
      end

      # Inserts a value into the persistent store based off the given key
      def neo_storage_put
        context = engine.evaluation_stack.pop
        key = unwrap_byte_array engine.evaluation_stack.pop.to_string
        return false if key.length > 1024
        value = unwrap_byte_array engine.evaluation_stack.pop
        SDK::Simulation::Storage.put context, key, value
        true
      end

      # Query all properties of the current transaction
      def neo_transaction_get_attributes
        raise NotImplementedError
      end

      # Get Hash for the current transaction
      def neo_transaction_get_hash
        raise NotImplementedError
      end

      # Query all transactions for current transactions
      def neo_transaction_get_inputs
        raise NotImplementedError
      end

      # Query all transaction output for current transaction
      def neo_transaction_get_outputs
        tx = engine.evaluation_stack.pop
        return false unless tx
        engine.evaluation_stack.push tx.outputs
        true
      end

      # Query the transaction output referenced by all inputs of the current transaction
      def neo_transaction_get_references
        tx = engine.evaluation_stack.pop
        return false if tx.nil?
        engine.evaluation_stack.push(tx.inputs.map { |input| tx.references[input] })
      end

      # Get the current transaction type
      def neo_transaction_get_type
        raise NotImplementedError
      end

      # Register as a bookkeeper
      def neo_validator_register
        raise NotImplementedError
      end

      def system_execution_engine_get_calling_script_hash
        engine.evaluation_stack.push engine.calling_context.script_hash
      end

      def system_execution_engine_get_entry_script_hash
        engine.evaluation_stack.push engine.entry_context.script_hash
      end

      def system_execution_engine_get_executing_script_hash
        engine.evaluation_stack.push engine.current_context.script_hash
      end

      def system_execution_engine_get_script_container
        engine.evaluation_stack.push SDK::Simulation::ExecutionEngine.get_script_container
        true
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
