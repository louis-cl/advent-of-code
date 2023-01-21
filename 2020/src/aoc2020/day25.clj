(ns aoc2020.day25
  (:require [clojure.string :as str]))

(def sample
  {:card 5764801
   :door 17807724})

(def input
  {:card 1614360
   :door 7734663})

(def M 20201227)

(defn discrete-exp [k]
  (iterate #(mod (* % k) M) 1))

(defn discrete-log [x k]
  (let [powers (discrete-exp k)]
    (first (keep-indexed (fn [idx it] (when (= it x) idx)) powers))))

(defn part-1 [input]
  (let [{:keys [card door]} input
        n-card (discrete-log card 7)]
    (nth (discrete-exp door) n-card)))

(comment
  (part-1 sample)
  ;; => 14897079
  (part-1 input)
  ;; => 5414549
)