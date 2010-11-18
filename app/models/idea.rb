require 'supervision_part'

class Idea < ActiveRecord::Base
  include SupervisionPart

  validates_presence_of :content

  validates_numericality_of :rating, :allow_nil => true

  scope :not_rated, :conditions => "rating IS NULL"

end

