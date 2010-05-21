class AddArchivedFieldToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :labels, :archived
  end
end
