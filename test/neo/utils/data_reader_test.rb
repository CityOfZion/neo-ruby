require 'test_helper'

describe Neo::Utils::DataReader do
  it 'can read a 16-bit integer' do
    with('702E').read_uint16.must_equal 11_888
  end

  it 'can read a 32-bit integer' do
    with('A6809AF4').read_uint32.must_equal 4_103_766_182
  end

  it 'can read a 64-bit integer' do
    with('D042CC717DA31CEA').read_uint64.must_equal 16_869_538_063_398_486_736
  end

  it 'can read variable length integers' do
    with('FC8E83E7CFFDC0F0CE').read_vint.must_equal 252
    with('FD8E83E7CFFDC0F0CE').read_vint.must_equal 33_678
    with('FE8E83E7CFFDC0F0CE').read_vint.must_equal 3_488_056_206
    with('FF8E83E7CFFDC0F0CE').read_vint.must_equal 14_911_630_562_571_027_342
  end

  it 'can read a boolean' do
    with('00').read_bool.must_equal false
    with('01').read_bool.must_equal true
    with('FF').read_bool.must_equal true
  end

  it 'can read a string' do
    with('044C6F636B').read_string.must_equal 'Lock'
  end

  it 'can read a hex string' do
    with('044C6F636B').read_hex.must_equal '4c6f636b'
  end

  it 'can read a fixed length hex string' do
    with('4C6F636B').read_hex(4).must_equal '4c6f636b'
  end

  it 'can read a reversed fixed length hex string' do
    with('4C6F636B').read_hex(4, true).must_equal '6b636f4c'
  end

  it 'can read a string from binary file' do
    File.open('test/fixtures/lock.bin') do |file|
      data = Neo::Utils::DataReader.new(file)
      data.read_string.must_equal 'Lock'
    end
  end

  it 'can read fixed point numbers' do
    with('CFFDC0F0CE014140').read_fixed8.must_equal 46_299_838_802.276505
  end

  describe 'with binary input' do
    before do
      @file = File.open('test/fixtures/block.bin')
      @data = Neo::Utils::DataReader.new(@file)
    end

    it 'can read a byte' do
      @data.move_to 4
      @data.read_byte.must_equal 77
    end

    after do
      @file.close
    end
  end

  describe 'with hex string input' do
    before do
      string = File.read('test/fixtures/block.txt')
      @data = Neo::Utils::DataReader.new(string)
    end

    it 'can read a byte' do
      @data.move_to 4
      @data.read_byte.must_equal 77
    end
  end

  private

  def with(hex)
    Neo::Utils::DataReader.new(hex)
  end
end
