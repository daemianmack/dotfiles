#!/usr/local/bin/bb

(require '[cheshire.core :as json]
         '[clojure.edn :as edn]
         '[clojure.tools.cli :as cli])

(defn fetch-ticker-data
  [symbol]
  (let [response (slurp (format "https://query1.finance.yahoo.com/v8/finance/chart/%s" symbol))
        parsed (json/parse-string response true)]
    (-> parsed :chart :result first :meta)))

(defn data-for-symbol
  [{:keys [symbol label type holding cost-basis] :as config}]
  (let [ticker-data (fetch-ticker-data (name symbol))
        quote       (select-keys ticker-data [:symbol :previousClose])
        holding     (or holding 0)
        cost-basis  (or cost-basis (:regularMarketPrice quote))]
    (assoc quote
           :type  type
           :label (or label symbol)
           :regularMarketPrice (:regularMarketPrice ticker-data)
           :value (int (* holding (- (:regularMarketPrice ticker-data)
                                     cost-basis)))
           :holding holding)))

(defn scale-number
  [n]
  (if (> 1 n)
    (.setScale (bigdec n) 2 BigDecimal/ROUND_HALF_EVEN)
    (.setScale (bigdec n) 0 BigDecimal/ROUND_HALF_EVEN)))

(defn tally-data
  [symbol-data]
  (let [total-value (apply + (map :value symbol-data))]
    {:total_value total-value
     :by_symbol   (map (fn [m]
                         (-> m
                             (update :regularMarketPrice scale-number)
                             (update :holding scale-number)))
                       (sort-by :value > symbol-data))
     :by_type     (reduce-kv
                   (fn [acc type rows]
                     (conj acc {:type type
                                :total (apply + (map :value rows))}))
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
;; and return a per-symbol listing with current value and previous
;; close, along with a total value, like...
;;
;;  {"total_value":375
;;   "by_type" [{"type": "S", "total": 375}],
;;   "by_symbol":[{"symbol":"BA"
;;                 "regularMarketPrice":167.5
;;                 "previousClose":169.58
;;                 "value":117
;;                 "type": "S"
;;                 "holding":1}
;;                {"symbol":"HD"
;;                 "regularMarketPrice":283.23
;;                 "previousClose":280.68
;;                 "value":258
;;                 "type": "S"
;;                 "holding":1}]}

(let [opts (-> *command-line-args*
               (cli/parse-opts cli-options)
               :options)
      ret  (portfolio->data (:config opts))]
  (print (json/generate-string ret)))