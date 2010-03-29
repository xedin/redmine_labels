class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|

      t.column :title, :string

      t.column :user_id, :integer

      t.column :global, :boolean, :default => false, :null => false

      t.column :color, :string, :default => '#ffffff', :limit => 7
      
    end
  end

  def self.down
    drop_table :labels
  end
end
