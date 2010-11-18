module SupervisionPart
  def self.included(base)
    base.validates_presence_of :user, :user_id
    base.validates_presence_of :supervision, :supervision_id

    base.belongs_to :user
    base.belongs_to :supervision
  end
end

