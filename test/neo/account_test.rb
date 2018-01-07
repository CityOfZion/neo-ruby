require 'test_helper'

describe Neo::Account do

  before do
    VCR.use_cassette 'rpc/getaccountstate', match_requests_on: [:query] do
      @account = Neo::Account.get 'AX2Ycy8dN52f1TdUJo8kyjFDrAMDubZYNn'
    end
  end

  it 'can get balances' do
    @account.neo_balance.must_equal 122
    @account.gas_balance.must_equal 2_591.295665
  end
end
