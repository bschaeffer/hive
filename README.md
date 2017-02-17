# Hive

Example using [swarm][] to distribute processes across nodes, with failover
monitoring.

This example randomly starts and stops workers.

## Usage

```bash
iex --name a@127.0.0.1 -S mix
iex --name b@127.0.0.1 -S mix
iex --name c@127.0.0.1 -S mix
```
