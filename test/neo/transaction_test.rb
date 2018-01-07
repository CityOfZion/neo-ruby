require 'test_helper'

describe Neo::Transaction do
  it 'can get a transaction by hash' do
    VCR.use_cassette 'rpc/getrawtransaction', match_requests_on: [:query] do
      tx = Neo::Transaction.get 'd2e9b91e6dedd2d224559093bac6c5a75aba16b285e9ab5bcd87940f1c1bbf44'
      tx.type.must_equal :contract_transaction
    end
  end
end
