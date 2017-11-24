#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class RateManagerTest < MiniTest::Test

  def setup
    @manager = RateManager.new(false) # not new customer
  end

  def test_region_required
    assert_raises(ArgumentError) {@manager.lookup_tax_rate(nil)}
  end

  def test_default_tax_rate
    assert_equal(0.3, @manager.lookup_tax_rate('SomeRegion'))
  end

  def test_supported_provinces
    assert_equal(0.1, @manager.lookup_tax_rate('Alberta'))
    assert_equal(0.2, @manager.lookup_tax_rate('Saskatchewan'))
  end

  def test_new_customer
    @manager_new_customer = RateManager.new(true)
    assert_equal(0.0, @manager_new_customer.lookup_tax_rate('Alberta'))
  end

end
