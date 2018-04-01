# return: Boolean
# params: Integer, PublicKey, Signature

def main(timestamp, pubkey, signature)
  header = Blockchain.get_header Blockchain.get_height
  return false if timestamp > Header.get_timestamp(header)
  verify_signature signature, pubkey
end
