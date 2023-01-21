(ns aoc2020.day16
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]
            [clojure.test :refer [is]]))


(def sample "class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
")

(defn parse-csv [s]
  (map read-string (str/split s #",")))

(defn parse-rule [s]
  (let [[name ranges] (str/split s #":")]
    {:field name
     :ranges (for [[_ & bounds] (re-seq #"(\d+)-(\d+)" ranges)]
       (map read-string bounds))}))

(defn parse [input]
  (let [[rules
         [_ ticket]
         [_ & tickets]]
        (as-> input $
          (str/split $ #"\R\R")
          (map str/split-lines $))]
    {:ticket (parse-csv ticket)
     :rules (map parse-rule rules)
     :tickets (map parse-csv tickets)}))

(comment
  (parse-rule "class: 1-3 or 5-7")
  (parse sample)
  )

(defn valid? [rules field]
  (some true? (for [[lower upper] rules]
         (<= lower field upper))))

(comment
  (is (valid? ['(1 3) '(5 7)] 3))
  (is (not (valid? ['(1 3) '(5 7)] 4)))
  )

(defn part-1 [input]
  (let [input (parse input)
        all-rules (apply concat (map :ranges (input :rules)))
        all-fields (flatten (input :tickets))]
    (->> all-fields
         (remove (partial valid? all-rules))
         (reduce +))))

(def input (read-file "input-16.txt"))

(comment
  (part-1 sample)
  ;; => 71
  (part-1 input)
  ;; => 26980
)

(defn matching-fields [rules ticket]
  (for [field ticket]
    (set (for [rule rules
               :when (valid? (:ranges rule) field)]
           (:field rule)))))

(defn part-2 [input]
  (let [{:keys [ticket rules tickets]} (parse input)
        all-fields (map (partial matching-fields rules) (conj tickets ticket))
        not-invalid-fields (remove (partial some empty?) all-fields)
        agg-possible-fields (->> not-invalid-fields
                                 (apply map vector)
                                 (map (partial apply clojure.set/intersection)))]
    (loop [options agg-possible-fields]
      (let [known-fields (transduce (filter #(= 1 (count %))) clojure.set/union options)]
        (if (= (count known-fields) (count options))
          (let [field-names (map first options)]
            (->> (map vector field-names ticket)
                 (filter (comp #(str/starts-with? % "departure") first))
                 (map second)
                 (reduce *)))
          (recur (map
                  (fn [fields] (if (= 1 (count fields))
                                 fields
                                 (clojure.set/difference fields known-fields)))
                  options)))))))

(comment
  (part-2 input)
  ;; => 3021381607403
)