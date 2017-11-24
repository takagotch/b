;---
; Excerpted from "The Cucumber for Java Book",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
;---
(require '[checkout.checkout :refer [empty-cart empty-price-list]])
(import '[org.junit Assert])

(def cart (atom (empty-cart)))
(def price-list (atom (empty-price-list)))

(defn- force-long
  [maybe-str]
  (Long. maybe-str))

(defn- assert-equals [expected actual]
  (Assert/assertEquals expected actual))

(Before []
        (reset! cart (empty-cart))
        (reset! price-list (empty-price-list)))
