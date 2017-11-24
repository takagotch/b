#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'
require 'pitfall/player_stub'
require 'pitfall/fake_transport'

class PlayerStubTest < MiniTest::Test

  def setup
    @fakeTransport = FakeTransport.new
    @player = PlayerStub.new(@fakeTransport)
  end

  def test_can_play_valid_track
    assert @player.playTrack('valid_track')
  end

  def test_fails_with_invalid_track
    assert !@player.playTrack('invalid_track')
  end

end