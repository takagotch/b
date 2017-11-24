#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class ConnectionHandlerTest < MiniTest::Test

  def setup
    @mockClient = mock()
    @connection_handler = ConnectionHandler.new(@mockClient)
  end

  def test_is_challenge
    message = { :type => 'challenge' }
    assert(@connection_handler.is_challenge(message))
  end

  def test_is_welcome
    message = { :type => 'welcome' }
    assert(@connection_handler.is_welcome(message))
  end

  def test_authentication_sent_when_challenge_received
    @mockClient.expects(:send_authenticate_message).at_least_once

    message = { :type => 'challenge' }
    @connection_handler.receive(message)
  end

end
