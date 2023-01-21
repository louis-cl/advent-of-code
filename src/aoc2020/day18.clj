(ns aoc2020.day17
  (:require [clojure.string :as str]
            [clojure.test :refer [is]]
            [aoc2020.utils :refer [read-file]]))

(defn tokenize [s]
  (as-> s e 
    (str/escape e {\* :mul \+ :plus \( \[  \) \]})
    (str "[" e "]")
    (read-string e)))

(defn eval [tokens]
  (loop [[token & ts] tokens
         val 0
         op +]
    (cond
      (nil? token) val
      (number? token) (recur ts (op val token) nil)
      (= :plus token) (recur ts val +)
      (= :mul token) (recur ts val *)
      (vector? token) (recur ts (op val (eval token)) nil))))

(is (= 71 (eval (tokenize "1 + 2 * 3 + 4 * 5 + 6"))))
(is (= 51 (eval (tokenize "1 + (2 * 3) + (4 * (5 + 6))"))))
(is (= 13632 (eval (tokenize "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))))

(def input (->> (read-file "input-18.txt")))

(comment
  (->> input
       (str/split-lines)
       (map tokenize)
       (map eval)
       (reduce +))
  ;; => 9535936849815
)

(defn split-by [sym ls]
  (->> ls
       (partition-by #{sym})
       (remove #{(list sym)})))


(defn eval-2-token [token]
  (cond
    (vector? token) (eval-2 token)
    (number? token) token
    :else (recur (first token))))

(defn eval-2-plus [tokens]
  (->> tokens
       (split-by :plus)
       (map eval-2-token)
       (reduce +)))

(defn eval-2 [tokens]
  (->> tokens
       (split-by :mul)
       (map eval-2-plus)
       (reduce *)))


(is (= 51 (eval-2 (tokenize "1 + (2 * 3) + (4 * (5 + 6))"))))
(is (= 46 (eval-2 (tokenize "2 * 3 + (4 * 5)"))))
(is (= 23340 (eval-2 (tokenize "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))))

(comment
  (->> input
       (str/split-lines)
       (map tokenize)
       (map eval-2)
       (reduce +))
  ;; => 472171581333710
  )