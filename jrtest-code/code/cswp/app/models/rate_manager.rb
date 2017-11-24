#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class RateManager

  attr_accessor :is_new_customer

  def initialize(is_new_customer)
    @is_new_customer = is_new_customer
  end

  def lookup_tax_rate(region)

    if (region.blank?)
      raise ArgumentError.new('Region can\'t be blank!');
    end

    tax_rate = 0.3

    if (region == 'Alberta')
      tax_rate = 0.1
    end

    if (region == 'Saskatchewan')
      tax_rate = 0.2
    end

    if (@is_new_customer)
      tax_rate = 0.0
    end

    return tax_rate

  end

end