# -*- coding: utf-8 -*-
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

module RubyInterface
  def interface(method_name, &interface_body)
    mod_inst = self.const_set("#{method_name.to_s.camelize}InstanceMethods", Module.new)
    mod_inst.module_eval <<-EOT, __FILE__, __LINE__ + 1
      def #{method_name}
        @#{method_name}_interface ||= self.class.#{method_name}_interface.new(self)
      end                                                             
      EOT


    mod_class = self.const_set("#{method_name.to_s.camelize}ClassMethods", Module.new)
    mod_class.module_eval <<-EOT, __FILE__, __LINE__ + 1
      def #{method_name}(&blk)
        self.#{method_name}_interface.class_eval(&blk) if blk
        self.#{method_name}_interface
      end

      def inherited(subclass)
        new_class = subclass.const_set("#{method_name.to_s.camelize}InterfaceClass", Class.new(self.#{method_name}_interface))
        new_class.interface_base = subclass
        subclass.#{method_name}_interface = new_class
        super
      end
      EOT

    interface_module = self
    
    add_interface do |base|
      base.send(:class_attribute, "#{method_name}_interface")
      interface_class = base.const_set("#{method_name.to_s.camelize}InterfaceClass", Class.new(RubyInterface::InterfaceClass))
      interface_class.interface_base = base
      interface_class.class_eval(&interface_body) if interface_body
      base.send("#{method_name}_interface=", interface_class)
      base.extend mod_class
      base.send :include, mod_inst
      base.class_eval(&interface_class.interfaced) if interface_class.interfaced
    end

    interface_module.define_singleton_method(:included) do |base|
      @_deps.each {|d| d.call(base)}
    end
  end

  private
  def add_interface &block
    @_deps ||= []
    @_deps << block
  end

  class InterfaceClass
    class_attribute :interface_base
    attr_accessor :owner      
    def initialize(owner)
      @owner = owner
    end

    class << self
      def interfaced(&block)
        if block_given?
          @_interfaced_block = block
        else
          @_interfaced_block
        end
      end
    end
  end
end
