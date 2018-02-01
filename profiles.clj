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
                        [table.core         :refer [table]]))

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
                  [cider/cider-nrepl "0.16.0" :exclusions [org.clojure/tools.nrepl]]

                  ;; Working, old.
                  ;; elisp: clojure-mode 20170622.2345, cider-nrepl 0.15.1, clj-refactor 20170608.320.
                  ;; [refactor-nrepl "2.3.1"]
                  ;; [cider/cider-nrepl "0.15.1" :exclusions [org.clojure/tools.nrepl]]

                  ;; ;; For org-babel with Clojure.
                  ;; [refactor-nrepl "2.4.0-SNAPSHOT" :exclusions [org.clojure/tools.nrepl]]
                  ;; [cider/cider-nrepl "0.15.0-20170707.160134-22" :exclusions [org.clojure/tools.nrepl]]
                  ;; ;; For Sayid
                  ;; [com.billpiel/sayid "0.0.15"]
                  ;; [refactor-nrepl "2.2.0"]
                  ;; [cider/cider-nrepl "0.14.0"]

                  ;; breaks on Clojure 1.9.0-alpha18
                  ;; [refactor-nrepl "2.3.1"]
                  ;; [cider/cider-nrepl "0.14.0"]

                  ;; For Cider 0.14.0, clj-refactor-2.2.0
                  ;; [refactor-nrepl "2.2.0" :exclusions [org.clojure/tools.nrepl]]
                  ;; [cider/cider-nrepl "0.11.0" :exclusions [org.clojure/tools.nrepl]]

                  ;; ;; for Cider 0.12.0, clj-refactor-2.2.0
                  ;; [refactor-nrepl "2.2.0"]
                  ;; [cider/cider-nrepl "0.12.0"]

                  ;; ;; For Cider 0.10.2, clj-refactor-2.0.0
                  ;; [refactor-nrepl "2.0.0"]
                  ;; [cider/cider-nrepl "0.10.2"]

                  ;; For Cider 0.10.1
                  #_[cider/cider-nrepl "0.10.1"]
                  #_[refactor-nrepl "2.1.0-alpha1"]

                  ;; For Cider 0.10.0
                  #_[cider/cider-nrepl "0.10.0"]
                  #_[refactor-nrepl "2.0.0-SNAPSHOT"]

                  ]
        :dependencies [
                       ;; Specifying this allows EOG project to work with above `nrepl` plugins.
                       [org.clojure/tools.nrepl "0.2.13" :exclusions [org.clojure/clojure]]]}}
