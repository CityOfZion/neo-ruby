require 'net/http'
require 'json'

#:nodoc:
module Neo
  # Make a call to a Neo node's JSON-RPC interface
  #
  # @param method [String] The RPC method name to call
  # @param params [Array<String>] arguments to the RPC method
  # @return [Hash] The parsed JSON response
  def self.rpc(method, *params)
    # TODO: Do somethign better than just randomly picking a seed
    uri = URI(Neo.config.seeds.to_a.sample)
    options = { jsonrpc: '2.0', method: method, params: params.to_s, id: 1 }
    uri.query = URI.encode_www_form(options)
    response = Net::HTTP.get(uri)
    JSON.parse(response)['result']
  end
end
