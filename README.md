# FFF — GPU miner for Pearl (PRL)

CUDA miner for [Pearl (PRL)](https://prl.kryptex.network).

Requires an NVIDIA GPU, Turing (RTX 20-series / Titan RTX) or newer, and a recent driver.

**Downloads: [Releases](../../releases/latest)**

Questions and updates: [FFF Miner on Telegram](https://t.me/+8wV51sFhRUJmNmIy)

## Windows

1. Download `fff-windows.zip` from [Releases](../../releases/latest) and extract it.
2. Right-click `start.bat` → **Edit**.
3. Set `WALLET` to your `prl1p...` address and `WORKER` to a name for this rig.
4. Save, close, double-click `start.bat`.

Pools (plain TCP only, no SSL):

| Pool | `POOL_HOST` | `POOL_PORT` | `AUTH_STYLE` |
|---|---|---|---|
| Kryptex (default) | `prl.kryptex.network` | `7048` | `array` |
| HeroMiners | `de.pearl.herominers.com` | `1200` | `object` |

All of these are variables at the top of `start.bat`. If the miner fails to authorize, switch `AUTH_STYLE` to the other value.

## HiveOS

Create a flight sheet with a Custom miner:

| Field | Value |
|---|---|
| Miner | `custom` |
| Miner name | `fff` |
| Installation URL | `https://github.com/korjikkorjik/fff-miner/releases/download/v1.1.1a/fff-1.1.1a.tar.gz` |
| Hash algorithm | `pearlhash` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `prl.kryptex.network:7048` |
| Password | `x` |
| Extra config arguments | `array` |

Use `object` instead of `array` for pools that require object-style authorization, such as HeroMiners.

HiveOS downloads and installs the package automatically. One miner process is started per GPU, and hashrate, accepted/rejected shares and uptime are reported to the dashboard.

If a flight-sheet field is not picked up, edit `/hive/miners/custom/fff/fff.conf` over SSH:

```text
WALLET=prl1p...your address...
WORKER_NAME=rig1
POOL_HOST=prl.kryptex.network
POOL_PORT=7048
AUTH_STYLE=array
```

## Developer fee

1.5%.
