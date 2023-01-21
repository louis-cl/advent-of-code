(ns aoc2020.day10
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))

(def sample-1 [16
               10
               15
               5
               1
               11
               7
               19
               6
               12
               4])

(defn jumps [input]
   (->> (conj input 0 (+ 3 (apply max input)))
       sort
       (partition 2 1)
       (map reverse)
       (map #(apply - %))))

(defn part1 [input]
  (->> (jumps input)
       frequencies
       vals
       (apply *)))

(part1 sample-1)
;; => 35

(def input (->> (read-file "input-10.txt")
                str/split-lines
                (map read-string)))

(part1 input)
;; => 2310

(defn part2 [input]
  (->> input
       jumps
       (partition-by #{3})
       (filter #(= (first %) 1))
       (map count)
       (map {1 1, 2 2, 3 4, 4 7})
       (apply *)))

(part2 input)
;; => 64793042714624

;; Solution above is sad, only works for my input
;; So no jumps of 2, no sequence of jumps of 1 longer than 4 elements...
;; Can we do better and enjoy the recursive nature of the problem ?

;; Idea is that we only care about the previous/next 3 numbers
(defn part2-v2 [input]
  (let [input (sort input)]
    (loop [now-3 {:val 0 :count 0}
           now-2 {:val 0 :count 0}
           now-1 {:val 0 :count 1}
           [x & xs] input]
      (if-not x 
        (:count now-1)
        (let [now-count (->> [now-3 now-2 now-1]
                             (filter #(<= (- x 3) (:val %)))
                             (map :count)
                             (apply +))
              now {:val x :count now-count}]
          (recur now-2 now-1 now xs))))))

(part2-v2 input)
;; => 64793042714624

;; Maybe we can avoid hardcoding the count of 3 previous memory values
;; and just leverage the diff of value being <= 3 and store whatever is needed