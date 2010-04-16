class AddIndexesToIssuesLabels < ActiveRecord::Migration
  def self.up
    add_index :issues_labels, :issue_id
    add_index :issues_labels, :label_id
  end

  def self.down
    remove_index :issues_labels, :column => :label_id
    remove_index :issues_labels, :column => :issue_id
  end
end
