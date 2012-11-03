
# Patches to the Redmine core.
require 'group_management/groups_controller_patch'

Redmine::Plugin.register :redmine_group_management do
  name 'Redmine Group Management plugin'
  author 'David Anderson'
  description 'Allow a user to manage group memberships without admin priveleges.'
  version '0.0.1'
  url 'https://github.com/ande3577/redmine_group_management'
  author_url 'https://github.com/ande3577/'
  
  project_module :groups do
    permission :manage_groups, :groups => [:index, :edit, :show, :edit_membership, :add_users, :remove_user, :destroy_membership, :update]
  end
  
  menu :top_menu, :group_manager_main_menu, {:controller => 'groups', :action => 'index'}, :caption => :label_group_plural,
   :if => Proc.new { !User.current.nil? && User.current.allowed_to?({:controller => 'groups', :action => 'index'},nil, :global => true ) && !User.current.admin? }
end
