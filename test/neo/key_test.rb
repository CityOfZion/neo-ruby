require 'test_helper'

describe Neo::Key do

  it 'can convert an address to script hash' do
    script_hash = Neo::Key.address_to_script_hash 'AZUMsCifwXMr3kMXwKuNwge9ZjhFuMEHwM'
    script_hash.must_equal 'c2225536c82a70dd3688d8467b23e2b60d4785a1'
  end
end
