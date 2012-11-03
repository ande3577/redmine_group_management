module GroupPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      safe_attributes 'name',
            'user_ids',
            'custom_field_values',
            'custom_fields',
            :if => lambda {|group, user| !user.nil? && user.allowed_to?({:controller => 'groups', :action => 'index'},nil, :global => true ) && !user.admin?}
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
end


require_dependency 'project'
require_dependency 'group'
require_dependency 'user'
require_dependency 'custom_field'
require_dependency 'custom_field_value'
require_dependency 'member'
require_dependency 'member_role'
Group.send(:include, GroupPatch)