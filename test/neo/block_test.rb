require 'test_helper'

describe Neo::Block do
  it 'can get block height' do
    VCR.use_cassette 'rpc/getblockcount', match_requests_on: [:query] do
      Neo::Block.height.must_equal 1_713_721
    end
  end

  it 'can get the best hash' do
    VCR.use_cassette 'rpc/getbestblockhash', match_requests_on: [:query] do
      Neo::Block.best_hash.must_equal '0x4c5c576c3cc0c0b9ca57b318bab78cddf67bbdaa4e5e1e1989a6cb7764f035a3'
    end
  end

  it 'can get a block by index' do
    VCR.use_cassette 'rpc/getblock_by_index', match_requests_on: [:query] do
      block = Neo::Block.get 42
      block.data.wont_be_nil
    end
  end

  it 'can get a block by hash' do
    VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
      block = Neo::Block.get 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
      block.data.wont_be_nil
    end
  end

  describe 'parser' do
    before do
      VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
        @block = Neo::Block.get 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
      end
    end

    it 'finds version' do
      @block.version.must_equal 0
    end

    it 'finds previous block hash' do
      @block.previous_block_hash.must_equal 'd724236aa5af46af1e4938278c2b36602a19dc64aca5a5bde8c12e7093c2694d'
    end

    it 'finds the merkle root' do
      @block.merkle_root.must_equal '7e656d2a01f0aeb483d849e1ef8b28423203f52e6c2eb57799e4129714990506'
    end

    it 'finds the timestamp' do
      @block.time_stamp.must_equal 1_513_562_283
    end

    it 'finds the block height' do
      @block.height.must_equal 899_727
    end

    it 'finds the nonce' do
      @block.nonce.must_equal '6331841e4f097d65'
    end

    it 'aliases nonce as consensus data' do
      @block.consensus_data.must_equal @block.nonce
    end

    it 'finds the next miners hash' do
      @block.next_consensus.must_equal 'AdyQbbn6ENjqWDa5JNYMwN3ikNcA4JeZdk'
    end
  end
end
