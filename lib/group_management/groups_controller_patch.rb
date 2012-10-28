module GroupsControllerPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      layout :check_layout
      
      before_filter :authorize_global
      skip_before_filter :require_admin, :only => [:manage, :edit, :show, :edit_membership, :add_users, :remove_user, :destroy_membership]
      skip_before_filter :find_group, :only => [:manage]
      before_filter :check_membership, :except => [:manage]
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
  
  def manage
    @groups = User.current.groups.sorted.all
    
    respond_to do |format|
      format.html
      format.api
    end
  end
  
end #GroupsPatch

GroupsController.send(:include, GroupsControllerPatch)