(ns aoc2020.day7
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def input (->> (io/resource "input-07.txt")
                (io/reader)
                (line-seq)))

(defn parse-content [content]
  (let [[_ n color] (re-matches #"(\d+)\s(.*)\sbags?" content)]
    (if n 
      [(Long/parseLong n) color]
      [0 nil])))

(defn parse-sentence [sentence]
  (let [[bag & content] (str/split sentence #"( bags contain |, |\.)")]
    [bag (map parse-content content)]))

(parse-sentence "wavy turquoise bags contain no other bags.")
(parse-sentence "vibrant beige bags contain 4 drab lime bags, 1 muted violet bag, 5 drab plum bags, 5 shiny silver bags.")

(defn reverse-rule [[bag & content]]
  (for [[n color] (first content)
        :when (pos? n)]
    [color bag]))

(defn reverse-map [rules]
  (->> rules
       (map reverse-rule)
       (apply concat)
       (group-by first)
       (reduce-kv #(assoc %1 %2 (map second %3)) {})))

(def rules (map parse-sentence input))
(def rev-map (reverse-map rules))

(defn part-1 [m [start & rest] seen]
  (if-not start seen
          (if (contains? seen start) (part-1 m rest seen)
              (if-let [to-explore (m start)]
                (part-1 m (concat rest to-explore) (conj seen start))
                (part-1 m rest (conj seen start))))))

(def input-sample
  (->> (io/resource "input-07-sample.txt")
       (io/reader)
       (line-seq)))

(part-1
 (->> input-sample
      (map parse-sentence)
      (reverse-map))
 ["shiny gold"]
 #{})

(->> (part-1 rev-map ["shiny gold"] #{})
     count
     dec)
;; => 222

(defn part-2 [m start]
  (if-let [content (m start)]
    (reduce + (for [[n color] content]
                (* n (inc (part-2 m color)))))
    0))

(def rules-sample2 (->> (io/resource "input-07-sample2.txt")
      (io/reader)
      (line-seq)
      (map parse-sentence)))

(part-2 (into {} rules-sample2) "shiny gold")

(part-2 (into {} rules) "shiny gold")
;; => 13264

;; Part 1 with loop
(let [r-map (->> input (map parse-sentence) reverse-map)]
     (loop [visited #{}
            [color & to-visit] ["shiny gold"]]
       (if-not color
         (dec (count visited))
         (recur (conj visited color)
                (into to-visit (remove visited) (r-map color))))))
;; Part 2 smaller
(let [rules (into {} (map parse-sentence input))]
  ((fn size [color]
     (reduce + 
             (for [[n color2] (rules color)]
               (* n (inc (size color2)))))) "shiny gold"))