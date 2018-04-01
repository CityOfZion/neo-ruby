# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::AgencyTransactionTest < Minitest::Test
  include TestHelper

  # # params: ByteArray, ByteArray, ByteArry, ByteArray, Boolean, Integer, Signature
  #
  # def main(agent, asset_id, value_id, client, way, price, signature)

  def test_one
    agent = ByteArray.new Random.new.bytes(20)
    asset_id = ByteArray.new Random.new.bytes(32)
    value_id = ByteArray.new Random.new.bytes(32)
    client = ByteArray.new Random.new.bytes(20)
    price = 42
    signature = ByteArray.new Random.new.bytes(65)
    input = mock('TransactionInput')
    output_a = mock('TransactionOutput', script_hash: ByteArray.new(Random.new.bytes(20)))
    output_b = mock('TransactionOutput', script_hash: ByteArray.new(Random.new.bytes(20)))
    tx = mock('ScriptContainer', outputs: [output_a])
    tx.expects(:inputs).returns [input]
    tx.expects(:references).returns({ input => output_b })
    Simulation.expects(:verify_signature).at_least(2).returns false, true
    Simulation.expects(:get_message).twice.returns ByteArray.new Random.new.bytes(20)
    ExecutionEngine.expects(:get_script_container).twice.returns tx

    contract = load_contract 'agency_transaction', :Boolean
    assert contract.invoke(agent, asset_id, value_id, client, false, price, signature)
  end
end
