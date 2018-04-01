# frozen_string_literal: true

require 'test_helper'
require 'securerandom'

class Neo::SDK::ExecutionTest < Minitest::Test
  include TestHelper

  # These contracts are executed with random inputs and test_hello_world
  # against the ruby implementation for correctness.
  AUTO_CONTRACTS = [
    'add',
    'arithmetic',
    'array_operations',
    'bit_invert',
    'bitwise',
    'boolean_and',          # TODO: Doesn't actually test BOOLAND
    'boolean_or',           # TODO: Doesn't actually test BOOLOR
    'constants',
    'control_for',
    'control_if_else_if',
    'control_if_else',
    'control_if',
    'decrement',            # TODO: Doesn't actually test DEC
    'divide',
    'equality',             # TODO: Doesn't actually test EQUAL
    'greater_than_equal',
    'greater_than',
    'increment',            # TODO: Doesn't actually test INC
    'less_than_equal',
    'less_than',
    'logical_not',
    'method_call',
    'modulo',
    'multiply',
    'negate',
    'return_42',
    'return_true',
    'shift_left',
    'shift_right',
    'string_concatenation',
    'string_length',
    'subtract',
    'struct',
    'switch',
    'while'
  ]

  AUTO_CONTRACTS.each do |name|
    define_method("test_#{name}") do
      load_and_invoke name
    end
  end

  def test_hello_world
    context = stub(:script_hash)
    Storage.stubs(:get_context).returns context
    Storage.expects(:put).twice.with context, 'Hello', 'World'
    load_and_invoke 'hello_world'
  end

  def test_fibonacci
    load_and_invoke 'fibonacci', 7
  end

  def test_runtime_log
    Runtime.expects(:log).twice.with('Hello, World.')
    load_and_invoke 'runtime_log'
  end

  def test_storage_get
    Blockchain.expects(:get_contract).returns stub(storage?: true)
    Storage.expects(:get_context).returns stub(:script_hash)
    Storage.expects(:get).returns 'Buzz'

    contract = load_contract 'storage_get', :String
    assert_equal 'Buzz', contract.invoke
  end

  def test_lock
    now = Time.now.to_i
    later = now + 100
    Simulation.stubs(:verify_signature).returns true
    Simulation.expects(:get_message).returns ByteArray.new Random.new.bytes(20)
    Blockchain.expects(:get_height).twice.returns 42
    Header.expects(:get_timestamp).returns later
    Blockchain.expects(:get_header).twice.returns stub(timestamp: later)
    load_and_invoke 'lock', now, '1234sig', '1234key'
  end
end
