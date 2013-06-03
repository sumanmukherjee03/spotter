require "active_support/concern"
require "active_support/inflector"
require "observer"

module Spotter
  extend ActiveSupport::Concern

  included do
    include Observable
  end

  def attach_observer(name)
    self.class.fetch_observer(name).new(self)
  end

  def attach_observers(*names)
    names.each { |name| attach_observer(name) }
  end

  module ClassMethods
    def observing_classes
      @observing_classes ||= {}
    end

    def register_observer(observing_klass_name)
      observing_classes[observing_klass_name.to_sym] = "#{name}::#{observing_klass_name.to_s.camelize}".constantize
    rescue NameError
      raise ArgumentError.new("#{observing_klass_name} is not valid. If you have an observer #{name}::FooBar, pass :foo_bar")
    end

    def register_observers(*names)
      names.each { |name| register_observer(name) }
    end

    def fetch_observer(name)
      observing_classes.fetch(name)
    rescue IndexError
      raise ArgumentError.new("#{name} is not registered as an observer")
    end
  end
end

