module ActiveRecord
  module Acts
    module Tree
      module InstanceMethods
        def path(options = {})
          nodes = ancestors.reverse.push(self)
          nodes.shift if options[:without_root]
          nodes.pop if options[:without_self]
          nodes
        end
        
        def subtree
          down = lambda do |item|
            items = []
            item.children.map{|item| items << item; items += down.call(item)}
            items
          end
          down.call(self)
        end
      end
    end
  end
end
