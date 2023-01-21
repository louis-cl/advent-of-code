(ns aoc2020.day2
  (:require [clojure.java.io :as io]))


(def demo-input [
                 "1-3 a: abcde"
                 "1-3 b: cdefg"
                 "2-9 c: ccccccccc"])

(defn parse-line [line]
  (let [[_ mini maxi digit password] (re-matches #"(\d+)-(\d+)\s([a-z]):\s(\w+)" line)]
    (if mini
      {:mini (Long/parseLong mini)
       :maxi (Long/parseLong maxi)
       :digit digit
       :password password}
      nil)))

(defn is-valid [{:keys [mini maxi digit password]}]
  (let [amount-of-d (count (re-seq (re-pattern digit) password))]
    (<= mini amount-of-d maxi)))

(def input (->> (io/resource "input-02.txt")
                (io/reader)
                (line-seq)))

(count (filter is-valid (map parse-line input)))

(defn get-char [word pos]
  (subs word (dec pos) pos))

(defn is-valid2 [{:keys [mini maxi digit password]}]
  (->> [(get-char password mini) (get-char password maxi)]
       (filter #(= digit %))
       (count)
       (= 1)))

(->> input
     (map parse-line)
     (filter is-valid2)
     (count))