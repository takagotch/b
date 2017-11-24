#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:user1)
  end

  test "login with valid credentials" do
    get login_path
    post login_path, session: { email: 'user@test.com', password: 'password' }
    follow_redirect!
    assert_select "h1", "Welcome"
  end

  test "login with invalid credentials" do
    get login_path
    post login_path, session: { email: '', password: '' }
    assert_select ".alert.alert-danger",  count: 1
  end

  test "login with valid credentials then by logout" do

    #login
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    follow_redirect!

    # verify logout link now appears
    assert_select "a[href=?]", logout_path

    #logout
    delete logout_path
    assert_redirected_to root_url
    follow_redirect!

    # verify logout link no longer appears
    assert_select "a[href=?]", logout_path,      count: 0
  end

  test "login with valid information original" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'title', "Welcome " + @user.name
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # assert_select "a[href=?]", login_path, count: 0
    # assert_select "a[href=?]", logout_path
    # assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    # assert_select "a[href=?]", login_path
    # assert_select "a[href=?]", logout_path,      count: 0
    # assert_select "a[href=?]", user_path(@user), count: 0
  end

end



# test "login with invalid credentials" do
#   get login_path
#   post login_path, session: { email: '', password: '' }
#   # assert_not flash.empty?
#   assert_select ".alert.alert-danger",  count: 1
# end
