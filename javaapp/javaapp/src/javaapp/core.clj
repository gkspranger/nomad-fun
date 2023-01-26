(ns javaapp.core
  (:gen-class)
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [iapetos.core :as prom]
            [iapetos.collector.jvm :as prom-jvm]
            [iapetos.export :as prom-export]))

(def port (Integer/parseInt (or (System/getenv "APP_PORT") "8080")))

(defonce prom-reg
  (-> (prom/collector-registry)
      (prom-jvm/initialize)
      (prom/register
       (prom/counter :app/greets))))

(defn respond-hello
  [_request]
  (-> prom-reg
      (prom/inc :app/greets))
  {:status 200 :body "Hello, world!"})

(defn respond-metrics
  [_request]
  {:status 200 :body (prom-export/text-format prom-reg)})

(def routes
  (route/expand-routes
   #{["/greet" :get respond-hello :route-name :greet]
     ["/metrics" :get respond-metrics :route-name :metrics]}))

(defn create-server []
  (http/create-server
   {::http/routes routes
    ::http/type :jetty
    ::http/port port}))

(defn -main
  [& _args]
  (http/start (create-server)))
