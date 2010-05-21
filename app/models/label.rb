class Label < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :fncolor, :bgcolor
  validates_uniqueness_of :title, :scope => :global, :if => :global?
  validates_uniqueness_of :title, :scope => :user_id, :unless => :global?

  default_scope :order => 'id ASC'

  named_scope :global, :conditions => { :global => true }

  named_scope :by_user, lambda { |user|
    { :conditions => { :global => false, :user_id => user } }
  }

  # we were force to do it because on each request to habtm issues association we get
  # TypeError (can't dup NilClass) exception. Feel free to fix it if you can
  
  def self.list_by_issue(issue)
    id = issue.is_a?(Issue) ? issue.id : issue
    
    label_ids = Label.find_by_sql <<-SQL
      SELECT `issues_labels`.`label_id` AS id FROM `issues_labels` WHERE `issues_labels`.`issue_id` = #{id} 
    SQL

    label_ids.map { |l| l.send(:reload) }
  end
  

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

      if global?
        i = issue.is_a?(Issue) ? issue : Issue.find(issue)
        i.init_journal(User.current, "Added '#{title}' global label to this task.")
        i.save
      end

      return true
    end
    return false
  end

  def issues_find(param)
    issue_id = param.is_a?(Issue) ? param.id : param

    Issue.find_by_sql <<-SQL
      SELECT * FROM `issues` 
        INNER JOIN `issues_labels` ON `issues`.id = `issues_labels`.issue_id 
      WHERE (`issues_labels`.label_id = #{id} AND `issues_labels`.issue_id = #{issue_id})
    SQL
  end
  
  def unlink_issue(issue)
    issue_id = issue.is_a?(Issue) ? issue.id : issue
    connection.delete("DELETE FROM `issues_labels` WHERE `issues_labels`.`label_id` = #{id} AND `issues_labels`.`issue_id` = #{issue_id}", "Unlink Issue from Label")

    if global?
      i = issue.is_a?(Issue) ? issue : Issue.find(issue)
      i.init_journal(User.current, "Removed '#{title}' global label from this task.")
      i.save
    end
  end
  
  alias :old_destroy :destroy

  def destroy
    if global?
      issues.each do |issue|
        issue.init_journal(User.current, "Has deleted the '#{title}' global label, which was previously assigned to this task.")
        issue.save
      end
    end

    old_destroy
    connection.delete("DELETE FROM `issues_labels` WHERE `issues_labels`.label_id = #{id}", "IssuesLabels Delete all")
  end

end
