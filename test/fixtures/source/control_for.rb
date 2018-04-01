# return: Integer
# params: Integer

def main(a)
  sum = 0
  for _i in 0..a do
    sum += 1
    break if sum >= a >> 8
  end
  sum
end
