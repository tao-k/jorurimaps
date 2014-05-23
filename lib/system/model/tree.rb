# encoding: utf-8
module System::Model::Tree
  def parent_tree(options = {})
    Util::Tree.climb(id, options.merge(:class => self.class))
  end
end
