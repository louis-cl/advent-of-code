(ns aoc2020.day19
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]))


(def sample "0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: \"a\"
5: \"b\"

ababbb
bababa
abbbab
aaabbb
aaaabbb")

(defn parse-rule [s]
  (let [[_ left right] (re-matches #"(\d+): (.*)" s)
        options (map #(str/split % #" ") (str/split right #"\s*\|\s*"))]
    [(read-string left) (map #(map read-string %) options)]))

(comment 
  (parse-rule "0: 4 1 5")
  (parse-rule "4: \"a\"")
  (parse-rule "3: 4 5 | 5 4"))

(defn parse-input [input]
  (let [[rules messages] (map str/split-lines (str/split input #"\R\R"))
        rules (into {} (map parse-rule rules))]
    {:rules rules :messages messages}))

;; idea 1: create a single regex for rule 0 (doesn't work if cycle)
;; idea 2: parse it manually left to right (works if rules consume one symbol)

(defn regex [rules rule-n]
  (let [options (get rules rule-n)
        or-regexs (for [option options]
                    (str/join
                     (for [term option]
                       (cond
                         (string? term) term
                         (number? term) (regex rules term)))))]
    (if (= 1 (count or-regexs))
      (first or-regexs)
      (str "(?:" (str/join "|" or-regexs) ")"))))


(defn part-1 [input]
    (let [{:keys [rules messages]} (parse-input input)
          regex-0 (re-pattern (regex rules 0))]
      (count (filter #(re-matches regex-0 %) messages))))


(def input (read-file "input-19.txt"))

(comment
  (part-1 sample)
  ;; => 2
  (part-1 input)
  ;; => 200
)

;; Part 2 has recursive calls, so I either manually write the regexp
;; But a^n b^n is gonna be hard, or I can do option 2... (hard but fun)

;; rule 0 : 8 11
;; rule 8 : 42 | 42 8  -> 42+
;; rules 11 : 42 31 | 42 11 31  -> 42^n 31^n
;; so
;; rule 0 : 42+ 42^n 31^n -> 42^n 31^m  n > m > 0

(comment 
 (let [{:keys [rules messages]} (parse-input input)
       rule-42 (regex rules 42)
       rule-31 (regex rules 31)
       p-42 (re-pattern rule-42)
       p-31 (re-pattern rule-31)
       p-0 (re-pattern (format "(%s+)(%s+)" rule-42 rule-31))]
   (->> (for [message messages]
          (if-let [[_ m-42 m-31] (re-matches p-0 message)]
            (let [count-42 (count (re-seq p-42 m-42))
                  count-31 (count (re-seq p-31 m-31))] 
              (> count-42 count-31))))
        (filter identity)
        count))
 ;; => 407
)