class Supervision < ActiveRecord::Base

  validates_inclusion_of :state, :in => %w{topic topic_vote finished}

  belongs_to :group
  has_many :topics

  scope :unfinished, :conditions => ["state <> ?", "finished"]

  before_validation(:on => :create) { self.state ||= "topic" }

  def all_topics?
    group.members.all? {|m| !topics.where(:author_id => m.id).empty? }
  end
end

