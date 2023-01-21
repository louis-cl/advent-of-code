(ns aoc2020.day1.main
  (:require [clojure.java.io :as io]))


(def demo-input [1721
            979
            366
            299
            675
            1456])

(defn part1 [input] 
  (first (for [x input
               y input
               :when (= 2020 (+ x y))]
           (* x y))))


(def input (->> (io/resource "input-01.txt")
                (io/reader)
                (line-seq)
                (map #(Long/parseLong %))))


(part1 input)