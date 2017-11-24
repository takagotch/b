;---
; Excerpted from "The Cucumber for Java Book",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material, 
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose. 
; Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
;---
(defproject clojure-cucumber "0.1.0-SNAPSHOT"
  :description "A checkout example tested using Cucumber"

  :dependencies [[org.clojure/clojure "1.6.0"]]

  :plugins [[lein-cucumber "1.0.2"]]

  :cucumber-feature-paths ["test/features/"])
