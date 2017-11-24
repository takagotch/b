#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'spec_helper'

describe 'Permits' do
  subject { page }
  describe 'new permit page' do

    before { visit new_permit_path }

    describe 'when creating a new valid permit' do

      it 'should have the right title' do
        have_title('New Permit')
      end

      it 'should create a permit' do
        fill_in 'Location', with: 'Saskatoon'
        expect { click_button 'Create Permit' }.to change(Permit, :count).by(1)
      end

      it 'should redirect after successful creation' do
        fill_in 'Location', with: 'Saskatoon'
        click_button 'Create Permit'
        expect(page).to have_title('Show Permit')
      end

      it 'should display success message' do
        fill_in 'Location', with: 'Saskatoon'
        click_button 'Create Permit'
        have_selector('div.alert.alert-success')
      end
    end
  end
end

describe 'Permits' do
  subject { page }
  describe 'new permit page' do

    before { visit new_permit_path }

    describe 'when creating a new valid permit' do

      it { should have_title('Create Permit') }

      it 'should create a permit' do
        fill_in 'Location', with: 'Saskatoon'
        expect { click_button 'Create Permit' }.to change(Permit, :count).by(1)
        expect(page).to have_title('Show Permit')
        have_selector('div.alert.alert-success')
      end

    end
  end
end

describe 'Permits' do
  subject { page }
  describe 'new permit page' do

    before { visit new_permit_path }

    it { should have_title('Create Permit') }

    describe 'when creating a new permit' do

      before do
        fill_in 'Location', with: 'Saskatoon'
        click_button 'Create Permit'
      end

      it { should have_title('Show Permit') }
      it { should have_selector('div.alert.alert-success') }

    end

    describe 'when saving to database' do
      it 'should increment the permit count' do
        expect { click_button 'Create Permit' }.to change(Permit, :count).by(1)
      end
    end
  end
end


# http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Actions:fill_in
# it { should have_title('New Permit') }
