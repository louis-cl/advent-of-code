(ns aoc2020.day19
  (:require [clojure.string :as str]
            [clojure.test :refer [is]]
            [aoc2020.utils :refer [read-file]]
            [clojure.math.combinatorics :as combo]))



(def sample (read-file "input-20-sample.txt"))
(def input (read-file "input-20.txt"))


(defn parse-tile [[head & body]]
  (let [[_ n] (re-matches #"Tile (\d+):" head)
        top (first body)
        bottom (last body)
        left (apply str (map first body))
        right (apply str (map last body))]
    {:n (read-string n)
     :top top
     :bottom (str/reverse bottom)
     :left (str/reverse left)
     :right right
     :body body}))

(def orients [:top :bottom :left :right])

(defn matches? [t1 t2]
  (->> (combo/cartesian-product orients orients)
       (filter (fn [[o1 o2]] (or (= (t1 o1) (t2 o2))
                                 (= (str/reverse (t1 o1)) (t2 o2)))))))

;; could refactor to support multiple matches per side, but that doesn't seem to be the case
;; so corners are tiles with 2 sides not matching anything, and not "tiles that match 2 other tiles somehow"
(defn part-1 [tiles]
  (->> (combo/combinations tiles 2)
       (map (fn [[t1 t2]] {:tiles [t1 t2] :match (matches? t1 t2)}))
       (remove (comp empty? :match))
       (map :tiles)
       flatten
       (map :n)
       frequencies
       (filter (fn [[_ v]] (= v 2)))
       (map first)
       (reduce *)))

(defn parse [input]
  (as-> input $
    (str/split $ #"\R\R")
    (map #(str/split-lines %) $)
    (map parse-tile $)))

(comment
  (part-1 (parse sample))
  ;; => 20899048083289
  (part-1 (parse input))
  ;; => 5775714912743
)

(comment
  (let [tiles (parse input)]
    (->> (combo/combinations tiles 2)
         (map (fn [[t1 t2]] {:tiles [t1 t2] :match (matches? t1 t2)}))
         (remove (comp empty? :match))
         (map :tiles)
         flatten
         (map :n)
         frequencies
         (vals)
         frequencies))
  ;; => {4 100, 3 40, 2 4}
  ;; so there is only one way to match them (YES!) 4 corners, 40 sides, 100 inside
)

(defn flip [tile]
  (map #(str/reverse %) tile))

(defn rotate [tile]
  (map #(apply str %) (apply (partial map vector) (reverse tile))))


(def ex [".##"
         "#.#"
         "..#"])

(comment 
  (is (= (flip ex) ["##."
                    "#.#"
                    "#.."]))
  (is (= (rotate ex) [".#."
                      "..#"
                      "###"]))
  (is (= ((comp rotate rotate) ex) ["#.."
                                    "#.#"
                                    "##."]))
)

(def transforms
  (for [flip-choice [identity flip]
        rotate-choice (reductions comp identity (repeat 3 rotate))]
    (comp rotate-choice flip-choice)))

(comment
  (map #(% ex) transforms))

(defn move [[x y] dir]
  (case dir
    :top [x (dec y)]
    :bottom [x (inc y)]
    :right [(inc x) y]
    :left [(dec x) y]))

(def opposite {:top :bottom
               :bottom :top
               :left :right
               :right :left})

(defn get-side [side tile]
  (case side
    :top (first tile)
    :bottom (last tile)
    :left (apply str (map first tile))
    :right (apply str (map last tile))))

(defn fits? [solution pos tile]
  (every? true? (for [[my-side other-side] opposite
                      :let [other-tile (get solution (move pos my-side))]
                      :when other-tile]
                  (= (get-side my-side tile)
                     (get-side other-side other-tile)))))

(defn solve [rem-tiles [pos & positions] solution]
  (if (empty? rem-tiles) solution
      (first (for [[n tile] rem-tiles
                   t transforms
                   :let [tile-t (t tile)]
                   :when (fits? solution pos tile-t)
                   :let [sol (solve (dissoc rem-tiles n)
                                    positions
                                    (assoc solution pos tile-t))]
                   :when sol]
               sol))))

(defn print-sol [sol n]
  (doseq [i (range n)]
    (println)
    (println (as-> (range n) $
               (map #(get sol [% i]) $)
               (apply (partial map vector) $)
               (map #(str/join " " %) $)
               (str/join "\n" $)))))

(defn solve-map [input]
  (let [tiles (reduce (fn [m tile] (assoc m (:n tile) (:body tile))) {} (parse input))
        n (int (Math/sqrt (count tiles)))
        positions (combo/cartesian-product (range n) (range n))]
    (solve tiles positions {})))

(def input-solution (solve-map input))
(def sample-solution (solve-map sample))

(defn update-values [m f & args]
  (reduce (fn [r [k v]] (assoc r k (apply f v args))) {} m))

(defn remove-border [tile]
  (let [n (count tile)]
    (->> tile
         (drop 1)
         drop-last
         (map #(subs % 1 (dec n))))))

(defn merge-tiles [tiles]
  (let [size (->> (keys tiles) (map first) (apply max) inc)]
    (flatten (for [i (range size)]
              (->> (range size)
                   (map #(get tiles [% i]))
                   (apply (partial map vector))
                   (map #(str/join %)))))))

(comment
  (is (= ["a1b1" "2a2b" "c1d1" "2c2d"]
         (merge-tiles {[0 0] ["a1" "2a"]
                       [1 0] ["b1" "2b"]
                       [0 1] ["c1" "2c"]
                       [1 1] ["d1" "2d"]}))))

(def monster ["                  # "
              "#    ##    ##    ###"
              " #  #  #  #  #  #   "])

(def monster-pos
  (for [ii (range 3)
        jj (range 20)
        :let [monster-c (get-in monster [ii jj])]
        :when (= monster-c \#)]
    [ii jj]))

;; let's assume monsters don't overlap

(defn find-monsters [image]
  (let [n (count image)]
    (count (filter identity (for [p (combo/cartesian-product (range (- n 2)) (range (- n 19)))
                                  :let [check-pos (map #(map + % p) monster-pos)
                                        im-at-pos (map #(get-in image %) check-pos)]]
                              (every? #{\#} im-at-pos))))))
(defn part-2 [sol]
  (let [no-border (update-values sol remove-border)
        merged (vec (merge-tiles no-border))]
    (let [monsters (first (for [t transforms
                                :let [image (vec (t merged))
                                      monsters (find-monsters image)]
                                :when (pos? monsters)]
                            monsters))
          count-# (count (filter #{\#} (str/join merged)))]
      (- count-# (* monsters 15)))))

(comment
  (part-2 sample-solution)
  ;; => 273
  (part-2 input-solution)
  ;; => 1836
)