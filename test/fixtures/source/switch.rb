# return: Integer
# params: Integer

def main(a)
  m = a % 4
  case m
  when 0, 2
    m = m / 2
  else
    m = m * 2
  end
  m
end
