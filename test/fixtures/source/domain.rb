# return: ByteArray
# params: String, Array

def main(operation, args)
  case operations
  when 'query'    then query    args[0].to_string
  when 'register' then register args[0].to_string, args[1]
  when 'transfer' then transfer args[0].to_string, args[1]
  when 'delete'   then delete   args[0].to_string
  else false
  end
end

def query(domain)
  Storage.get Storage.get_context domain
end

def register(domain, owner)
  return false unless Runtime.check_witness owner
  value = Storage.get Storage.get_context domain
  return false unless value.nil?
  Storage.put Storage.get_context, domain, owner
  true
end

def transfer(domain, to)
  return false unless Runtime.check_witness to
  from = Storage.get Storage.get_context domain
  return false if from.nil?
  return false unless Runtime.check_witness from
  Storage.put Storage.get_context, domain, to
  true
end

def delete(domain)
  owner = Storage.get Storage.get_context, domain
  return false if owner.nil?
  return false unless Runtime.check_witness owner
  Storage.delete Storage.get_context, domain
  true
end
