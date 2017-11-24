#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
# require 'test_helper'
#
# class UsersLoginTest < ActionDispatch::IntegrationTest
#
#   test 'can access welcome page' do
#     @user = users(:user1)
#     get login_path
#     post login_path, session: { email: 'user@test.com', password: 'password' }
#     follow_redirect!
#     assert_select 'h1', 'Welcome'
#   end
#
#   test 'can access company financials' do
#     @user = users(:user1)
#     get login_path
#     post login_path, session: { email: 'user@test.com', password: 'password' }
#     follow_redirect!
#     get financials_path
#     assert_select 'h1', 'Financials'
#   end
#
#   test 'can access plans for world domination' do
#     @user = users(:user1)
#     get login_path
#     post login_path, session: { email: 'user@test.com', password: 'password' }
#     follow_redirect!
#     get world_domination_path
#     assert_select 'h1', 'Step1: Take Saskatchewan'
#   end
#
# end
#
# class UsersLoginTestRefactored < ActionDispatch::IntegrationTest
#
#   def setup
#     @user = users(:user1)
#     get login_path
#     post login_path, session: { email: 'user@test.com', password: 'password' }
#     follow_redirect!
#   end
#
#   test 'can access welcome page' do
#     assert_select 'h1', 'Welcome'
#   end
#
#   test 'can access company financials' do
#     assert_select 'h1', 'Financials'
#   end
#
#   test 'can access plans for world domination' do
#     get world_domination_path
#     assert_select 'h1', 'Step1: Take Saskatchewan'
#   end
#
# end