#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class StubWeatherForecaster

  def predict_weather(city)
    if city === 'Hawaii'
      return 30
    elsif city === 'Stockholm'
      return 0
    elsif city === 'Winnepag'
      return -20
    end
  end

end