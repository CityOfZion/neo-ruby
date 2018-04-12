# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Handle ruby features, emit Neo bytecode
      module Handlers
        require 'neo/sdk/compiler/handlers/assignments'
        require 'neo/sdk/compiler/handlers/control_expressions'
        require 'neo/sdk/compiler/handlers/literals'
        require 'neo/sdk/compiler/handlers/methods'

        include Assignments
        include ControlExpressions
        include Literals
        include Methods

        OPERATORS = {
          :+      => :ADD,
          :-      => :SUB,
          :*      => :MUL,
          :/      => :DIV,
          :%      => :MOD,
          :~      => :INVERT,
          :&      => :AND,
          :|      => :OR,
          :"^"    => :XOR,
          :"!"    => :NOT,
          :>      => :GT,
          :>=     => :GTE,
          :<      => :LT,
          :<=     => :LTE,
          :<<     => :SHL,
          :>>     => :SHR,
          :-@     => :NEGATE,
          :"eql?" => :EQUAL,
          :verify_signature => :CHECKSIG
        }.freeze

        NAMESPACES = %i[
          Account
          Asset
          Attribute
          Block
          Blockchain
          Contract
          Enrollment
          ExecutionEngine
          Header
          Input
          Output
          Runtime
          Storage
          Transaction
          Validator
        ].freeze
      end
    end
  end
end
