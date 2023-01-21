(ns aoc2020.day6
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def input (->> (io/resource "input-06.txt")
                (io/reader)
                (slurp)))

(defn group-count [group]
  (count (set (str/replace group #"\R" ""))))

(->> (str/split input #"\R\R")
     (map group-count)
     (reduce +))
;; => 6782


(defn group-count2 [group]
  (let [groups (str/split group #"\n")]
    (->> groups
         (map set)
         (reduce clojure.set/intersection)
         (count))))

(->> (str/split input #"\R\R")
     (map group-count2)
     (reduce +))
;; => 3596
