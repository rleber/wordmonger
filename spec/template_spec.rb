# Helper methods and definitions for RSpec

require 'pry'

MAXIMUM_SIZE = 10
MAXIMUM_RANDOM = 1000

def random(from, to)
  raise "to must be >= from" unless to >= from
  limit = to-from+1
  rand(limit) + from
end

def generate_random_array(size=random(0,MAXIMUM_SIZE-1))
  a = Array.new
  size.times { a <<random(-MAXIMUM_RANDOM, MAXIMUM_RANDOM) }
  a
end

module Helpers
  def aligned_messages(*args)
    return [] if args.size==0
    pairs = args.each_slice(2).to_a
    prefix_width = pairs.map{|prefix, _| prefix.size}.max
    pairs.map {|prefix, msg| "  #{prefix.rjust(prefix_width)}: #{msg}"}
  end

  def custom_failure_message(message, expected, got)
    ([message.to_s] + aligned_messages("expected", expected, "got", got)).join("\n")
  end

  def as_expected(arg, meth, expectation, fail_message, &res_block)
    original_arg = arg.dup
    test_arg = original_arg.dup
    res = test_arg.send(meth)
    expected_res = expectation
    failure_message = custom_failure_message("#{original_arg.inspect}.#{meth} #{fail_message}:", expected_res, res)
    res = expect(yield(test_arg, res)).to eq(expected_res), failure_message
    res
  end
end

RSpec.configure do |c|
  c.include Helpers
end
