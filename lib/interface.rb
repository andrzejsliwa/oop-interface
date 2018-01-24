require "interface/version"

module Interface
  UnknownInterface = Class.new(StandardError)
  module Abstract
    def self.extended(interface)
      interface.class_eval do
        instance_methods(false).each do |method|
          define_method(method) do |*args, &block|
            methods = [:super, :method_missing]
            begin
              send(methods.shift, *args, &block)
            rescue NoMethodError
              if methods.empty?
                raise NotImplementedError.new("#{self.class} needs to implement '#{method}' for interface #{interface}")
              else
                args.unshift(method.to_sym)
                retry
              end
            end
          end
        end
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def implements(*modules)
      modules.flatten.reverse!.each { |mod| include mod.extend(Abstract) }
    end
    alias_method :implement, :implements

    def interfaces
      klass = is_a?(Class) ? self : self.class
      klass.included_modules.select { |mod| mod.is_a?(Abstract) }
    end

    def unimplemented_methods
      interfaces.inject({}) do |hash, interface|
        methods = unimplemented_methods_for(interface)
        methods.empty? ? hash : hash.merge!(interface => methods)
      end
    end

    def unimplemented_methods_for(interface)
      interface.instance_methods(false).reject do |method|
        !method_defined?(method.to_sym) || instance_method(method.to_sym).owner != interface
      end.sort.map(&:to_sym)
    end
  end

  def as(interface)
    raise UnknownInterface.new(interface) unless self.class.interfaces.include?(interface)
    Class.new do
      def initialize(target)
        @target = target
      end

      interface.instance_methods.select do |method|
        interface.instance_method(method.to_sym).owner == interface
      end.each do |method|
        define_method(method) do |*args, &block|
          @target.public_send(method, *args, &block)
        end
      end

      [:is_a?, :kind_of?, :instance_of?].each do |type_method|
        define_method(type_method) do |target, &block|
          return true if target == interface
          super
        end
      end

      define_method(:inspect) do
        "#<#{interface.name}:#{self.object_id}>"
      end

      def to_s
        inspect
      end
    end.new(self)
  end
end
