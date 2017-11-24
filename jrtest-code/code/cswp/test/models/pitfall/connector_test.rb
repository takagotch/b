#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'pitfall/connector'

class ConnectorTest < MiniTest::Test

  def setup
    @mockHandler = mock()
    @connector = Connector.new(@mockHandler)
  end

  def test_handler_handles_request_when_playing_track
    @mockHandler.expects(:handle_request)
    @connector.handle_request('track:xxx')
  end

end