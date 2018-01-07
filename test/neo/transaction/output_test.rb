require 'test_helper'

describe Neo::Transaction::Output do
  before do
    VCR.use_cassette 'rpc/gettxout', match_requests_on: [:query] do
      txid = 'd2e9b91e6dedd2d224559093bac6c5a75aba16b285e9ab5bcd87940f1c1bbf44'
      @output = Neo::Transaction::Output.get txid, 1
    end
  end

  it 'can get an output' do
    @output.asset_id.must_equal '0x' + Neo::Asset::NEO_ID.to_s(16)
    @output.address.must_equal 'AX2Ycy8dN52f1TdUJo8kyjFDrAMDubZYNn'
    @output.value.must_equal 122
  end
end
