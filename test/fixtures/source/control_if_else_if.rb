# return: Integer
# params: Integer

def main(a)
  if a % 3 == 0
    a
  elsif a % 3 == 1
    a * 2
  else
    a * 3
  end
end
