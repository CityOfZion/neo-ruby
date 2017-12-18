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
      block.data.wont_be_empty
    end
  end

  it 'can get a block by hash' do
    VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
      block = Neo::Block.get 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
      block.data.wont_be_empty
    end
  end
end
