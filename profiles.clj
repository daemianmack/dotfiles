{:user {:jvm-opts ["-Dapple.awt.UIElement=true"]
        :plugins [[lein-try "0.4.3"]
                  [lein-pprint "1.1.1"]]
        :dependencies [[pr-foobar "0.1.1"]
                       [table "0.5.0"]
                       [pjstadig/humane-test-output "0.8.0"]]
        :injections [(require 'pjstadig.humane-test-output)
                     (pjstadig.humane-test-output/activate!)]
        :repl-options {:skip-default-init true}}

 :repl {:injections [(ns my
                       (:require
                        [clojure.java.shell :refer [sh]]
                        [clojure.pprint     :refer [pprint *print-right-margin*]]
                        [table.core         :refer [table]]
                        [clojure.java.javadoc :refer [javadoc]]))

                     (defn beep []
                       (future (sh "afplay" "-r" "3" "/System/Library/Sounds/Submarine.aiff"))
                       nil)

                     (defmacro t [form]
                       `(let [ret# (time (try
                                           ~form
                                           (catch Exception e#
                                             e#)))]
                          (my/beep)
                          ret#))

                     (defn wp [x] (binding [*print-right-margin* 455] (pprint x)))
                     (defn mp [x] (binding [*print-right-margin* 200] (pprint x)))
                     (defn np [x] (binding [*print-right-margin* 155] (pprint x)))

                     (defn pt [x] (table x :style :unicode))
                     (defn nt [x] (binding [table.width/*width* (delay 80)] (pt x)))

                     (defn list-fields [o]
                       (-> o class .getDeclaredFields seq (->> (map #(.getName %)))))

                     (defn list-methods [o]
                       (-> o class .getDeclaredMethods seq (->> (map #(.getName %)))))

                     (defn jdoc "javadoc an object" [obj]
                       (javadoc (class obj)))


                     (require '[clojure.pprint :refer [print-table]]
                              '[clojure.reflect :as r])
                     (import [clojure.lang Reflector])

                     ;;================
                     ;; Java inspection
                     ;;================

                     (defn inspect [thing]
                       (let [by-flags #(.indexOf [:public :private :protected] (first (:flags %)))]
                         (print-table (sort-by by-flags (:members (r/reflect thing))))))

                     ;; TODO Fix this to not wonk out with lengthy results columns.
                     ;; Either inspect-table or control width of columns or
                     ;; devolve to vertical printing for long things.
                     (defn prod [thing]
                       (let [members (:members (r/reflect thing))
                             publics (filter #(contains? (:flags %) :public) members)
                             methods (filter :return-type publics)
                             argless (remove (comp seq :parameter-types) methods)]
                         (->> argless
                              (map #(dissoc % :declaring-class))
                              (map #(assoc  % :result (pr-str (Reflector/invokeInstanceMember thing (str (:name %))))))
                              (map #(select-keys % [:name :result]))
                              print-table)))

                     (defn get-methods [thing]
                       (doseq [m (.getMethods (type thing))]
                         (println "Method Name: " (.getName m))
                         (println "Return Type: " (.getReturnType m) "\n")))


                     (defmacro def-let
                       "like let, but binds the expressions globally."
                       [bindings & more]
                       (let [let-expr (macroexpand `(let ~bindings))
                             names-values (partition 2 (second let-expr))
                             defs   (map #(cons 'def %) names-values)]
                         (concat (list 'do) defs more)))

                     (beep)

                     (comment :print-elapsed-test-time

                       (def time-table (atom {}))

                       (defmethod report :begin-test-var [m]
                         (swap! time-table assoc (keyword (str (:var m)))   (System/nanoTime)))

                       (defmethod report :end-test-var [m]
                         (swap! time-table update-in [(keyword (str (:var m)))] #(-   (System/nanoTime) %)))

                       (defmethod report :end-test-ns [m]
                         (println (sort (fn [[k1 v1] [k2 v2]]
                                          (compare v2 v1)) @time-table))))]

        :plugins [
                  ;; elisp: clojure-mode 20180121.1011, cider-nrepl 0.16.0, clj-refactor 20171117.317
                  [refactor-nrepl "2.4.0-SNAPSHOT"]
                  [cider/cider-nrepl "0.16.0" :exclusions [org.clojure/tools.nrepl]]]

        :dependencies [
                       ;; Specifying this allows EOG project to work with above `nrepl` plugins.
                       [org.clojure/tools.nrepl "0.2.13" :exclusions [org.clojure/clojure]]]}}
