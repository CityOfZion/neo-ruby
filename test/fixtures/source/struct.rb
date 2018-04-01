# return: Void

def main()
  array = [Point.new(1, 2), Point.new(2, 1)]
  add(array[0], array[1])
  nil
end

def add(a, b)
  Point.new(a.x + b.x, a.y + b.y)
end

Point = Struct.new(:x, :y)
