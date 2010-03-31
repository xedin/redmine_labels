class Label < ActiveRecord::Base
  
  belongs_to :user
  has_and_belongs_to_many :issues
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :fncolor, :bgcolor

  named_scope :global, :conditions => { :global => true }
  
  named_scope :by_user, lambda { |user|
    { :conditions => { :global => false, :user_id => user } }
  }
  
end
