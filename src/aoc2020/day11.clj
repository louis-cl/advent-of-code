(ns aoc2020.day11
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))


(def sample "L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
")

(defn parse-map [input]
  (->> input
       str/split-lines
       (mapv (fn [row]
               (mapv {\L :empty \. :floor \# :occupied} row)))))

(defn adjacents [grid i j]
  (for [di [-1 0 1]
        dj [-1 0 1]
        :when (not (and (= di 0) (= dj 0)))]
    (get-in grid [(+ i di) (+ j dj)])))

(defn occupied-around [grid i j]
  (->> (adjacents grid i j)
       (filter #{:occupied})
       (count)))

(defn step [grid]
  (let [changes 
        (for [i (range (count grid))
              j (range (count (grid i)))]
          (let [seat (get-in grid [i j])
                occ (occupied-around grid i j)]
            (cond
              (and (= seat :empty) (zero? occ))
              [i j :occupied]
              (and (= seat :occupied) (<= 4 occ))
              [i j :empty])))]
    (->> changes
         (remove nil?)
         (reduce (fn [grid [i j state]]
                   (update-in grid [i j] (constantly state)))
                 grid))))

(->> (parse-map sample)
     step
     step
     step
     step
     step
     flatten
     (filter #{:occupied})
     count)
;; => 37

(defn part-1 [input]
  (loop [grid (parse-map input)]
    (let [next-grid (step grid)]
      (if (= next-grid grid)
        (count (filter #{:occupied} (flatten grid)))
        (recur next-grid)))))

(part-1 sample)
;; => 37
 
(def input (->> (read-file "input-11.txt")))

(part-1 input)
;; => 2483


(def sample2 ".......#.
...#.....
.#.......
.........
..#L....#
....#....
.........
#........
...#.....
")

(defn occupied-around-2 [grid [i j]]
  (->> (for [di [-1 0 1]
             dj [-1 0 1]
             :when (not (and (= di 0) (= dj 0)))]
         (let [pos-in-dir (rest (iterate (fn [[i j]] [(+ i di) (+ j dj)]) [i j]))
               seats-in-dir (map #(get-in grid %) pos-in-dir)]
           (first (drop-while #{:floor} seats-in-dir))))
       (filter #{:occupied})
       count))

(occupied-around-2 (parse-map sample2) [4 3])
;; => 8

(defn step-2 [grid]
  (let [changes
        (for [i (range (count grid))
              j (range (count (grid i)))]
          (let [seat (get-in grid [i j])
                occ (occupied-around-2 grid [i j])]
            (cond
              (and (= seat :empty) (zero? occ))
              [i j :occupied]
              (and (= seat :occupied) (<= 5 occ))
              [i j :empty])))]
    (->> changes
         (remove nil?)
         (reduce (fn [grid [i j state]]
                   (update-in grid [i j] (constantly state)))
                 grid))))

(->> (parse-map sample)
     step-2
     step-2
     step-2
     step-2
     step-2
     step-2
     flatten
     (filter #{:occupied})
     count)
;; => 26

(defn part-2 [input]
  (loop [grid (parse-map input)]
    (let [next-grid (step-2 grid)]
      (if (= next-grid grid)
        (count (filter #{:occupied} (flatten grid)))
        (recur next-grid)))))

(part-2 sample)
;; => 26
(part-2 input)
;; => 2285
