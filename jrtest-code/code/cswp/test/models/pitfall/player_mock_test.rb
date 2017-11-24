#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'pitfall/player_mock'
require 'pitfall/connector'

class PlayerMockTest < MiniTest::Test

  def setup
    @mockConnector = mock()
    @player = PlayerMock.new(@mockConnector)
  end

  def test_connector_reconnects_if_not_connected
    @mockConnector.expects(:is_connected).returns(false)
    @mockConnector.expects(:connect)
    @mockConnector.expects(:handle_request)
    @player.playTrack('track:xxx')
  end

  def test_can_play_valid_track
    @mockConnector.expects(:is_connected).returns(true)
    @mockConnector.expects(:handle_request).returns(true)
    assert @player.playTrack('valid_track')
  end

  def test_fails_with_invalid_track
    @mockConnector.expects(:is_connected).returns(true)
    @mockConnector.expects(:handle_request).returns(false)
    assert !@player.playTrack('invalid_track')
  end

end