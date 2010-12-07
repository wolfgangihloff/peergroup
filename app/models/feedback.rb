class Feedback < ActiveRecord::Base
  belongs_to :supervision
  belongs_to :user
end
