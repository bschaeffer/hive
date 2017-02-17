# Hive

Example using [swarm][] to distribute processes across nodes with failover
monitoring.

When swarm registers a process on a node, and that process exits abnormally,
and/or is restarted by its local supervisor, Swarm will not account for this
process during topology changes. This uses a GenServer process to register
and monitor Swarm registered processes, and when abnormal exits occur,
re-registers the processes through Swarm again.

## Usage

```bash
iex --name a@127.0.0.1 -S mix
iex --name b@127.0.0.1 -S mix
iex --name c@127.0.0.1 -S mix
```

[swarm]: https://github.com/bitwalker/swarm
