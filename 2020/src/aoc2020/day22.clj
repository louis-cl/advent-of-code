(ns aoc2020.day11
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))


(def sample "Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10")

(def input "Player 1:
31
24
5
33
7
12
30
22
48
14
16
26
18
45
4
42
25
20
46
21
40
38
34
17
50

Player 2:
1
3
41
8
37
35
28
39
43
29
10
27
11
36
49
32
2
23
19
9
13
15
47
6
44")

(defn queue
  ([] (clojure.lang.PersistentQueue/EMPTY))
  ([coll]
   (reduce conj clojure.lang.PersistentQueue/EMPTY coll)))

(defn parse-decks [input-s]
  (as-> input-s $
    (str/split $ #"\R\R")
    (map #(str/split-lines %) $)
    (map rest $)
    (map #(map read-string %) $)))

(defn play [d1 d2]
  (let [card-1 (peek d1)
        card-2 (peek d2)]
    (if (< card-1 card-2)
      [(pop d1) (conj (pop d2) card-2 card-1)]
      [(conj (pop d1) card-1 card-2) (pop d2)])))

(defn score [deck]
  (let [weight (range (count deck) 0 -1)]
    (reduce + (map * weight deck))))


(defn part-1 [input]
  (let [[p1 p2] (parse-decks input)
        deck-p1 (queue p1)
        deck-p2 (queue p2)]
    (loop [[d1 d2] [deck-p1 deck-p2]]
      (cond
        (empty? d1) {:win 2 :deck d2 :score (score d2)}
        (empty? d2) {:win 1 :deck d1 :score (score d1)}
        :else (recur (play d1 d2))))))

(comment
  (part-1 sample)
  ;; => {:win 2, :deck <-(3 2 10 6 8 5 9 4 7 1)-<, :score 306}
  (:score (part-1 input))
  ;; => 36257
  )

(defn play-2 [deck-1 deck-2]
  (loop [seen #{}
         d1 deck-1
         d2 deck-2]
    (cond
      (contains? seen [d1 d2]) {:win 1 :deck d1}
      (empty? d1) {:win 2 :deck d2}
      (empty? d2) {:win 1 :deck d1}
      :else (let [c1 (peek d1)
                  c2 (peek d2)
                  new-seen (conj seen [d1 d2])
                  new-d1 (pop d1)
                  new-d2 (pop d2)]
              (cond
                (and (<= c1 (count new-d1))
                     (<= c2 (count new-d2)))
                (let [rec-d1 (queue (take c1 new-d1))
                      rec-d2 (queue (take c2 new-d2))
                     {:keys [win deck]} (play-2 rec-d1 rec-d2)]
                  (case win
                    1 (recur new-seen (conj new-d1 c1 c2) new-d2)
                    2 (recur new-seen new-d1 (conj new-d2 c2 c1))))
                ;; recursive combat
                (< c1 c2)
                (recur new-seen new-d1 (conj new-d2 c2 c1))
                :else
                (recur new-seen (conj new-d1 c1 c2) new-d2))))))

(def inf-sample "Player 1:
43
19

Player 2:
2
29
14")

(defn part-2 [input]
  (let [[p1 p2] (parse-decks input)
        d1 (queue p1)
        d2 (queue p2)]
    (play-2 d1 d2)))

(comment
  (part-2 inf-sample)
  ;; => {:win 1, :deck <-(43 19)-<}
  (part-2 sample)
  ;; => {:win 2, :deck <-(7 5 6 2 4 1 10 8 9 3)-<}
  (->> (part-2 input)
       :deck
       score)
  ;; => 33304
)