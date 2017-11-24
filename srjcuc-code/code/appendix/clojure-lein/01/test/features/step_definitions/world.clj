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

(def cart (atom (empty-cart)))
(def price-list (atom (empty-price-list)))

(defn- force-num
  [maybe-str]
  (num
   (if (instance? String maybe-str)
     (Long/parseLong maybe-str 10)
     maybe-str)))

(Before []
        (reset! cart (empty-cart))
        (reset! price-list (empty-price-list)))
