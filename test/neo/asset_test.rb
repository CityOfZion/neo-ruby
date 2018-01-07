require 'test_helper'

describe Neo::Asset do

  it 'can get asset' do
    VCR.use_cassette 'rpc/getassetstate', match_requests_on: [:query] do
      Neo::Asset.neo.name.must_equal 'AntShare'
    end
  end
end
