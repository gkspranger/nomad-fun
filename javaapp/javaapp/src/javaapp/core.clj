(ns javaapp.core
  (:gen-class)
  (:require [io.pedestal.http :as http]
            [io.pedestal.http.route :as route]
            [iapetos.core :as prom]
            [iapetos.collector.jvm :as prom-jvm]
            [iapetos.export :as prom-export]))

(def app-port (Integer/parseInt (or (System/getenv "APP_PORT") "8080")))
(def app-name (or (System/getenv "APP_NAME") "DEFAULT"))
(def app-instance (or (System/getenv "APP_INSTANCE") "DEFAULT"))

(defonce prom-reg
  (-> (prom/collector-registry)
      (prom-jvm/initialize)
      (prom/register
       (prom/counter :app/greets))))

(defn hello-text
  []
  (str "app_name=" app-name "; app_instance=" app-instance "; app_port=" app-port))

(defn respond-hello
  [_request]
  (-> prom-reg
      (prom/inc :app/greets))
  {:status 200 :body (hello-text)})

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
    ::http/host "0.0.0.0"
    ::http/port app-port}))

(defn -main
  [& _args]
  (http/start (create-server)))
