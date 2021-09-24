#!/usr/local/bin/bb

(require '[cheshire.core :as json]
         '[clojure.edn :as edn]
         '[clojure.tools.cli :as cli])

(defn scale-number
  ([n s]
   (.setScale (bigdec n) s BigDecimal/ROUND_HALF_EVEN))
  ([n]
   (if (> 10 n)
     (.setScale (bigdec n) 2 BigDecimal/ROUND_HALF_EVEN)
     (.setScale (bigdec n) 0 BigDecimal/ROUND_HALF_EVEN))))

(defn priced-symbol-data
  [{:keys [type symbol label icon holding cost-basis]}
   price
   up-on-day?]
  (let [cost        (or cost-basis price)
        gains       (* holding (- price cost))
        equity      (* holding price)
        spent       (* holding cost)
        ;; Special-case multiplier, high-level indicator
        equity-mult (when (pos? cost-basis)
                      (let [mult (/ equity spent)]
                        (when (< 1 mult)
                          (scale-number mult 2))))
        ;; General case view of equity-mult, detail-level
        equity-pct  (if (pos? cost-basis)
                      (scale-number (* 100 (/ equity spent))
                                    2)
                      0)]
    {:symbol         symbol
     :holding        (scale-number holding)
     :type           type
     :label          (or label symbol)
     :icon           icon
     :price          (scale-number price 2)
     :gains          (scale-number gains 0)
     :equity         (scale-number equity 0)
     :equity_mult    equity-mult
     :equity_percent equity-pct
     :cost_basis     cost-basis
     :up_on_day      up-on-day?}))

(def nomics-url "https://api.nomics.com/v1/currencies/ticker")

(defn nomics-price
  [symbol-datas]
  (let [coin-ids (str/join "," (map :qname symbol-datas))
        resp (curl/get nomics-url {:query-params {"ids" coin-ids
                                                  "interval" "1h,1d"
                                                  "key" "bdd6a02e71bd0d7be1b1be479b85210437da8347"}})
        quotes (group-by :id (json/parse-string (:body resp) true))]
    (def q quotes)
    (map (fn [{:keys [qname] :as symbol-data}]
           (if (not (contains? quotes qname))
             {:price 0}
             (let [quote      (get-in quotes [qname 0])
                   price      (get quote :price)
                   up-on-day? (when-let [change (get-in quote [:1d :price_change])]
                                (pos? (Double/parseDouble change)))]
               (priced-symbol-data symbol-data (Double/parseDouble price) up-on-day?))))
         symbol-datas)))

(def coingecko-url-base "https://api.coingecko.com/api/v3/")

(defn coingecko-price
  [symbol-datas]
  (let [endpoint (str coingecko-url-base "simple/price")
        coin-ids (str/join "," (map :qname symbol-datas))
        currency "usd"
        resp     (curl/get endpoint {:query-params {"ids"                 coin-ids
                                                    "vs_currencies"       currency
                                                    "include_24hr_change" "true"}})
        quotes   (json/parse-string (:body resp))]
    (map (fn [{:keys [qname] :as symbol-data}]
           (if (not (contains? quotes qname))
             {:price 0}
             (let [quote      (get quotes qname)
                   price      (get quote "usd")
                   up-on-day? (when-let [change (get quote "usd_24h_change")]
                                (pos? change))]
               (priced-symbol-data symbol-data price up-on-day?))))
         symbol-datas)))

(defn fetch [quote-source symbol-datas] quote-source)
(defmulti fetch-from-quote-source fetch)

(defmethod fetch-from-quote-source :nomics [_ symbol-datas]
  (nomics-price symbol-datas))

(defmethod fetch-from-quote-source :coingecko [_ symbol-datas]
  (coingecko-price symbol-datas))

(defn fetch-ticker-data
  [symbol]
  (let [response (slurp (format "https://query1.finance.yahoo.com/v8/finance/chart/%s" symbol))
        parsed (json/parse-string response true)]
    (-> parsed :chart :result first :meta)))

(defn yahoo-fetch-from-quote-source
  [{:keys [symbol label icon type holding cost-basis] :as config}]
  (let [ticker-data (fetch-ticker-data (name symbol))
        prev-close  (get ticker-data :previousClose)
        price       (get ticker-data :regularMarketPrice)
        up-on-day?  (< prev-close price)]
    (priced-symbol-data config price up-on-day?)))

(defmethod fetch-from-quote-source :yahoo
  [_ symbol-datas]
  (map yahoo-fetch-from-quote-source symbol-datas))

(defn tally-data
  [symbol-data]
  (let [total-gains (apply + (map :gains symbol-data))
        total-equity (apply + (map :equity symbol-data))]
    {:total_gains total-gains
     :total_equity total-equity
     :by_symbol   (sort-by :gains > symbol-data)
     :by_type     (reduce-kv
                   (fn [acc type rows]
                     (conj acc {:type type
                                :total (apply + (map :gains rows))}))
                   []
                   (group-by :type symbol-data))}))

(defn symbol-data-by-type
  [config]
  (let [grouped   (group-by :qsrc config)]
    (mapcat (fn [[group symbol-datas]]
              (fetch-from-quote-source group symbol-datas))
            grouped)))

(defn portfolio->data
  [config]
  (let [symbol-data  (symbol-data-by-type config)
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