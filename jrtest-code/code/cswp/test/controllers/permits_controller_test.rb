#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class PermitsControllerTest < ActionController::TestCase

  setup do
    @permit = permits(:one)
  end

  test 'should get permit' do
    get :show, id: @permit    # -> /persons/:id
    @returned_permit = assigns(:permit)

    assert_select 'title', 'Show Permit'
    assert_equal 'Saskatoon', @returned_permit.location
    assert_response :success # 200 OK
  end

  test 'should create permit' do
    assert_difference('Permit.count') do
      post :create, permit: {location: @permit.location}
    end
  end

  test 'should update permit' do
    patch :update, id: @permit, permit: {location: 'Stureby'}
    @updated_permit = assigns(:permit)
    assert_equal 'Stureby', @updated_permit.location
  end

  test 'should delete permit' do
    assert_difference('Permit.count', -1) do
      delete :destroy, id: @permit
    end
  end

  # * <tt>:success</tt>   - Status code was in the 200-299 range
  # * <tt>:redirect</tt>  - Status code was in the 300-399 range
  # * <tt>:missing</tt>   - Status code was 404
  # * <tt>:error</tt>     - Status code was in the 500-599 range

  test 'http status codes' do
    # assert_response :success
    # assert_response :missing
    # assert_response :redirect
    # assert_response :error
  end

  test 'get permit test' do
    # find existing permit
    # read it back
    # check it's contents
  end

  test 'create permit test' do
    # create a new permit
    # read it back
    # check it's contents
  end

  test 'update permit test' do
    # find permit
    # change it
    # verify it was changed
  end

  test 'delete permit test' do
    # find permit
    # delete it
    # verify it was deleted
  end

end

# check the JSON response coming back

# test_case.rb
# You can also send a real document in the simulated HTTP request.
#
#   def test_create
#     json = {book: { title: "Love Hina" }}.to_json
#     post :create, json
#   end
#

# <b>@response</b>::
#      An ActionController::TestResponse object, representing the response
#      of the last HTTP response. In the above example, <tt>@response</tt> becomes valid
#      after calling +post+. If the various assert methods are not sufficient, then you
#      may use this object to inspect the HTTP response in detail.
