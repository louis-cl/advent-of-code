(ns aoc2020.day9
  (:require [clojure.string :as str]
            [clojure.math.combinatorics :as comb]
            [aoc2020.utils :refer [read-file]]))

(def sample-input [35 20 15 25 47 40 62 55 65 95 102 117 150 182 127 219 299 277 309 576])

(defn sum-of-2 [coll x]
  (->> (comb/combinations coll 2)
       (map (partial apply +))
       (filter #{x})
       not-empty))

(defn part-1 [input block-size]
  (loop [[window & rest] (partition (inc block-size) 1 input)]
    (let [x (last window)
          not-x (remove #{x} window)]
      (if (sum-of-2 not-x x)
        (when rest (recur rest))
        x))))
;; => #'aoc2020.day9.main/part-1

(part-1 sample-input 5)
;; => 127

(def input (->> (read-file "input-09.txt")
                str/split-lines
                (map read-string)))

(part-1 input 25)
;; => 15690279

(defn part-2 [input]
  (let [input (vec input)
        target (part-1 input 25)]
    (loop [i 0 ;; included
           j 1 ;; excluded
           current-sum (first input)]
      (let [new-sum (+ current-sum (nth input j))]
        (condp apply [new-sum target]
          = (let [sum-set (subvec input i (inc j))]
              (+ (apply max sum-set) (apply min sum-set)))
          < (recur i (inc j) new-sum)
          > (recur (inc i) (+ i 2) (nth input (inc i))))))))

(part-2 input)
;; => 2174232

;; (cond
;;   (= a b) "eq"
;;   (< a b) "lt"
;;   (> a b) "gt")
;; 
;; is the same as
;; 
;; (condp apply [a b]
;;   = "eq"
;;   < "lt"
;;   > "gt")


;; do not
;; (reduce max seq)
;; but instead
;; (apply max seq)
;; you save the full recursion stack of reducing if the op (max) accepts seqs