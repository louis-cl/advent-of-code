(ns aoc2020.utils
  (:require [clojure.java.io :as io]))

(defn read-file [filename]
  (->> filename
       io/resource
       slurp))