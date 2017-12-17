require 'test_helper'

describe Neo::Block do
  it 'can get block height' do
    VCR.use_cassette 'rpc/getblockcount', match_requests_on: [:query] do
      Neo::Block.height.must_equal 1_713_721
    end
  end
end
