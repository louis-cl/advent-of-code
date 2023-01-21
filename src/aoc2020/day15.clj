(ns aoc2020.day15)

(def sample [0 3 6])
(def input [6,4,12,1,20,0,16])

(defn part-1 [input pos]
    (loop [turn (count input)
           to-speak 0
           last-turn (reduce-kv (fn [m i v] (assoc m v i)) {} input)]
      (if (= turn pos) to-speak
            (recur (inc turn)
                   (- turn (get last-turn to-speak turn))
                   (assoc last-turn to-speak turn)))))

(comment
  (part-1 sample (dec 2020))
  ;; => 436
  (part-1 input (dec 2020))
  ;; => 475
  (part-1 input (dec 30000000))
  ;; => 11261
)