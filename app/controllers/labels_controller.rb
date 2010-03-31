class LabelsController < ApplicationController
  unloadable

#   def index
#     @labels = Label.find_all_by_global(true)
#   end
  
  def update
    @label = Label.find_by_id(params[:id])
    @label.update_attributes(params[:label])

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
      @label.issues << @issue unless @label.issues.find_by_id(@issue.id)
    end

    respond_to do |format|
      format.js
    end
   
  end

  
end
