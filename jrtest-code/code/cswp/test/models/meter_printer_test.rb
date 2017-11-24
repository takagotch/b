#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class MeterPrinterTest < MiniTest::Test

  def test_print_gas

    header = "Meter Report\n"
    footer = "Construction Co. Ltd.\n"

    gas_meter = Meter.new('gas')
    meter_printer = MeterPrinter.new
    report = meter_printer.print(gas_meter)

    expected = header + "Type: Gas\n" + footer
    assert_equal(expected, report)

  end

  def test_print_wind

    header = "Meter Report\n"
    footer = "Construction Co. Ltd.\n"

    wind_meter = Meter.new('wind')
    meter_printer = MeterPrinter.new
    report = meter_printer.print(wind_meter)

    expected = header + "Type: Wind\n" + footer
    assert_equal(expected, report)

  end

  def test_print_solar

    header = "Meter Report\n"
    footer = "Construction Co. Ltd.\n"

    solar_meter = Meter.new('solar')
    meter_printer = MeterPrinter.new
    report = meter_printer.print(solar_meter)

    expected = header + "Type: Solar\n" + footer
    assert_equal(expected, report)

  end

end



class MeterPrinterTest_refactored < MiniTest::Test

  def setup
    @header = "Meter Report\n"
    @footer = "Construction Co. Ltd.\n"
    @meter_printer = MeterPrinter.new
  end

  def test_print_gas

    gas_meter = Meter.new('gas')
    report = @meter_printer.print(gas_meter)

    expected = @header + "Type: Gas\n" + @footer
    assert_equal(expected, report)

  end

  def test_print_wind

    wind_meter = Meter.new('wind')
    report = @meter_printer.print(wind_meter)

    expected = @header + "Type: Wind\n" + @footer
    assert_equal(expected, report)

  end

  def test_print_solar

    solar_meter = Meter.new('solar')
    report = @meter_printer.print(solar_meter)

    expected = @header + "Type: Solar\n" + @footer
    assert_equal(expected, report)

  end

end

