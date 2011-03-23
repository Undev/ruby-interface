RubyInterface
=============

Простенький патерн определения интерфейсов в руби. В противовес стандартным миксинам, для каждого интерфейса создается свой класс и соответсвенно экземпляр класса для каждого объекта с интерфейсом.

    module Tree
      extend RubyInterface
      interface :tree do
        include Enumerable
        attr_accessor :parent
    
        def childs
          @childs ||= []
        end
    
        def each(&blk)
          blk.call(owner)
          childs.each { |v| v.tree.each(&blk) }
        end
    
        def set_parent(parent)
          parent.tree.childs << owner
          @parent = parent
        end
      end
    end

    class A
      include Tree
    end

При разработке интерфейса не нужно задумываться о конфликтах имен переменных, методов, можно делать все что угодно. Аргументом к методу interface передается название метода, по которому этот интерфейс будет доступен.

    a = A.new
    b = A.new

    a.tree.set_parent b
    b.tree.childs # => [a]
    b.tree.map { |o| o } # => [b, a]
    
А при использовании методов относящихся к интерфейсу мы явно видим к какому же интерфейсу он относится. Всем профит!

В интерфейсе доступен метод owner, возвращающий родительский объект. У класса интерфейса есть <tt>interface_base</tt>, возвращающий класс, куда интерфейс был заинклужен.

Помимо инстанс метода, создается так же класс-метод. В него можно передать блок, который выполнится в скоупе класса интерфейса. Сам метод возвращает класс интерфейса.

    module StateMachine
      extend RubyInterface
      interface :state_machine do
        def self.state(name)
          puts "New state #{name}"
        end
      end
    end

    class A
      include StateMachine
  
      state_machine do
        state(:parked) # => New state parked
        state(:idling) # => New state idling
      end
    end
    
При наследовании класса с интерфейсом, создается новый класс интерфейса и наследуется от предыдущего, т.е. повторяет иерархию класса, в который он включен.

Если в блоке <tt>interface</tt> вызывается метод <tt>interfaced</tt>, то исполнение блока, передаваемого <tt>interfaced</tt> 
происходит после добавления интерфейса в класс, в контексте этого класса.

Пример:
   
     module A
       extend RubyInterface
       interface :int do
         interfaced do
           def baz
             self.class.int_interface.foo
           end
         end
     
         def self.foo
           "bar"
         end
       end
     end
     
     class B
       include A
     end
     
     B.new.baz # => "bar"

В каждом модуле может быть определено произвольное количество интерфейсов