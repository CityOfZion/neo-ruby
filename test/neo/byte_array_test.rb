# frozen_string_literal: true

require 'test_helper'

class Neo::ByteArrayTest < Minitest::Test
  def test_intialize_from_array
    bytes = Neo::ByteArray.new [255]
    assert_equal 255.chr(Encoding::ASCII_8BIT), bytes.data
  end

  def test_intialize_from_string
    bytes = Neo::ByteArray.new "\xff"
    assert_equal 255.chr(Encoding::ASCII_8BIT), bytes.data
  end

  def test_serialize_hex_string
    bytes = Neo::ByteArray.new [255]
    assert_equal 'ff', bytes.to_hex_string
  end

  def test_serialize_hex_string_with_prefix
    bytes = Neo::ByteArray.new [255]
    assert_equal '0xff', bytes.to_hex_string(prefix: true)
  end

  def test_deserialize_hex_string
    bytes = Neo::ByteArray.from_hex_string 'ff'
    assert_equal bytes, Neo::ByteArray.new([255])
  end

  def test_convert_to_string
    bytes = Neo::ByteArray.new 'Hello!'
    assert_equal 'Hello!', bytes.to_string
  end

  def test_convert_from_string
    bytes = Neo::ByteArray.from_string 'Hello!'
    assert_equal 'Hello!', bytes.to_string
  end

  def test_convert_to_array_of_integer_bytes
    bytes = Neo::ByteArray.new 'Hello!'
    assert_equal [72, 101, 108, 108, 111, 33], bytes.bytes
  end

  def test_get_value
    bytes = Neo::ByteArray.new "\xff"
    assert_equal 255, bytes[0]
  end

  def test_set_value
    bytes = Neo::ByteArray.new "\xff"
    bytes[0] = 42
    assert_equal 42, bytes[0]
  end

  def test_to_int16
    bytes = Neo::ByteArray.new [255, 127]
    assert_equal 32767, bytes.to_int16
  end

  def test_negative_int16
    bytes = Neo::ByteArray.from_hex_string 'a9ff'
    assert_equal(-87, bytes.to_int16)
  end

  def test_from_integer
    bytes = Neo::ByteArray.from_integer 600
    assert_equal 600, bytes.to_integer
  end

  def test_from_large_integer
    bytes = Neo::ByteArray.from_integer 90_194_313_174
    assert_equal 90_194_313_174, bytes.to_integer
  end

  def test_concatenation
    fizz = Neo::ByteArray.from_string 'Fizz'
    buzz = Neo::ByteArray.from_string 'Buzz'
    assert_equal 'FizzBuzz', (fizz + buzz).to_string
  end

  def test_concatenation_utf8
    small = Neo::ByteArray.from_string '小'
    ants  = Neo::ByteArray.from_string '蚁'
    assert_equal '小蚁', (small + ants).to_string
  end

  def test_take
    bytes = Neo::ByteArray.new 'foobar'
    assert_equal Neo::ByteArray.new('foo'), bytes.take(3)
  end

  def test_skip
    bytes = Neo::ByteArray.new 'foobar'
    assert_equal Neo::ByteArray.new('bar'), bytes.skip(3)
  end

  def test_to_s
    bytes = Neo::ByteArray.new [255, 6]
    assert_equal '<ff 06>', bytes.to_s
  end

  def test_from_int16
    bytes = Neo::ByteArray.from_int16 42
    assert_equal 42, bytes.to_int16
  end

  def test_from_int16_negative
    bytes = Neo::ByteArray.from_int16 (-42)
    assert_equal (-42), bytes.to_int16
  end
end
