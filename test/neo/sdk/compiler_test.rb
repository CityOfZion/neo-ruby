# frozen_string_literal: true

require 'test_helper'

class Neo::SDK::CompilerTest < Minitest::Test
  include TestHelper

  AUTO_CONTRACTS = [
    'add',
    'arithmetic',
    'bit_invert',
    'bitwise',
    'boolean_and',
    'boolean_or',
    'constants',
    'control_if',
    'control_if_else',
    'decrement',
    'divide',
    'equality',
    'greater_than_equal',
    'greater_than',
    'increment',
    'inequality',
    'less_than_equal',
    'less_than',
    'logical_not',
    'method_call',
    'modulo',
    'multiply',
    'negate',
    'numeric_equality',
    'numeric_inequality',
    'return_42',
    'return_false',
    'return_true',
    'shift_left',
    'shift_right',
    'subtract',
    'while'
  ]

  AUTO_CONTRACTS.each do |name|
    define_method "test_#{name}" do
      compile_and_invoke name
    end
  end

  def test_it_finds_return_type
    script = Neo::SDK::Compiler.load 'test/fixtures/source/return_42.rb', Logger.new(IO::NULL)
    assert_equal :Integer, script.return_type
  end

  def test_it_compiles_return_42
    script = Neo::SDK::Compiler.load 'test/fixtures/source/return_42.rb', Logger.new(IO::NULL)
    sim = Neo::SDK::Simulation.new script
    assert_equal 42, sim.invoke
  end

  def test_runtime_log
    Runtime.expects(:log).twice.with('Hello, World.')
    compile_and_invoke 'runtime_log'
  end

  def test_lock
    now = Time.now.to_i
    later = now + 100
    Simulation.stubs(:verify_signature).returns true
    Simulation.expects(:get_message).returns ByteArray.new Random.new.bytes(20)
    Blockchain.expects(:get_height).twice.returns 42
    Header.expects(:get_timestamp).returns later
    Blockchain.expects(:get_header).twice.returns stub(timestamp: later)
    compile_and_invoke 'lock', now, '1234sig', '1234key'
  end
end
