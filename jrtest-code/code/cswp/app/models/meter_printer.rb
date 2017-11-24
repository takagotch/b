#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class MeterPrinter

  def print(m)
r = StringIO.new
                case m.type
when 'gas'
  r << "Meter Report\n"
  r << "Type: Gas\n"
  r << "Construction Co. Ltd.\n"
  when 'wind'
      r << "Meter Report\n"
      r << "Type: Wind\n"
      r << "Construction Co. Ltd.\n"
    when 'solar'
        r << "Meter Report\n"
        r << "Type: Solar\n"
        r << "Construction Co. Ltd.\n"
    end
return r.string
  end

end

class MeterPrinter_spaced

  def print(m)

    r = StringIO.new

    case m.type
      when 'gas'
        r << "Meter Report\n"
        r << "Type: Gas\n"
        r << "Construction Co. Ltd.\n"
      when 'wind'
        r << "Meter Report\n"
        r << "Type: Wind\n"
        r << "Construction Co. Ltd.\n"
      when 'solar'
        r << "Meter Report\n"
        r << "Type: Solar\n"
        r << "Construction Co. Ltd.\n"
    end

    return r.string

  end

end

class MeterPrinter_named

  def print(meter)

    report = StringIO.new

    case meter.type
      when 'gas'
        report << "Meter Report\n"
        report << "Type: Gas\n"
        report << "Construction Co. Ltd.\n"
      when 'wind'
        report << "Meter Report\n"
        report << "Type: Wind\n"
        report << "Construction Co. Ltd.\n"
      when 'solar'
        report << "Meter Report\n"
        report << "Type: Solar\n"
        report << "Construction Co. Ltd.\n"
    end

    return report.string

  end

end

class MeterPrinter_refactored

  def print(meter)

    report = StringIO.new

    report << "Meter Report\n"

    case meter.type
      when 'gas'
        report << "Type: Gas\n"
      when 'wind'
        report << "Type: Wind\n"
      when 'solar'
        report << "Type: Solar\n"
    end

    report << "Construction Co. Ltd.\n"

    return report.string

  end

end