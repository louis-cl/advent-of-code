(ns aoc2020.day17
  (:require [clojure.string :as str]
            [clojure.test :refer [is]]
            [clojure.math.combinatorics :as combo]))

(def sample ".#.
..#
###
")

(def input "######.#
##.###.#
#.###.##
..#..###
##.#.#.#
##...##.
#.#.##.#
.###.###
")

(defn parse-map
  ([input] (parse-map input (fn [[i j] c] (if (= c \#) [0 i j]))))
  ([input f] 
   (->> input
        str/split-lines
        (map-indexed (fn [i line]
                       (keep-indexed (fn [j c]
                                       (f [i j] c))
                                     line)))
        (apply concat)
        set)))

(defn adjacents
  ([pos] (adjacents 3 pos))
  ([n pos]
   (->> (apply combo/cartesian-product (repeat n (range -1 2)))
        (map #(map + pos %))
        (remove #{pos}))))

(defn neighbors
  ([cubes] (neighbors 3 cubes))
  ([n cubes]
   (->> cubes
        (map (partial adjacents n))
        (apply concat)
        (frequencies))))

(defn step
  ([active-cubes] (step 3 active-cubes))
  ([n active-cubes]
   (let [neighs (neighbors n active-cubes)
         new-active (->> neighs
                         (filter (comp #{3} second))
                         (map first)
                         (remove active-cubes)
                         set)]
     (->> active-cubes
          (clojure.set/select #(<= 2 (get neighs % 0) 3)) ; remove inactive
          (clojure.set/union new-active)))))

(defn min-max-range [seq]
  (range (reduce min seq) (inc (reduce max seq))))

;; this is ugly....
(defn draw [cubes]
  (let [dims (apply (partial map vector) cubes)
        [zs xs ys] (map min-max-range dims)]
    (str/join "\n\n"
              (for [z zs]
                (let [lines (for [x xs]
                              (->>  ys
                                    (map #(if (cubes [z x %]) \# \.))
                                    (str/join)))]
                  (str/join "\n"
                            (conj lines (str "z = " z))))))))

(defn part-1 [input]
  (->> input
       parse-map
       (iterate step)
       (#(nth % 6))
       count))

(comment
  (part-1 sample)
  ;; => 112
  (part-1 input)
  ;; => 348
)

(defn part-2 [input]
  (->> (parse-map input (fn [[i j] c] (if (= c \#) [0 0 i j])))
       (iterate (partial step 4))
       (#(nth % 6))
       count))

(comment
  (part-2 sample)
  ;; => 848
  (part-2 input)
  ;; => 2236
)