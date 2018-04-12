# frozen_string_literal: true

module Neo
  module VM
    # Random-access Stack
    class Stack
      def initialize
        @items = []
      end

      def empty?
        @items.empty?
      end

      def insert(index, item)
        @items.insert index, item
      end

      def peek(idx = 0)
        @items[idx]
      end

      def pop
        @items.shift
      end

      def push(item)
        @items.unshift item
      end

      def remove(index)
        @items.delete_at index
      end

      def set(index, item)
        @items[index] = item
      end

      def size
        @items.size
      end

      def to_s
        "[#{@items.map(&:inspect).join(', ')}]"
      end

      alias inspect to_s
    end
  end
end
