require 'test_helper'

describe Neo::RemoteNode do

  before do
    @remote_node = Neo::RemoteNode.new 'http://seed2.neo.org:10332'
  end

  it 'can get version' do
    VCR.use_cassette 'rpc/getversion', match_requests_on: [:query] do
      @remote_node.version.must_equal '/NEO:2.4.1/'
    end
  end

  it 'can get connection count' do
    VCR.use_cassette 'rpc/getconnectioncount', match_requests_on: [:query] do
      @remote_node.connection_count.must_equal 98
    end
  end

  it 'can get peers' do
    VCR.use_cassette 'rpc/getpeers', match_requests_on: [:query] do
      @remote_node.peers['connected'].wont_be_empty
      @remote_node.peers['unconnected'].wont_be_empty
    end
  end

  it 'can get mempool' do
    VCR.use_cassette 'rpc/getrawmempool', match_requests_on: [:query] do
      @remote_node.mempool.wont_be_empty
    end
  end
end
