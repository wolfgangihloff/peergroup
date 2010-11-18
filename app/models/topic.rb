require 'supervision_part'

class Topic < ActiveRecord::Base
  include SupervisionPart

  has_many :votes, :as => :statement
end

