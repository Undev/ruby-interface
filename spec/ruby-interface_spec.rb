# -*- coding: utf-8 -*-
require 'spec_helper'

describe RubyInterface do
  def make_interface
    mod = Module.new
    mod.extend(RubyInterface)
    mod
  end
  
  describe "Создание интерфейса" do
    let(:mod) { make_interface.tap { |v| v.interface(:test) } }
    
    it "должен вызываться interfaced, если определен" do
      @proc = proc {}
      klass = Class.new
      mod.interface :int do
        interfaced(&@proc)
      end
      mock(klass).class_eval(&@proc)
      mock(klass).class_eval(&@proc)
      klass.send :include, mod
    end
    
    describe "Класс с интерфейсом" do
      subject { klass }
      let(:klass) { Class.new.tap { |v| v.send :include, mod } }
      let(:interface_klass) { klass.test_interface }
      its(:test) { should eq(interface_klass) }
      
      it "может дополнять класс интерфейса" do
        interface_klass.respond_to?(:test).should be_false
        klass.test do
          mattr_accessor :test
        end
        interface_klass.respond_to?(:test).should be_true
      end
      
      it "должен содержать класс интерфейса" do
        klass::TestInterfaceClass.ancestors.should include(RubyInterface::InterfaceClass)
        klass.test_interface.should eq(klass::TestInterfaceClass)
      end
      
      describe "Класс интерфейса" do
        subject { interface_klass }
        its(:interface_base) { should eq(klass) }
        
        describe "Объект с интерфейсом" do
          subject { obj }
          let(:obj) { klass.new }
          its(:test) { should be_kind_of(interface_klass)}
          describe "Объект интерфейса" do
            subject { interface_obj }
            let(:interface_obj) { obj.test }
            its(:owner) { should eq(obj) }
            let(:mod) do 
              make_interface.tap do |v| 
                v.interface(:test) do
                  def foo
                    "bar"
                  end
                end
              end              
            end
            
            it "должен поддерживать методы определенные в интерфейсе" do
              interface_obj.foo.should eq('bar')
            end
          end
        end
        
        describe "при наследовании" do
          let(:klass2) { Class.new(klass) }
          it "должен создавать новый интерфейс-класс, наследуя старый" do
            klass2.test.ancestors.should include(interface_klass)
          end
          it "новый интерфейс-класс должен ссылаться на новый класс" do
            klass2.test.interface_base.should eq(klass2)
          end
        end
      end
      

    end
  end

  describe "Модуль с двумя интерфейсами" do
    before(:each) do
      @mod = Module.new
      @mod.send :extend, RubyInterface
      @mod.interface :first do
        interfaced do
          def baz
            first.foo
          end
        end
      
        def foo
          "bar"
        end
      end

      @mod.interface :second do
        interfaced do
          self.second_interface.foo
        end

        def self.foo
          "baz"
        end
      end
    end

    it "не должно происходить ошибок при подключении модуля с двумя интерфейсами" do
      b = Class.new
      lambda { b.send :include, @mod }.should_not raise_error
    end

    it "должны появиться интерфейсы с методами" do
      b = Class.new
      b.send :include, @mod
      bb = b.new
      bb.baz.should eq("bar")
      bb.second_interface.foo.should eq("baz")
    end
  end
end