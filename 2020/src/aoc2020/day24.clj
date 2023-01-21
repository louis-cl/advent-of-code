(ns aoc2020.day24
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))


(def sample "sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew")

(defn parse [input]
  (->> input
       (str/split-lines)
       (map #(re-seq #"se|sw|ne|nw|e|w" %))
       (map #(map keyword %))))

(def basis
  {:e [1 0]
   :w [-1 0]
   :nw [0 1]
   :se [0 -1]
   :ne [1 1]
   :sw [-1 -1]})

(defn dir->coord [dirs]
  (apply (partial map +) (map basis dirs)))

(defn part-1 [input]
  (->> (parse input)
       (map dir->coord)
       frequencies
       (filter (comp odd? second))
       count))

(def input (read-file "input-24.txt"))

(map + [0 1] [2 3])

(comment
  (part-1 sample)
  ;; => 10
  (part-1 input)
  ;; => 521
)

(defn adjacents [coord]
  (->> (vals basis)
       (map (partial map + coord))))

(defn tick [black-tiles]
  (let [black-adj-count (->> black-tiles
                             (map adjacents)
                             (apply concat)
                             frequencies)
        new-whites (for [tile black-tiles
                         :let [adj (get black-adj-count tile 0)]
                         :when (or (= 0 adj) (< 2 adj))]
                     tile)
        new-blacks (->> black-adj-count
                        (filter (comp #{2} second))
                        (map first)
                        (remove black-tiles))]
    (clojure.set/union
     (clojure.set/difference black-tiles (set new-whites))
     (set new-blacks))))

(defn part-2 [input]
  (->> (parse input)
       (map dir->coord)
       (frequencies)
       (filter (comp odd? second))
       (map first)
       set
       (iterate tick)
       (#(nth % 100))
       count))

(comment
  (part-2 sample)
  ;; => 2208
  (part-2 input)
  ;; => 4242
)


(nth (iterate inc 0) 4)
