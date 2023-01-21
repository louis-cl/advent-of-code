(ns aoc2020.day3
  (:require [clojure.java.io :as io]))

(def demo-input (->> (io/resource "input-03-sample.txt")
                     (io/reader)
                     (line-seq)))

(defn parse-map [lines]
  (let [positions (set (for [[i row]  (map-indexed list lines)
                             [j cell] (map-indexed list row)
                             :when (= cell \#)]
                         {:x     i
                          :y     j
                          :tree? (= cell \#)}))]
    {:cells positions
     :maxX (apply max (map :x positions))
     :maxY (apply max (map :y positions))}
    ))


(def demo-map (parse-map demo-input))

(defn tree? [{:keys [cells maxX maxY]} {:keys [x y]}]
  (->> {:x x :y (mod y (inc maxY)) :tree? true}
       (contains? cells)))

(tree? demo-map {:x 11 :y 14})

(defn move
  ([pos]
   (move pos {:dx 1 :dy 3}))
  ([{:keys [x y]} {:keys [dx dy]}]
   {:x (+ x dx) :y (+ y dy)}))

(->> (take-while #(<= (:x %) 10) (iterate move {:x 0 :y 0}))
     (filter #(tree? demo-map %))
     (count))

(def input (->> (io/resource "input-03.txt")
                (io/reader)
                (line-seq)))

(def input-map (parse-map input))

(defn count-slope [mapa slopeX slopeY]
  (->> (iterate #(move % {:dx slopeX :dy slopeY}) {:x 0 :y 0})
       (take-while #(<= (:x %) (:maxX mapa)))
       (filter #(tree? mapa %))
       (count)))

;; part 1
(count-slope input-map 1 3)
;; => 230

;; part 2
(->> [[1 1] [1 3] [1 5] [1 7] [2 1]]
     (map (partial apply count-slope input-map))
     (reduce *))
;; => 9533698720
