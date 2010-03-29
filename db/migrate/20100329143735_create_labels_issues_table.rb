class CreateLabelsIssuesTable < ActiveRecord::Migration
  def self.up
    create_table :issues_labels, :id => false do |t|
      t.integer :issue_id
      t.integer :label_id
    end
  end

  def self.down
    drop_table :issues_labels
  end
end
