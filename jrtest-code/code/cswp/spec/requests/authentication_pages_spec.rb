#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

# ORGANIZING
describe 'Authentication' do

  subject { page }

  describe 'signin page' do
    before { visit login_path }

    it { should have_content('Sign in') }
    it { should have_title('Log in') }
  end

end

# SELECTING
describe 'Authentication' do

  subject { page }

  describe 'signin page' do
    before { visit login_path }

    it { should have_content('Sign in') }
    it { should have_title('Log in') }
  end

  describe 'should be able to login' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end
    it { should have_selector('h1', text: 'Welcome' )}
  end

  describe 'should be selectable via name' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit login_path
      fill_in 'session_email', with: user.email
      fill_in 'session_password', with: user.password
      click_button 'Sign in'
    end
    it { should have_selector('h1', text: 'Welcome' )}
  end

  describe 'should be selectable via id' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit login_path
      fill_in 'session[email]', with: user.email
      fill_in 'session[password]', with: user.password
      click_button 'Sign in'
    end
    it { should have_selector('h1', text: 'Welcome' )}
  end

  describe 'should be selectable via text placeholder' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
      # puts page.body
    end
    it { should have_selector('h1', text: 'Welcome' )}
  end

  describe 'should be selectable via element' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit login_path
      find(:css, 'input[type=text]').set(user.email)
      find(:css, 'input[type=password]').set(user.password)
      click_button 'Sign in'
      # puts page.body
    end
    it { should have_selector('h1', text: 'Welcome' )}
  end


end

# http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Actions:fill_in
# https://loadfocus.com/blog/2013/09/05/how-to-locate-web-elements-with-selenium-webdriver/
# http://stackoverflow.com/questions/8297624/how-to-check-a-checkbox-in-capybara

# $("input[type=text]")