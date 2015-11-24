module Mocha
  def self.callable_returns?
    !!@callable_returns
  end
  def self.with_callable_returns
    was = callable_returns?
    @callable_returns = true
    yield
  ensure
    @callable_returns = was
  end
  class SingleReturnValue
    def is_callable?
      @value.respond_to?(:call) &&
        @value.respond_to?(:arity) && @value.arity.zero?
    end
  end
  module CallableReturnBuilder
    def build(*values)
      super.tap do |rets|
        if Mocha.callable_returns?
          rets.values.each do |val|
            def val.evaluate
              is_callable? ? @value.call : @value
            end
          end
        end
      end
    end
  end
  ReturnValues.singleton_class.send(:prepend, CallableReturnBuilder)
end
