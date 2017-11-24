#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

describe 'Signup Page' do

  subject { page }

  # without ids
  it 'should be able to access' do
    visit signup_path
    # puts page.body
    all(:css, 'input[type=text]')[0].set('New User')
    all(:css, 'input[type=text]')[1].set('user@example.com')
    all(:css, 'input[type=password]')[0].set('foobar')
    all(:css, 'input[type=password]')[1].set('foobar')
    find(:css, '.btn-large').click
  end

  # with ids
  it 'should be able to access' do
      visit signup_path
      # puts page.body
      fill_in 'user_name', with: 'New User'
      fill_in 'user_email', with: 'user@example.com'
      fill_in 'user_password', with: 'foobar'
      fill_in 'user_password_confirmation', with: 'foobar'
      click_button 'Create my account'
  end

end

describe 'Signup' do

  subject { page }

  describe 'signin page' do
    before { visit signup_path }

    it { should have_title('Sign Up') }
    it { should have_content('Sign Up') }
  end

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

  describe 'signup' do

    before { visit signup_path }

    describe 'with invalid information' do
      it 'should not create a user' do
        click_button 'Create my account'
        should have_selector('div.alert.alert-danger')
      end
    end

  end

end



# describe 'with invalid information' do
#   it 'should not create a user' do
#     expect { click_button submit }.not_to change(User, :count)
#   end
# end




