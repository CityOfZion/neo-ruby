$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'coveralls'
require 'simplecov'

unless ENV['CI']
  Coveralls::Output.silent = true
  SimpleCov.start
else
  Coveralls.wear!
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'vcr'

require 'neo'
require 'neo/sdk'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
end


module TestHelper
  ByteArray       = Neo::ByteArray
  Blockchain      = Neo::SDK::Simulation::Blockchain
  Compiler        = Neo::SDK::Compiler
  ExecutionEngine = Neo::SDK::Simulation::ExecutionEngine
  Header          = Neo::SDK::Simulation::Header
  Simulation      = Neo::SDK::Simulation
  Storage         = Neo::SDK::Simulation::Storage
  Runtime         = Neo::SDK::Simulation::Runtime

  protected

  def compile_and_invoke(name, *parameters)
    script = Compiler.load "test/fixtures/source/#{name}.rb", Logger.new(IO::NULL)
    vm_sim = Simulation.new script
    rb_sim = Simulation.new script.source, script.return_type

    if parameters.empty?
      script.param_types.each.with_index do |type, n|
        parameters << case type
        when :Boolean then Random.rand >= 0.5
        when :Integer then Random.rand(0xffff)
        when :String  then SecureRandom.base64
        else raise NotImplementedError, type
        end
      end
    end

    rb_result = rb_sim.invoke(*parameters)
    vm_result = vm_sim.invoke(*parameters)

    if script.return_type == :Void
      refute rb_result
      refute vm_result
    else
      assert_equal rb_result, vm_result, parameters
    end
    vm_sim
  end

  def load_and_invoke(name, *parameters)
    source = load_source(name)
    vm_sim = load_contract name, source[:return]
    rb_sim = Simulation.new source[:source], source[:return]

    if parameters.empty?
      source[:params].each.with_index do |type, n|
        parameters << case type
        when :Boolean then Random.rand >= 0.5
        when :Integer then Random.rand(0xffff)
        when :String  then SecureRandom.base64
        else raise NotImplementedError, type
        end
      end
    end

    rb_result = rb_sim.invoke(*parameters)
    vm_result = vm_sim.invoke(*parameters)

    if source[:return] == :Void
      refute rb_result
      refute vm_result
    else
      assert_equal rb_result, vm_result, parameters
    end
    vm_sim
  end

  def load_contract(name, return_type = nil)
    Simulation.load "test/fixtures/binary/#{name}.avm", return_type
  end

  def load_source(name)
    source = IO.read("test/fixtures/source/#{name}.rb")
    magic = source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
    meta = { source: source, return: magic["return"].to_sym }
    meta[:params] = magic["params"] ? magic["params"].split(', ').map(&:to_sym) : []
    meta
  end
end
