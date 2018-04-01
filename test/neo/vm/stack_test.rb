# frozen_string_literal: true

require 'test_helper'

class Neo::VM::StackTest < Minitest::Test

  def setup
    @stack = Neo::VM::Stack.new
  end

  def test_push
    @stack.push 42
    assert_equal 1, @stack.size
  end

  def test_pop
    @stack.push 42
    @stack.push 666
    assert_equal 666, @stack.pop
    assert_equal 42, @stack.pop
  end

  def test_insert
    @stack.push 42
    @stack.push 666
    @stack.insert 1, 256
    assert_equal 256, @stack.peek(1)
  end

  def test_inspect
    @stack.push 42

    assert_equal '[42]', @stack.inspect
  end
end
