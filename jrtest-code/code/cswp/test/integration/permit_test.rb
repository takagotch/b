#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class PermitsIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @permit = permits(:one)
  end

  test 'show permit' do
    get permit_path(@permit)
    assert_select 'title', 'Show Permit'
    assert response.body.to_s.include? 'Saskatoon'
    assert_response :success # 200 OK
  end

  test 'create permit' do
    get new_permit_path
    assert_select 'title', 'Create Permit'

    post permits_path, permit: {location: 'Moose Jaw'}
    follow_redirect!
    assert_select 'title', 'Show Permit'
    assert response.body.to_s.include? 'Moose Jaw'
    assert_select 'div.alert-success'
  end

  test 'edit permit' do
    get edit_permit_path(@permit)
    assert_select 'title', 'Edit Permit'

    patch permit_path(@permit), permit: {location: 'Medicine Hat'}
    follow_redirect!
    assert_select 'title', 'Show Permit'
    assert response.body.to_s.include? 'Medicine Hat'
  end

  test 'delete permit' do
    # no delete page - just an action
    assert_difference 'Permit.count', -1 do
      delete permit_path(@permit)
    end
  end

  test 'delete permit conventional' do
    get permit_path(@permit)
    assert_response :success # 200 OK
    delete permit_path(@permit)

    assert_raises(ActiveRecord::RecordNotFound) do
      get permit_path(@permit)
    end
  end

  test 'HTTP GET' do
    get permit_path(:id => @permit.id, :format => :json)
    # puts response.body
    assert response.body.to_s.include? 'Saskatoon'
    assert_response :success # 200 OK
  end

  test 'HTTP POST' do
    assert_difference 'Permit.count', 1 do
      post permits_path, permit: {location: 'Moose Jaw'}
    end
    assert_response :redirect
  end

  test 'HTTP POST alternative' do
    # search for existing permit
    permit = Permit.find_by_location('Moose Jaw')

    # verify it doesn't exist
    assert_nil permit

    # create it
    post permits_path, permit: {location: 'Moose Jaw'}

    # search for it again
    permit = Permit.find_by_location('Moose Jaw')

    # verify was created
    assert_not_nil permit

    # check status code (302)
    assert_response :redirect
  end

  test 'HTTP PUT' do
    # search for permit by new attribute
    permit = Permit.find_by_location('Medicine Hat')

    # verify it doesn't exist
    assert_nil permit

    # update it
    put permit_path(@permit), permit: {location: 'Medicine Hat'}

    # search for it again
    permit = Permit.find_by_location('Medicine Hat')

    # verify was updated
    assert_not_nil permit

    # check status code (302)
    assert_response :redirect
  end

  test 'HTTP DELETE' do
    delete permit_path(@permit)
    assert_response :redirect

    assert_raises(ActiveRecord::RecordNotFound) do
      get permit_path(@permit)
    end
  end


end



