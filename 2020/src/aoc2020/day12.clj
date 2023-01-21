(ns aoc2020.day12
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))

(def sample "F10
N3
F7
R90
F11")

(defn parse [input]
  (->> input
       str/split-lines
       (map (fn [line]
              (let [[_ op arg] (re-matches #"(.)(\d+)" line)]
                [(keyword op) (read-string arg)])))))
(parse sample)

(def rot-order (cycle [:N :W :S :E]))
(defn rotate [current-dir angle]
  (let [steps (mod (/ angle 90) 4)]
    (nth
     (drop-while (complement #{current-dir}) rot-order)
     steps)))

(defn move [{:keys [x y dir] :as state} [op arg]]
  (case op
    :N (update state :y #(+ % arg))
    :S (move state [:N (- arg)])
    :E (update state :x #(+ % arg))
    :W (move state [:E (- arg)])
    :F (move state [dir arg])
    :L (update state :dir #(rotate % arg))
    :R (move state [:L (- arg)])))

;; part 1
(defn part1 [input]
  (let [moves (parse input)
        final-state (reduce move {:x 0 :y 0 :dir :E} moves)]
    (+ (Math/abs (:x final-state))
       (Math/abs (:y final-state)))))

(part1 sample)

(def input (->> (read-file "input-12.txt")))

(part1 input)
;; => 759

(defn rotate-90 [[x y]] [(- y) x])
(defn rotate-2 [[x y] angle]
  (let [steps (mod (/ angle 90) 4)]
        (nth (iterate rotate-90 [x y]) steps)))

(defn move-2 [{:keys [x y wx wy] :as state} [op arg]]
  (case op
    :N (update state :wy #(+ % arg))
    :S (move-2 state [:N (- arg)])
    :E (update state :wx #(+ % arg))
    :W (move-2 state [:E (- arg)])
    :F (-> state
           (update :x #(+ % (* arg wx)))
           (update :y #(+ % (* arg wy))))
    :L (let [[wx2 wy2] (rotate-2 [wx wy] arg)]
         {:x x :y y :wx wx2 :wy wy2})
    :R (move-2 state [:L (- arg)])))

(defn part2 [input]
  (let [moves (parse input)
        final-state (reduce move-2 {:x 0 :y 0 :wx 10 :wy 1} moves)]
    (+ (Math/abs (:x final-state))
       (Math/abs (:y final-state)))))

(part2 input)
;; => 45763
