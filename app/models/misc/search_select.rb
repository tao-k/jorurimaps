# -*- encoding:utf-8 -*-
class Misc::SearchSelect < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  serialize :selects

end
