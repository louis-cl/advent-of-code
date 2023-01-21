(ns aoc2020.day23
  (:require [clojure.string :as str]))

(def sample "389125467")

(defn parse [s]
  (mapv read-string (str/split s #"")))

(defn cut-at [coll val]
  (let [[left right] (split-with (complement #{val}) coll)]
    [left (rest right)]))

(defn destination [cups current]
  (let [lowers (filter #(< % current) cups)]
    (if (seq lowers) (reduce max lowers) (reduce max cups))))

(defn step [[current & cups]]
  (let [pick (take 3 cups)
        rem-cups (drop 3 cups)
        dest (destination rem-cups current)
        [before-dest after-dest] (cut-at rem-cups dest)]
    (concat before-dest [dest] pick after-dest [current])))

(defn part-1 [input moves]
  (let [cups (parse input)
        res (nth (iterate step cups) moves)
        [bef aft] (cut-at res 1)]
    (str/join (concat aft bef))))

(def input "712643589")

(let [cups (parse input)]
  (time (step cups)))

(comment
  (part-1 sample 10)
  ;; => "92658374"
  (part-1 sample 100)
  ;; => "67384529"
  (part-1 input 100)
  ;; => "29385746"
)

;; OK part2, a step needs to be constant like micro second constant
;; re writing with a "linked list" map

;; we only take 3, so in case of wrapping around, we pick the first here
(def max-options (take 4 (iterate dec 1000000)))

(defn destination-2 [current blocked]
  (let [dec-options (range (dec current) 0 -1)
        options (concat dec-options max-options)]
    (first (remove (set blocked) options))))

(defn step-2 [cups current]
  (let [[c1 c2 c3 c4 & _] (drop 1 (iterate cups current))
        dest (destination-2 current [c1 c2 c3])
        new-cups (assoc cups
                        current c4
                        dest c1
                        c3 (cups dest))]
    [new-cups c4]))

(defn pprint [s m]
  (take (count m) (iterate m s)))

(defn part-2 [input n]
  (let [in (parse input)
        nums (concat in (range 10 1000001) [(first in)])
        cups (into {} (map vec (partition 2 1 nums)))]
    (as-> [cups (first in)] $
      (iterate (partial apply step-2) $)
      (nth $ n))))

(comment 
  (def res-2-sample (part-2 sample 10000000))
  (let [m (first res-2-sample)]
    (->> (iterate m 1)
         (drop 1)
         (take 2)))
  ;; => (934001 159792)
  (def res-2 (part-2 input 10000000))
  (let [m (first res-2)]
    (->> (iterate m 1)
         (drop 1)
         (take 2)
         (reduce *)))
)