# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::DomainContractTest < Minitest::Test
  include TestHelper

  def test_query
    bytes = ByteArray.new Random.new.bytes(33)
    Blockchain.expects(:get_contract).returns stub(storage?: true)
    Storage.expects(:get_context).returns stub(:script_hash)
    Storage.expects(:get).returns bytes

    contract = load_contract 'domain', :ByteArray
    assert_equal bytes, contract.invoke('query', ['neo.org'])
  end

  def test_register
    domain = ByteArray.from_string 'cityofzion.io'
    owner = ByteArray.new Random.new.bytes(33)
    storage_context = stub 'StorageContext', :script_hash
    Blockchain.expects(:get_contract).returns stub('Contract', storage?: true)
    Storage.expects(:get_context).twice.returns storage_context
    Storage.expects(:get).with(storage_context, domain).returns nil
    Storage.expects(:put).with(storage_context, domain, owner)
    Simulation.expects(:check_witness).returns true

    contract = load_contract 'domain', :ByteArray
    assert_equal ByteArray.new([1]), contract.invoke('register', [domain, owner])
  end
end
