;---
; Excerpted from "The Cucumber for Java Book",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
;---
(require '[clojure-cucumber.core :refer :all])
(require '[clojure.test :refer [is]])

(load-file "test/features/step_definitions/world.clj")

(When #"^I scan a \"(.*?)\"$" [item-name]
      (swap! cart scan @price-list item-name))

(Then #"^the total is (\d+)c$" [expected-total]
      (is (= (force-num expected-total) (checkout @cart))))
