class LabelsController < ApplicationController
  unloadable

  def index
    @labels = Label.find_all_by_global(true)
  end

end
