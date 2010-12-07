class CreateFeedbacks < ActiveRecord::Migration

  # We have to redefine this classes here, to allow safely
  # migrate database. Otherwise this migration would use class
  # definition from models, which depends on STI and observers
  # callbacks.
  class IdeasFeedback < ActiveRecord::Base
  end
  class SolutionsFeedback < ActiveRecord::Base
  end


  def self.up
    create_table :feedbacks do |t|
      t.string :type
      t.text :content
      t.references :supervision
      t.references :user

      t.timestamps
    end

    IdeasFeedback.all.each do |f|
      feedback = Feedback.new(:content => f.content,
                              :supervision_id => f.supervision_id,
                              :user_id => f.user_id)
      feedback.type = "IdeasFeedback"
      feedback.save!
    end
    drop_table :ideas_feedbacks
    SolutionsFeedback.all.each do |f|
      feedback = Feedback.new(:content => f.content,
                              :supervision_id => f.supervision_id,
                              :user_id => f.user_id)
      feedback.type = "SolutionsFeedback"
      feedback.save!
    end
    drop_table :solutions_feedbacks
  end

  def self.down
    create_table :ideas_feedbacks do |t|
      t.text :content
      t.references :supervision
      t.references :user
    end
    IdeasFeedback.reset_column_information
    create_table :solutions_feedbacks do |t|
      t.text :content
      t.references :supervision
      t.references :user
    end
    SolutionsFeedback.reset_column_information
    Feedback.all.each do |f|
      klass = "::CreateFeedbacks::#{f.type.to_s}".constantize
      if [IdeasFeedback,SolutionsFeedback].include?(klass)
        feedback = klass.new(:content => f.content,
                             :supervision_id => f.supervision_id,
                             :user_id => f.user_id)
        feedback.save!(false)
      end
    end
    drop_table :feedbacks
  end
end
