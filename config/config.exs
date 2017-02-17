# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :hive,
  workers: 20,
  start_delay: 7_000,
  kill_delay: 10_000

config :libcluster,
  topologies: [
    hive: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: ~w(a@127.0.0.1 b@127.0.0.1 c@127.0.0.1)a
      ]
    ]
  ]
