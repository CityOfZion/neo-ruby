require 'test_helper'

describe Neo::Contract do
  before do
    VCR.use_cassette 'rpc/getcontractstate', match_requests_on: [:query] do
      @contract = Neo::Contract.get 'b95ee3beefc33fde5f057b7ba5827f77323e0709'
    end
  end

  it 'can get a contract' do
    @contract.name.must_equal 'Raffle'
  end

  it 'can read storage' do
    VCR.use_cassette 'rpc/getstorage', match_requests_on: [:query] do
      skip
      data = Neo::Contract.storage '1f06d4728dfa975c925258f886594b73d9651bdc', '48656c6c6f'
      data.must_equal '576f726c64'
    end
  end
end
