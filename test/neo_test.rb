require 'test_helper'

describe Neo do
  it 'has a version number' do
    Neo.version.wont_be_nil
  end

  describe 'configuration' do
    it 'defaults network to TestNet' do
      Neo.config.network.must_equal 'TestNet'
    end

    it 'can change network' do
      Neo.configure do |config|
        config.network = 'MainNet'
      end

      Neo.config.network.must_equal 'MainNet'
    end

    after do
      Neo.config = Neo::Configuration.new
    end
  end
end
