class RenameQuestionAndAnswerColumnsToContent < ActiveRecord::Migration
  def self.up
    rename_column :questions, :question, :content
    rename_column :answers, :answer, :content
  end

  def self.down
    rename_column :questions, :content, :question
    rename_column :answers, :content, :answer
  end
end

