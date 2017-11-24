#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

describe 'Signup' do

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

      # check for the success message, along with the user's name
      it { should have_selector('div.alert.alert-success') }
      it { should have_content(user.name) }
    end
  end

  describe 'with invalid credentials' do

    before { visit signup_path }

    describe 'with no credentials' do
      it 'should not create a user' do
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    describe 'when creating a user' do
      it 'should not create if user name is blank' do
        fill_in 'user_name', with: '' # <- blank
        fill_in 'user_email', with: 'user@example.com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    describe 'with no email' do
      it 'should not create a user' do
        fill_in 'user_name', with: 'New User'
        # fill_in 'user_email', with: 'user@example.com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    describe 'with a really long name' do
      it 'should not create a user' do
        fill_in 'user_name', with: 'a' * 51
        fill_in 'user_email', with: 'user@example.com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    describe 'with a really long email' do
      it 'should not create a user' do
        fill_in 'user_name', with: 'New User'
        fill_in 'user_email', with: 'a' * 256
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    describe 'with invalid email address' do
      it 'should not create a user' do
        fill_in 'user_name', with: 'New User'
        fill_in 'user_email', with: 'user @ example , com'
        fill_in 'user_password', with: 'foobar'
        fill_in 'user_password_confirmation', with: 'foobar'
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

    # how to test duplicate email addresses ... that's a lot work!

    describe 'with short password' do
      it 'should not create a user' do
        fill_in 'user_name', with: 'New User'
        fill_in 'user_email', with: 'user @ example , com'
        fill_in 'user_password', with: 'a' * 5
        fill_in 'user_password_confirmation', with: 'a' * 5
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end


  end

end
