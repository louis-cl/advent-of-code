(ns aoc2020.day14
  (:require [clojure.string :as str]
            [aoc2020.utils :refer [read-file]]
            [clojure.test :refer [deftest is]]
            [clojure.math.combinatorics :as combo]))


(def sample "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0")

(defn str->bin [s]
  (read-string (str "2r" s)))

(defn read-mask [mask-line]
  (let [bits (re-find #"[X|1|0]{36}" mask-line)
        and-mask (str/replace bits "X" "1")
        or-mask (str/replace bits "X" "0")]
    {:and (str->bin and-mask)
     :or (str->bin or-mask)}))

(defn read-instr [line]
  (let [[_ address value] (re-matches #"mem\[(\d+)\]\s=\s(\d+)" line)]
    {:addr (read-string address)
     :value (read-string value)}))

(defn parse
  ([input] (parse input read-mask))
  ([input mask-reader]
   (let [lines (str/split-lines input)]
     (for [line lines]
       (cond
         (str/starts-with? line "mask") (mask-reader line)
         :else (read-instr line))))))

(comment
  (read-mask "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X")
  (read-instr "mem[8] = 11")
  (parse sample))

(defn execute [mask memory instr]
  (let [res (->> (:value instr)
                 (bit-and (:and mask))
                 (bit-or (:or mask)))]
    (assoc memory (:addr instr) res)))

(comment
  (is (= (execute {:and 68719476733, :or 64} {} {:addr 8, :value 11})
                {8 73}))
  )

(defn part-1 [input]
  (let [input-instrs (parse input)]
    (loop [mask {:and 1 :or 0}
           memory {}
           [instr & instrs] input-instrs]
      (if-not instr
        (->> memory
             vals
             (apply +))
        (if (:addr instr)
          (recur mask (execute mask memory instr) instrs)
          (recur instr memory instrs))))))

(def input (->> (read-file "input-14.txt")))

(comment
  (part-1 sample)
  ;; => 165
  (part-1 input)
  ;; => 14862056079561
)

(def sample-2 "mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
")

(defn read-mask-2 [mask-line]
  (let [bits (re-find #"[X|1|0]{36}" mask-line)
        or-mask (str/replace bits "X" "0")
        x-pos (->> bits
                   (map-indexed vector)
                   (filter (comp #{\X} second))
                   (map first)
                   (map #(- 35 %))
                   (map #(bit-shift-left 1 %)))]
    {:or (str->bin or-mask)
     :xs x-pos
     :and (bit-not (apply + x-pos))}))

(comment 
  (read-mask-2 "mask = 000000000000000000000000000000X1001X")
  (read-mask-2 "mask = 00000000000000000000000000000000X0XX")
  (parse sample-2 read-mask-2))

(defn execute-2 [mask memory instr]
  (let [base-addr (->> (:addr instr)
                       (bit-and (:and mask)) ; remove floating bits
                       (bit-or (:or mask)))
        addrs (->> (combo/subsets (:xs mask))
                   (map (partial apply +)) ; OR all bits, + gives a nice 0 default
                   (map (partial + base-addr)))]
    (reduce (fn [mem addr] (assoc mem addr (:value instr)))
            memory 
            addrs)))

(comment 
  (is (= (execute-2 {:or 18, :and -34, :xs '(32 1)} {} {:addr 42, :value 100})
         {26 100, 27 100, 58 100, 59 100}))
  (execute-2 {:or 0, :xs '(8 2 1), :and -12} {} {:addr 26, :value 1})
)

(defn part-2 [input]
  (let [input-instrs (parse input read-mask-2)]
    (loop [mask nil
           memory {}
           [instr & instrs] input-instrs]
      (if-not instr
        (->> memory
             vals
             (apply +))
        (if (:addr instr)
          (recur mask (execute-2 mask memory instr) instrs)
          (recur instr memory instrs))))))

(comment
  (parse sample-2 read-mask-2)
  (part-2 sample-2)
  ;; => 208
  (part-2 input)
  ;; => 3296185383161
)
