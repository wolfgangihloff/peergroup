require 'supervision_part'
require 'rateable'

class Solution < ActiveRecord::Base
  include SupervisionPart
  include Rateable

  validates_presence_of :content
end

