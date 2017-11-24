#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

describe 'Authentication' do

  subject { page }

  describe 'signin page' do
    before { visit login_path }

    it { should have_content('Sign in') }
    it { should have_title('Log in') }
  end

  describe 'signin' do
    before { visit login_path }

    describe 'with valid information' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        fill_in 'Email', with: user.email.upcase
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      it { should have_title(user.name) }
      it { should have_link('Sign out', href: logout_path) }
      it { should_not have_link('Sign in', href: login_path) }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
      end
    end

    describe 'with invalid information' do
      before { click_button 'Sign in' }

      it { should have_title('Log in') }

      describe 'after visiting another page' do
        before { click_link 'Home' }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

  end

end
