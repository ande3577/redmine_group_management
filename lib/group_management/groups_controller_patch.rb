module GroupsControllerPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      layout :check_layout
      
      before_filter :authorize_global
      skip_before_filter :require_admin
      before_filter :check_membership, :except => [:index]
      before_filter :get_groups, :only => [:index]
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def check_layout
    if !User.current.nil? && !User.current.admin?
      'base'
    else
      'admin'
    end
  end
  
  def check_membership
    # deny access if trying to access a group where not a member
    if !User.current.admin? && (@group.nil? || @group.users.where(:id => User.current.id).empty?)
      deny_access 
    end
  end
  
  def get_groups
    if User.current.admin?
      @visible_groups = Group.sorted.all
    else
      @visible_groups = User.current.groups.sorted.all
    end
  end
  
end #GroupsPatch

GroupsController.send(:include, GroupsControllerPatch)