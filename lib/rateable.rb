module Rateable
  def self.included(base)
    base.validates_numericality_of :rating, :allow_nil => true
    base.scope :not_rated, :conditions => "rating IS NULL"
  end
end

