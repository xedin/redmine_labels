class LabelsController < ApplicationController
  unloadable

#   def index
#     @labels = Label.find_all_by_global(true)
#   end

  def show
  end
  
  def update
    @label = Label.find_by_id(params[:id])
    old_title = @label.title.dup

    if @label.update_attributes(params[:label])
      unless old_title == @label.title
        @label.issues.each do |issue|
          labels_custom_field = issue.available_custom_fields.detect { |cf| cf.name.downcase == 'label' }
          labels_custom_field_value = issue.custom_value_for(labels_custom_field)
          labels_custom_field_value.value = labels_custom_field_value.value.gsub("#{old_title}|", "#{@label.title}|")
          labels_custom_field_value.save
        end
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def create
    @label = Label.new(params[:label])
    @label.user = User.current
    @label.save
  end
  
  def destroy
    @label = Label.find(params[:id])
    @label.destroy

    respond_to do |format|
      format.js
    end
  end

  def add_issue
    @label = Label.find_by_id(params[:id])
    @issue = Issue.find_by_id(params[:issue_id])
    
    
    if @label && @issue
      if @label.issues_add(@issue)
        labels_custom_field = @issue.available_custom_fields.detect { |cf| cf.name.downcase == 'label' }
        @issue.custom_field_values
        labels_custom_field_value = @issue.custom_value_for(labels_custom_field)
        labels_custom_field_value.value += "#{@label.title}|"
        labels_custom_field_value.save
      end
    end

    respond_to do |format|
      format.js
    end
   
  end

  
end
