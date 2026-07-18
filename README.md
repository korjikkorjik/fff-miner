# FFF — GPU-native Pearl (PRL) miner

A CUDA miner for [Pearl (PRL)](https://prl.kryptex.network). Matrix generation, hashing, and the jackpot scan all run on the GPU; the CPU only handles networking and proof submission.

Two builds are provided here — no source code, just ready-to-run binaries:

- **[`fff-windows.zip`](fff-windows.zip)** — Windows, double-click to run.
- **[`hiveos/fff-hiveos.tar.gz`](hiveos/fff-hiveos.tar.gz)** — HiveOS custom miner package.

Current test build: **v1.1.3c**. It adds a native persistent SM75 tensor-core
path for RTX 20-series / Titan RTX and one-time automatic kernel scheduling
for RTX 30xx / 40xx. The first scan includes the short auto-tuning pass;
subsequent hashrate lines represent steady-state speed.

The HiveOS binary is self-contained: it does not run `apt`, install CUDA
packages, or modify the rig's system CUDA environment.

## Requirements

NVIDIA GPU, Turing (RTX 20-series / Titan RTX) or newer (RTX 30xx / 40xx also supported). Recent NVIDIA driver.

## Windows

1. Download and extract [`fff-windows.zip`](fff-windows.zip) (or use the [`windows/`](windows/) folder directly).
2. Right-click `start.bat` → **Edit**.
3. Set `WALLET` to your real `prl1p...` address and `WORKER` to a name for this rig.
4. Save, close, double-click `start.bat`.

### Supported pools (plain TCP only, no SSL)

| Pool | `POOL_HOST` | `POOL_PORT` | `AUTH_STYLE` |
|---|---|---|---|
| Kryptex (default) | `prl.kryptex.network` | `7048` | `array` |
| HeroMiners | `de.pearl.herominers.com` | `1200` | `object` |

Both edit the same variables at the top of `start.bat`. Other Pearl pools may use either `AUTH_STYLE` — if the miner fails to authorize, try switching it. Pools that only offer SSL/TLS endpoints are not supported (plain TCP only).

The console prints one summary line every few seconds — throughput (TH/s), accepted/rejected shares, and a probability estimate for how long until the next share. `[share] ACCEPTED`/`REJECTED` lines confirm pool responses.

## HiveOS

Add a Custom miner in your flight sheet and paste this exact URL into the "Miner URL" field:

```
https://github.com/korjikkorjik/fff-miner/releases/download/v1.1.3c/fff-hiveos-v1.1.3c.tar.gz
```

HiveOS downloads and extracts it automatically. For wallet/worker/pool configuration and full details, see [`hiveos/README-hiveos.txt`](hiveos/README-hiveos.txt).

The HiveOS wrapper and dashboard statistics are running on real multi-GPU
rigs. The v1.1.3c Linux binary also passes the GPU/CPU proof self-test. If a
flight-sheet field is not picked up, edit `fff.conf` directly in the miner
folder over SSH; that path does not depend on HiveOS variable passing.

## Developer fee

This miner takes a **1.5% developer fee**: roughly every 20 minutes, it mines for ~18 seconds to the developer's own address before switching back to yours. This is the same model used by other redistributable miners (XMRig, SRBMiner, etc.). You'll see a `[fee]` line in the console when a fee window starts and ends.

## Troubleshooting

- **Miner won't authorize / "params must be an object"** — wrong `AUTH_STYLE` for that pool, see the table above.
- **No shares showing on the pool's dashboard** — double-check `WALLET` is your actual address on that pool, not a leftover placeholder. Accepted shares are logged locally (`[share] ACCEPTED`) regardless of what the dashboard shows.
- **Speed looks unstable** — normal cycle-to-cycle jitter is a few percent; larger dips can be thermal/power throttling under sustained load.
