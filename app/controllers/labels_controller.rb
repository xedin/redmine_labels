class LabelsController < ApplicationController
  unloadable
  
  def show
  end
  
  def update
    @label = Label.find_by_id(params[:id])
    params[:label].delete(:global) unless User.current.allowed_to?(:manage_global_labels, nil, :global => true)

    @label.update_attributes(params[:label])

    respond_to do |format|
      format.js
    end
  end

  def create
    @label = Label.new(params[:label])
    @label.user = User.current
    @label.global = false unless User.current.allowed_to?(:manage_global_labels, nil, :global => true)
    @label.save
  end
  
  def destroy
    @label = Label.find(params[:id])
    @label.destroy

    respond_to do |format|
      format.js
    end
  end

  def link
    @label = Label.find_by_id(params[:id])
    @issues = Issue.find(params[:issue_ids])
    
    
    if @label
      @issues.each do |issue|
        if @label.issues_add(issue)
          labels_custom_field = issue.available_custom_fields.detect { |cf| cf.name.downcase == 'label' }
          issue.custom_field_values
          labels_custom_field_value = issue.custom_value_for(labels_custom_field)
          labels_custom_field_value.value = labels_custom_field_value.value.to_s + "|#{@label.id}| "
          labels_custom_field_value.save
        end
      end
    end

    respond_to do |format|
      format.js
    end
   
  end
  
  def unlink
    @label = Label.find_by_id(params[:id])
    @issue = Issue.find_by_id(params[:issue_id])

    if @label and @issue
      @label.unlink_issue(@issue)

      labels_custom_field = @issue.available_custom_fields.detect { |cf| cf.name.downcase == 'label' }
      labels_custom_field_value = @issue.custom_value_for(labels_custom_field)
      labels_custom_field_value.value = labels_custom_field_value.value.gsub("|#{@label.id}| ", "")
      labels_custom_field_value.save
    end

    respond_to do |format|
      format.js { render :text => "Successfully Unlinked!" }
    end
  end
  
end
