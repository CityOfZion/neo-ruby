# return: Integer
# params: Integer

def main(n)
  fibonacci n
end

def fibonacci(n)
  return 1 if (n == 1 || n == 2)
  m1 = fibonacci n - 1;
  m2 = fibonacci n - 2;
  return m1 + m2;
end
