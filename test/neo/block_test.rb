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
end
