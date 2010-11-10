class Supervision < ActiveRecord::Base

  validates_inclusion_of :state, :in => %w{topic finished}

  belongs_to :group
  has_many :topics

  scope :unfinished, :conditions => ["state <> ?", "finished"]

  before_validation(:on => :create) { self.state ||= "topic" }
end

