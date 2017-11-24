#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'pitfall/player_simple_mock'
require 'pitfall/connector'

class PlayerMockSimpleTest < MiniTest::Test

  def setup
    @mockConnector = mock()
    @player = PlayerSimpleMock.new(@mockConnector) # remember PlayerMock -> Player
  end

  def test_connect_handles_request_when_playing_track
    @mockConnector.expects(:handle_request)
    @player.playTrack('track:xxx')
  end

end

