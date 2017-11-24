;---
; Excerpted from "The Cucumber for Java Book",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
;---
(ns clojure-cucumber.core)

(defn empty-cart [] '())
(defn empty-price-list [] {})

(defn add-to-price-list
  "Adds a series of item-price pairs to the list of prices, e.g.
  (add-to-price-list (empty-price-list) [:onion 1] [:bacon 2])."
  [price-list & names-and-prices]
  (merge price-list (apply hash-map (flatten names-and-prices))))

(defn price [price-list item]
  "Gets the price for an item from the list."
  (get price-list item 0))

(defn scan
  "Scans a series of items for their price and adds them to the cart, e.g.
  (scan (empty-cart) price-list :onion :bacon)"
  [cart price-list & items]
  (concat cart (map (partial price price-list) items)))

(defn checkout [cart]
  "Checks out."
  (apply + cart))
