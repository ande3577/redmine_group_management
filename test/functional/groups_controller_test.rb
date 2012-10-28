require File.expand_path('../../test_helper', __FILE__)

class GroupsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :groups_users
  
  # Replace this with your real tests.
  def test_permissions
    get :manage
    assert_response 302 # will redirect to login
    
    get :index
    assert_response 302 # will redirect to login

    post :add_users, :id => Group.first()
    assert_response 302 # will redirect to login

    #test when logged in without proper permission
    @request.session[:user_id] = 2
    
	get :manage
	assert_response 403

    get :index
    assert_response 403
    
    post :add_users, :id => Group.first()
    assert_response 403
    
    delete :destroy, :id => Group.first()
    assert_response 403 #still don't allow delete
    
    #now add the permission and make sure succeeds for index, still 403 for others
    
    Role.find(2).add_permission! :manage_groups
    
    get :manage
    assert_response 200

    get :index
    assert_response 403
    
    post :add_users, :id => Group.first()
    assert_response 403
    
    delete :destroy, :id => Group.first()
    assert_response 403 #still don't allow delete
    
    #now add the member to the group:
    Group.first.users << User.current
    
    get :manage
    assert_response 200
    
    post :add_users, :id => Group.first()
    assert_redirected_to(:controller => 'groups', :action => 'edit', :tab => "users")
    
    delete :destroy, :id => Group.first()
    assert_response 403 #still don't allow delete
    
  end
  
  def test_add_remove_user
    @request.session[:user_id] = 2
    Role.find(2).add_permission! :manage_groups
    Group.first.users << User.find(2)
    
    # add a single user
    initial_user_count = Group.first().users().count
    post :add_users, :id => Group.first(), :user_id => 1
    assert_redirected_to(:controller => 'groups', :action => 'edit', :tab => "users")
    assert_equal initial_user_count + 1, Group.first().users().count
    
    post :add_users,  :id => Group.first(), :user_ids => [3, 4]
    assert_redirected_to(:controller => 'groups', :action => 'edit', :tab => "users")
    assert_equal initial_user_count + 3, Group.first().users().count
    
    delete :remove_user, :id => Group.first(), :user_id => 1
    assert_redirected_to(:controller => 'groups', :action => 'edit', :tab => "users")
    assert_equal initial_user_count + 2, Group.first().users().count
    
  end
  
end
