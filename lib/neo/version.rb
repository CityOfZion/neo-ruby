# frozen_string_literal: true

#:nodoc:
module Neo
  # @return [String] the current version.
  # @note This string also has singleton methods:
  #
  #   * `major` [Integer] The major version.
  #   * `minor` [Integer] The minor version.
  #   * `patch` [Integer] The patch version.
  #   * `parts` [Array<Integer>] List of the version parts.
  def version
    @version ||= begin
      string = +'0.0.0'

      def string.parts
        split('.').map(&:to_i)
      end

      def string.major
        parts[0]
      end

      def string.minor
        parts[1]
      end

      def string.patch
        parts[2]
      end

      string
    end
  end

  module_function :version

  def user_agent
    "/NEO-RUBY:#{version}/"
  end

  module_function :user_agent
end
