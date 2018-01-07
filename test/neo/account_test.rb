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

  it 'it can validate an address' do
    VCR.use_cassette 'rpc/validateaddress_valid', match_requests_on: [:query] do
      assert Neo::Account.validate('AZzDawx6i7XDnjuFtH3rqaqs9dRApmTqu1')
    end
  end

  it 'it can invalidate an address' do
    VCR.use_cassette 'rpc/validateaddress_invalid', match_requests_on: [:query] do
      refute Neo::Account.validate('lolwut')
    end
  end
end
