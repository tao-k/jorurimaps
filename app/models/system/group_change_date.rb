class System::GroupChangeDate < ActiveRecord::Base

  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator


  validates :start_at,              :presence => true

end
