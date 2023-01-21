(ns aoc2020.day13
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))

(def sample
  "939
7,13,x,x,59,x,31,19")

(defn parse [input]
  (let [[earliest buses] (str/split-lines input)]
    {:earliest (read-string earliest)
     :buses (->> (str/split buses #",")
                 (remove #{"x"})
                 (map read-string))}))

(defn part-1 [input]
  (let [{:keys [earliest buses]} (parse input)]
    (->> buses
         (map (fn [bus]
                (let [wait (- bus (mod earliest bus))]
                  {:wait wait :bus bus})))
         (apply min-key :wait)
         vals
         (apply *))))

(comment
  (part-1 sample)
  ;; => 295
)

(def input "1000001
29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,577,x,x,x,x,x,x,x,x,x,x,x,x,13,17,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,601,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37")

(part-1 input)
;; => 174

(defn parse-2 [input]
  (let [[_ buses] (str/split-lines input)]
     (->> (str/split buses #",")
          (map read-string)
          (map-indexed vector)
          (remove (comp #{'x} second)))))

(parse-2 input)
;; => ([0 29] [19 41] [29 577] [42 13] [43 17] [48 19] [52 23] [60 601] [97 37])

;; input it here https://www.dcode.fr/chinese-remainder
;; t = -offset (mod bus)

(parse-2 sample)
;; Is there a simpler way that doesn't involve writting the theorem code ?
;; We could iterate quickly enough

(defn part-2 [input]
  (loop [timestamp 0
         delta 1
         [[offset cadence] & rest :as all] (parse-2 input)]
    (if-not all
      timestamp
      (if (zero? (mod (+ timestamp offset) cadence))
        (recur timestamp (* delta cadence) rest)
        (recur (+ timestamp delta) delta all)))))

(comment
  (part-2 sample)
  ;; => 1068781
  (part-2 input)
  ;; => 780601154795940
)
