# return: Boolean
# params: ByteArray, ByteArray, ByteArry, ByteArray, Boolean, Integer, Signature

def main(agent, asset_id, value_id, client, way, price, signature)
  return true if verify_signature signature, client
  return false unless verify_signature signature, agent

  input_id  = way ? asset_id : value_id
  output_id = way ? value_id : asset_id

  input_sum = 0
  output_sum = 0

  references = ExecutionEngine.get_script_container.get_references
  references.each do |reference|
    if reference.script_hash == ExecutionEngine.get_entry_script_hash
      unless referece.asset_id == input_id
        return false
      else
        input_sum += reference.value
      end
    end
  end

  outputs = ExecutionEngine.get_script_container.get_outputs
  outputs.each do |output|
    if output.script_hash == ExecutionEngine.get_entry_script_hash
      if output.asset_id == input_id
        input_sum -= output.value
      elsif output.asset_id == output_id
        output_sum += output.value
      end
    end
  end

  return true if input_sum <= 0

  if way
    return false if output_sum * 100000000 < input_sum * price
  else
    return false if input_sum * 100000000 < output_sum * price
  end

  true
end
