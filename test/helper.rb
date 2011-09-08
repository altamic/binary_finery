$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# TODO: resort to test_unit where minitest
# is not available and don't require
# anything
begin; gem 'minitest' if RUBY_VERSION =~ /^1\.9/; rescue Gem::LoadError; end

begin
  require 'minitest/autorun'
rescue LoadError
  require 'rubygems'
  require 'minitest/autorun'
end

require 'binary_finery'

module BinaryFinery
  class TestCase < MiniTest::Unit::TestCase
    #
    # Test::Unit backwards compatibility
    #
    begin
      alias :assert_no_match   :refute_match
      alias :assert_not_nil    :refute_nil
      alias :assert_raise      :assert_raises
      alias :assert_not_equal  :refute_equal
    end if RUBY_VERSION =~ /^1\.9/

    def fixture_path
      File.join(File.dirname(__FILE__), 'fixtures')
    end

    def lib_path
      File.join(File.dirname(__FILE__), '../lib')
    end

    def random_string(length)
      (0...length).inject("") { |m,n| m  << (?A + rand(25)).chr }
    end

    def random_integer(bits, type=:uint)
      (type.equal? :int) ? -1*rand(2**(bits-1)) : rand(2**bits)
    end
  end
end
