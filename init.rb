require 'redmine'

Redmine::Plugin.register :redmine_labels do
  name 'Redmine Labels plugin'
  author 'Pavel A. Yaskevich & Max O. Gilinsky'
  description 'Brings labels support to RedMine'
  version '0.0.1'
  permission :labels, {:labels => [:create, :update, :destroy, :add_issue]}, :public => true
end

ActionController::Routing::Routes.draw do |map|
  map.resources :labels, :member => { :add_issue => :post, :unlink => :post }
end

class << ActionController::Routing::Routes

  def reload!
    ActionController::Routing.use_controllers!(nil)
    load_routes!
  end
    
end
