module System::Script::Base
  
  def self.included(mod)
    mod.extend(ClassMethods)
  end
  
  module ClassMethods
    def executable?
      method = caller.first.scan(/`(.*)'/)[0][0]
      class_method = "#{self.name}.#{method}"
      
      com = "ps -ef | grep -e '#{class_method}' | grep -v grep -c"
      pscount = `#{com}`
      return pscount.to_i <= 1
    rescue 
      true
    end
  end
end