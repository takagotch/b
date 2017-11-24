;---
; Excerpted from "The Cucumber for Java Book",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
;---
(ns checkout.checkout)

(defn empty-cart [] '())
(defn empty-price-list [] {})

(defn add-to-price-list
  "Adds an item-cost pair to the list of prices, e.g.
  (add-to-price-list (empty-price-list) :onion 1)"
  [price-list name cost]
  (assoc price-list name cost))

(defn price [price-list item]
  "Gets the price for an item from the list."
  (get price-list item 0))

(defn scan
  "Scans an item for their price and adds it to the cart, e.g.
  (scan (empty-cart) price-list :onion)"
  [cart price-list item]
  (conj cart (price price-list item)))

(defn checkout [cart]
  "Checks out."
  (apply + cart))
