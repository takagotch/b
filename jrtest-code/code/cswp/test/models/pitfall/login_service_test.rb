#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'pitfall/login_service'

class LoginServiceTest < MiniTest::Test

  def setup
    @mockRoles = mock()
    @mockPermissions = mock()
    @mockAuthorization = mock()
    @mockAuthentication = mock()
    @mockAnalytics = mock()
    @mockDatabaseAdapter = mock()
    @mockMainFrame = mock()
    @mockLogging = mock()

    @login_service = LoginService.new(@mockRoles, @mockPermissions, @mockAuthorization, @mockAuthentication,
                                  @mockAnalytics, @mockDatabaseAdapter, @mockMainFrame, @mockLogging)
  end

  def test_valid_login
    @mockRoles.expects(:check_role)
    @mockPermissions.expects(:check_permissions)
    @mockAuthorization.expects(:authorize)
    @mockAuthentication.expects(:authenticate)
    @mockAnalytics.expects(:record_login)
    @mockDatabaseAdapter.expects(:connect)
    @mockMainFrame.expects(:predict_weather)
    @mockLogging.expects(:log)

    @login_service.login('username', 'password')

  end

end