#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class LoginService

  attr_accessor :roles
  attr_accessor :permissions
  attr_accessor :authorization
  attr_accessor :authentication
  attr_accessor :analytics
  attr_accessor :databaseadapter
  attr_accessor :mainframe
  attr_accessor :logging

  def initialize(roles, permissions, authorization, authentication, analytics, databaseadapter, mainframe, logging)
    @roles = roles
    @permissions = permissions
    @authorization = authorization
    @authentication = authentication
    @analytics = analytics
    @databaseadapter = databaseadapter
    @mainframe = mainframe
    @logging = logging
  end

  def login(username, password)
    @roles.check_role
    @permissions.check_permissions
    @authorization.authorize
    @authentication.authenticate
    @analytics.record_login
    @databaseadapter.connect
    @mainframe.predict_weather
    @logging.log
  end

end