#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

describe 'When creating a new user' do

  subject { page }

  describe 'with valid credentials' do

    before do
      # create a new user
      visit signup_path
      fill_in 'user_name', with: 'New User'
      fill_in 'user_email', with: 'user@example.com'
      fill_in 'user_password', with: 'foobar'
      fill_in 'user_password_confirmation', with: 'foobar'
      click_button 'Create my account'
    end

    describe 'after saving the user' do
      # find the new user we just created
      let(:user) { User.find_by(email: 'user@example.com') }

      # make some assertions
      it { should have_title(user.name) }
      it { should have_selector('.alert-success') }
    end
  end

  describe 'with invalid credentials' do

    before do
      visit signup_path
      click_button 'Create my account'
    end

    it { should have_selector('.alert.alert-danger') }

  end
end

# with placeholder text
describe 'When creating a new user' do

  subject { page }

  describe 'with valid credentials' do

    before do
      # create a new user
      visit signup_path
      fill_in 'Name', with: 'New User'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'foobar'
      fill_in 'Confirmation', with: 'foobar'
      click_button 'Create my account'
    end

    describe 'after saving the user' do
      # find the new user we just created
      let(:user) { User.find_by(email: 'user@example.com') }

      # make some assertions
      it { should have_content(user.name) }
      it { should have_selector('.alert-success') }
    end
  end
end

describe 'Signup' do

  subject { page }

# with id tags
  describe 'with valid credentials' do

    before do
      # create a new user
      visit signup_path
      fill_in 'user_name', with: 'New User'
      fill_in 'user_email', with: 'user@example.com'
      fill_in 'user_password', with: 'foobar'
      fill_in 'user_password_confirmation', with: 'foobar'
      click_button 'Create my account'
    end

  end


# sign up page
  describe 'Signin page' do
    before { visit signup_path }

    it { should have_content('Sign Up') }
    it { should have_title('Sign Up') }
  end


# everything
  describe 'Signup page' do

    let(:submit) { 'Create my account' }
    before { visit signup_path }

    describe 'with valid credentials' do
      before do
        fill_in 'user_name', with: 'New User'
        fill_in 'user_email', with: 'user@example.com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        # it { should have_selector('div.alert-success', text: 'Success!') }
        it { should have_selector('.alert-success') }
      end

    end

    describe 'with invalid information' do
      before { click_button submit }
      it { should have_selector('.alert-danger') }
    end

  end


# without id tags
  describe 'with valid information' do

    before do
      # create a new user
      visit signup_path
      all(:css, 'input[type=text]')[0].set('New User')
      all(:css, 'input[type=text]')[1].set('user@example.com')
      all(:css, 'input[type=password]')[0].set('foobar')
      all(:css, 'input[type=password]')[1].set('foobar')
      find(:css, '.btn-large').click
    end

  end

end


# describe 'with invalid information' do
#   it 'should not create a user' do
#     expect { click_button submit }.not_to change(User, :count)
#   end
# end

# it 'should create a user' do
#   expect { click_button submit }.to change(User, :count).by(1)
# end
#

# http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Actions:fill_in