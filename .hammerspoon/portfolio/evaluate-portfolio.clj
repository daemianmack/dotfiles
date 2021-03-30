#!/usr/local/bin/bb

(require '[cheshire.core :as json]
         '[clojure.edn :as edn]
         '[clojure.tools.cli :as cli])

(defn fetch-ticker-data
  [symbol]
  (let [response (slurp (format "https://query1.finance.yahoo.com/v8/finance/chart/%s" symbol))
        parsed (json/parse-string response true)]
    (-> parsed :chart :result first :meta)))

(defn scale-number
  ([n s]
   (.setScale (bigdec n) s BigDecimal/ROUND_HALF_EVEN))
  ([n]
   (if (> 10 n)
     (.setScale (bigdec n) 2 BigDecimal/ROUND_HALF_EVEN)
     (.setScale (bigdec n) 0 BigDecimal/ROUND_HALF_EVEN))))

(defn data-for-symbol
  [{:keys [symbol label icon type holding cost-basis] :as config}]
  (let [ticker-data    (fetch-ticker-data (name symbol))
        quote          (select-keys ticker-data [:symbol :previousClose])
        holding        (or holding 0)
        price          (:regularMarketPrice ticker-data)
        cost           (or cost-basis price)
        gains          (scale-number (* holding (- price cost)) 0)
        equity         (scale-number (* holding price) 0)
        equity-percent (if cost-basis
                         (scale-number (* 100
                                          (/ (* holding price)
                                             (* holding cost)))
                                       2)
                         0)]
    (assoc quote
           :type  type
           :label (or label symbol)
           :icon  icon
           :regularMarketPrice (scale-number price 2)
           :gains gains
           :equity equity
           :holding (scale-number holding)
           :cost_basis (or (scale-number cost-basis 2) 0)
           :equity_percent equity-percent)))

(defn tally-data
  [symbol-data]
  (let [total-gains (apply + (map :gains symbol-data))]
    {:total_gains total-gains
     :by_symbol   (sort-by :gains > symbol-data)
     :by_type     (reduce-kv
                   (fn [acc type rows]
                     (conj acc {:type type
                                :total (apply + (map :gains rows))}))
                   []
                   (group-by :type symbol-data))}))

(defn portfolio->data
  [config]
  (let [symbol-data  (map data-for-symbol config)
        tallied-data (tally-data symbol-data)]
    tallied-data))

(def cli-options
  [["-c" "--config FILE" "Config file in EDN" :parse-fn (comp edn/read-string slurp)]])

;; Accept an EDN file via `--config` that looks like...
;;
;;  [{:symbol :BA :holding 1 :cost-basis 50}
;;   {:symbol :HD :holding 1 :cost-basis 25}]
;;
;; and return a per-symbol listing along with a total value, like...
;;
;;  {"total_gains":375
;;   "by_type" [{"type": "S", "total": 375}],
;;   "by_symbol":[{"symbol":"BA"
;;                 "regularMarketPrice":167.5
;;                 "previousClose":169.58
;;                 "gains":117
;;                 "type": "S"
;;                 "holding":1}
;;                {"symbol":"HD"
;;                 "regularMarketPrice":283.23
;;                 "previousClose":280.68
;;                 "gains":258
;;                 "type": "S"
;;                 "holding":1}]}

(let [opts (-> *command-line-args*
               (cli/parse-opts cli-options)
               :options)
      ret  (portfolio->data (:config opts))]
  (print (json/generate-string ret)))