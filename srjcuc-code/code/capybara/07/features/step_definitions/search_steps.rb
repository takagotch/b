#---
# Excerpted from "The Cucumber for Java Book",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
#---
When /^I search for "([^"]*)"$/ do |query|
  visit('/search')
  fill_in('query', :with => query)
  click_button('Search')
end

Then /^the results should be:$/ do |expected_results|
  results = [['content']] + page.all('ol.results li').map do |li|
    [li.text]
  end
  
  expected_results.diff!(results)
end
