class Label < ActiveRecord::Base
  
  belongs_to :user
  # has_and_belongs_to_many :issues
  #   :finder_sql => 
  #     "SELECT * FROM `issues` INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id WHERE (`issues_labels`.label_id = #{@id} )",
  #   :counter_sql =>
  #     "SELECT count(*) AS count_all FROM `issues` INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id WHERE (`issues_labels`.label_id = #{@id} )"
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :fncolor, :bgcolor

  default_scope :order => 'id ASC'

  named_scope :global, :conditions => { :global => true }
  
  named_scope :by_user, lambda { |user|
    { :conditions => { :global => false, :user_id => user } }
  }
  

  # we were force to do it because on each request to habtm issues association we get
  # TypeError (can't dup NilClass) exception. Feel free to fix it if you can

  def issues
    Issue.find_by_sql <<-SQL
      SELECT * FROM `issues` 
        INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id 
      WHERE (`issues_labels`.label_id = #{id} )
    SQL
  end

  def issues_count
    Issue.count_by_sql <<-SQL
      SELECT count(*) FROM `issues` 
        INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id 
      WHERE (`issues_labels`.label_id = #{id} )
    SQL
  end

  def issues_add(issue)
    if issues_find(issue).empty?
      connection.execute <<-SQL
        INSERT INTO `issues_labels` VALUES(#{issue.id}, #{id})
      SQL
    end
  end

  def issues_find(param)
    issue_id = param.is_a?(Issue) ? param.id : param

    Issue.find_by_sql <<-SQL
      SELECT * FROM `issues` 
        INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id 
      WHERE (`issues_labels`.label_id = #{id} AND `issues_labels`.issue_id = #{issue_id})
    SQL
  end

  alias :old_destroy :destroy

  def destroy
    old_destroy
    connection.delete("DELETE FROM `issues_labels` WHERE `issues_labels`.label_id = #{id}", "IssuesLabels Delete all")
  end

end
