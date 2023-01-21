(ns aoc2020.day4
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def demo-input (->> (io/resource "input-04-sample.txt")
                (io/reader)
                (slurp)))

(defn present-fields [pairs]
  (set (for [p pairs]
         (let [[left right] (str/split p #":")]
           left))))

(defn valid? [fields]
  (clojure.set/subset? #{"hgt" "pid" "byr" "eyr" "iyr" "ecl" "hcl"} fields))

(defn part-1 [input]
  (let [blocks (filter (complement str/blank?) (str/split input #"\n\n"))]
    (->> blocks
         (map #(str/split % #"\s+"))
         (map present-fields)
         (filter valid?)
         (count))))

(part-1 demo-input)
;; => 2

(def input (->> (io/resource "input-04.txt")
                     (io/reader)
                     (slurp)))
(part-1 input)
;; => 260


(defn fields [pairs]
  (for [p pairs]
    (let [[left right] (str/split p #":")]
      {:key left :value right})))

(defn valid-field [{:keys [key value]}]
  (case key
    "byr" (if-let [digits (re-matches #"\d{4}" value)]
            (<= 1920 (Long/parseLong digits) 2002))
    "iyr" (if-let [digits (re-matches #"\d{4}" value)]
            (<= 2010 (Long/parseLong digits) 2020))
    "eyr" (if-let [digits (re-matches #"\d{4}" value)]
            (<= 2020 (Long/parseLong digits) 2030))
    "hgt" (if-let [[_ n unit] (re-matches #"(\d+)(cm|in)" value)]
            (case unit
              "in" (<= 59 (Long/parseLong n) 76)
              "cm" (<= 150 (Long/parseLong n) 193)))
    "hcl" (some? (re-matches #"#[0-9a-f]{6}" value))
    "ecl" (contains? #{"amb" "blu" "brn" "gry" "grn" "hzl" "oth"} value)
    "pid" (some? (re-matches #"\d{9}" value))
    "cid" true
     false))

(valid-field {:key "hgt" :value "120in"})
(valid-field {:key "hcl" :value "#abcdzs"})
(valid-field {:key "ecl" :value "blu"})
(valid-field {:key "pid" :value "000000123"})

(defn check-fields [passport]
  (for [field passport]
    {:field field :valid? (valid-field field)}))

(defn part-2 [input]
  (let [blocks (filter (complement str/blank?) (str/split input #"\n\n"))]
    (->> blocks
         (map #(str/split % #"\s+"))
         (map fields)
         (filter #(valid? (set (map :key %))))
         (map check-fields)
         (map (partial map :valid?))
         (filter (partial every? true?))
         (count))))

(part-2 input)


(->> (io/resource "input-04-valid.txt")
     (io/reader)
     (slurp))