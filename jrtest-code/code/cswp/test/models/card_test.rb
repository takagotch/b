#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class CardTest < MiniTest::Test

  def setup
    @card = Card.new(2, 'Hearts')
  end

  def test_new_card
    assert_equal(2, @card.value)
    assert_equal('Hearts', @card.suit)
  end

end


class WhenSomethingHappens

  def setup
    # prepare data/context and do something
  end

  def then_foo
    # assert foo outcome
  end

  def then_bar
    # assert bar outcome
  end

end

class WhenCreatingANewCard < MiniTest::Test

  def setup
    @card = Card.new(2, 'Hearts')
  end

  def test_that_card_value_is
    assert_equal(2, @card.value)
  end

  def test_that_card_suit_is
    assert_equal('Hearts', @card.suit)
  end

end