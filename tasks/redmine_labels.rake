namespace :redmine_labels do
  namespace :create do

    desc "Create custom field for labels"
    task :custom_field => :environment do |t|
      unless IssueCustomField.find_by_name('Label')
        cf = IssueCustomField.new(:name => 'Label', :field_format => 'string', :is_for_all => true, :is_filter => true, :editable => true)
        cf.trackers << Tracker.all
        cf.save
      end
    end

  end

end
