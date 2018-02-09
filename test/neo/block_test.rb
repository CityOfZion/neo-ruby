require 'test_helper'

describe Neo::Block do
  it 'can get block height' do
    VCR.use_cassette 'rpc/getblockcount', match_requests_on: [:query] do
      Neo::Block.height.must_equal 1_713_721
    end
  end

  it 'can get the best hash' do
    VCR.use_cassette 'rpc/getbestblockhash', match_requests_on: [:query] do
      Neo::Block.best_hash.must_equal '0x4c5c576c3cc0c0b9ca57b318bab78cddf67bbdaa4e5e1e1989a6cb7764f035a3'
    end
  end

  it 'can get a block by index' do
    VCR.use_cassette 'rpc/getblock_by_index', match_requests_on: [:query] do
      block = Neo::Block.get 42
      block.height.must_equal 42
    end
  end

  it 'can get a block by hash' do
    VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
      block = Neo::Block.get 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
      block.height.must_equal 899727
    end
  end

  it 'can get a block hash by index' do
    VCR.use_cassette 'rpc/getblockhash', match_requests_on: [:query] do
      Neo::Block.hash(42).must_equal '0x6e0b6bad6dc34ef335c829c0864f57750796a17603ccab8e296d8345c8c469f0'
    end
  end

  it 'can get a block sys fee by index' do
    VCR.use_cassette 'rpc/getblocksysfee', match_requests_on: [:query] do
      Neo::Block.sys_fee(2134).must_equal 10
    end
  end

  it 'can hash itself' do
    hash = 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
    VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
      block = Neo::Block.get hash
      block.block_hash.must_equal hash
    end
  end

  describe 'parser' do
    before do
      VCR.use_cassette 'rpc/getblock_by_hash', match_requests_on: [:query] do
        @block = Neo::Block.get 'fb70a04f58cf18ed025377e85dab7c21ba97e5b5c07e05fbb7d3d81d40216a40'
      end
    end

    it 'finds version' do
      @block.version.must_equal 0
    end

    it 'finds previous block hash' do
      @block.previous_block_hash.must_equal 'd724236aa5af46af1e4938278c2b36602a19dc64aca5a5bde8c12e7093c2694d'
    end

    it 'finds the merkle root' do
      @block.merkle_root.must_equal '7e656d2a01f0aeb483d849e1ef8b28423203f52e6c2eb57799e4129714990506'
    end

    it 'finds the timestamp' do
      @block.time_stamp.must_equal 1_513_562_283
    end

    it 'finds the block height' do
      @block.height.must_equal 899_727
    end

    it 'finds the nonce' do
      @block.nonce.must_equal '6331841e4f097d65'
    end

    it 'aliases nonce as consensus data' do
      @block.consensus_data.must_equal @block.nonce
    end

    it 'finds the next miners hash' do
      @block.next_consensus.must_equal 'AdyQbbn6ENjqWDa5JNYMwN3ikNcA4JeZdk'
    end

    it 'finds verification script' do
      @block.script.verify.must_equal verification_script_hash
    end

    it 'finds invocation script' do
      @block.script.invoke.must_equal invocation_script_hash
    end

    it 'finds the right number of transactions' do
      @block.transactions.size.must_equal 4
    end

    it 'finds the transaction type' do
      @block.transactions[0].type.must_equal :miner_transaction
      @block.transactions[1].type.must_equal :contract_transaction
      @block.transactions[3].type.must_equal :claim_transaction
    end

    it 'finds the transaction version' do
      @block.transactions[0].version.must_equal 0
    end

    it 'finds the exclusive data of a miner transaction' do
      @block.transactions[0].nonce.must_equal 1_326_021_989
    end

    it 'finds the exclusive data of a miner transaction' do
      @block.transactions[0].nonce.must_equal 1_326_021_989
    end

    it 'finds the exclusive data of a publish transaction' do
      VCR.use_cassette 'rpc/getblock_publish', match_requests_on: [:query] do
        block = Neo::Block.get 232
        block.transactions[1].name.must_equal 'Lock'
      end
    end
  end

  def verification_script_hash
    '55210209e7fd41dfb5c2f8dc72eb30358ac100ea8c72da18847befe06eade68cebfcb9210'\
    '327da12b5c40200e9f65569476bbff2218da4f32548ff43b6387ec1416a231ee821034ff5'\
    'ceeac41acf22cd5ed2da17a6df4dd8358fcb2bfb1a43208ad0feaab2746b21026ce35b291'\
    '47ad09e4afe4ec4a7319095f08198fa8babbe3c56e970b143528d2221038dddc06ce68767'\
    '7a53d54f096d2591ba2302068cf123c1f2d75c2dddc542557921039dafd8571a641058ccc'\
    '832c5e2111ea39b09c0bde36050914384f7a48bce9bf92102d02b1873a0863cd042cc717d'\
    'a31cea0d7cf9db32b74d4c72c01b0011503e2e2257ae'
  end

  def invocation_script_hash
    '405f70bb1cb06b0038540e1bfe2c38df2b4b6824a0f28512b4ca72ba2763c24b857770525'\
    'd2013ce538059ac60f003e7e5171f6a26c6130091f5cf37b4c50f9a90405c0cda410b2d1c'\
    'badcd008e4ce83c6fa0ac5ec550f15b888f16ddf15a7e324321f83abd1eef044473cd8a79'\
    '4e548dd29ab67d70263b87d2d38dd5c518a1bab4340340247f1b0e396f2097302588ff19d'\
    '63bbd161cb059ff55d6bc8fbeaf98f436c93dafd8f35abfccfcf07e110cda246079a426aa'\
    '74024b9fc76a6809af43a378f403fc6b224c5e84c80f076058125fc8e591c33802572d910'\
    'b1d2fa842121a52112cbf342a51c850e29adfd033dd3d8680bc4265983f5464df9e99ee8f'\
    '5597d1c1340642a65097047c22f9edfb23844b3625f873fda7f1e69ed4ac2b18ea7be8bc3'\
    '2482135daed7e5616639fb6f1f588ddb2e09c00a17327005ea296dce43444845c6'
  end
end
