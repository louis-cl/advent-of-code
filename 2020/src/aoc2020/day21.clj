(ns aoc2020.day21
  (:require [clojure.string :as str]
            [clojure.test :refer [is]]
            [aoc2020.utils :refer [read-file]]
            [clojure.math.combinatorics :as combo]))

(def sample "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
")

(def input (read-file "input-21.txt"))

(defn parse [input]
    (for [line (str/split-lines input)]
      (let [words (re-seq #"\w+" line)
            [ingredients allergens] (split-with (complement #{"contains"}) words)]
        [ingredients (rest allergens)])))


(defn ingr-by-allergen [parsed-input]
  (let [possible-match
        (->> (for [[ingrs allers] parsed-input
                   aller allers]
               [aller ingrs])
             (reduce (fn [m [ingr allers]]
                       (update-in m [ingr] #(conj % allers)))
                     {})
             (map (fn [[k v]] [k (apply clojure.set/intersection (map set v))])))]
     (loop [current-match possible-match]
       (let [matched (filter (comp #{1} count second) current-match)]
         (if (= (count matched) (count current-match))
           matched
           (let [matched-ingr (->> matched (map second) (apply clojure.set/union))]
             (recur (for [[allergen ingrs :as all] current-match]
                      (if (= 1 (count ingrs))
                        all
                        [allergen (clojure.set/difference ingrs matched-ingr)])))))))))

(defn part-1 [input]
  (let [input (parse input)
        ingr-by-aller (ingr-by-allergen input)
        all-allergens (apply clojure.set/union (map second ingr-by-aller))]
    (->> input
         (map first)
         (apply concat)
         (remove all-allergens)
         count)))

(comment
  (part-1 sample)
  ;; => 5
  (part-1 input)
  ;; => 2389
)

(defn part-2 [input]
  (let [input (parse input)
        ingr-by-aller (ingr-by-allergen input)]
    (->> ingr-by-aller
         (sort-by first)
         (map second)
         (map first)
         (str/join ","))))

(comment
  (part-2 sample)
  ;; => "mxmxvkd,sqjhc,fvjkl"
  (part-2 input)
  ;; => "fsr,skrxt,lqbcg,mgbv,dvjrrkv,ndnlm,xcljh,zbhp"
)

