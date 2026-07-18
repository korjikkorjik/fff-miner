FFF Miner 1.1.3e - HiveOS custom miner for Pearl (PRL)

FLIGHT SHEET
  Miner:                         custom
  Miner name:                    fff
  Installation URL:              https://github.com/korjikkorjik/fff-miner/releases/download/v1.1.3e/fff-1.1.3e.tar.gz
  Hash algorithm:                pearlhash
  Wallet and worker template:    %WAL%.%WORKER_NAME%
  Pool:                          prl.kryptex.network:7048
  Password:                      x
  Extra config arguments:        array

Use "object" instead of "array" for pools that require object-style
mining.authorize parameters, such as HeroMiners.

PACKAGE LAYOUT
  The archive name is fff-1.1.3e.tar.gz, so HiveOS detects miner "fff" and
  version "1.1.3e". The archive contains exactly one top-level directory:

    fff/
      fff.bin
      fff.conf
      h-config.sh
      h-manifest.conf
      h-run.sh
      h-stats.sh

  HiveOS installs it into /hive/miners/custom/fff. It does not overwrite
  the shared /hive/miners/custom/h-*.sh wrappers used to switch between
  different custom miners.

RECOVERY FROM v1.1.3d
  v1.1.3d had an invalid flat archive and could overwrite HiveOS's shared
  custom-miner wrappers. Stop the miner and run these commands once in
  Hive Shell:

    wget -qO /tmp/fff-repair.sh https://github.com/korjikkorjik/fff-miner/releases/download/v1.1.3e/repair-1.1.3d.sh
    bash /tmp/fff-repair.sh

  The repair restores the official HiveOS shared hooks and force-installs
  FFF 1.1.3e into /hive/miners/custom/fff. Re-apply the required flight
  sheet after it reports success.

DIRECT CONFIGURATION
  If a flight-sheet value is not passed through, edit:

    /hive/miners/custom/fff/fff.conf

  Values:

    WALLET=prl1p...your address...
    WORKER_NAME=rig1
    POOL_HOST=prl.kryptex.network
    POOL_PORT=7048
    AUTH_STYLE=array

RUNTIME
  h-run.sh detects NVIDIA GPUs and launches one fff.bin process per GPU,
  pinned with CUDA_VISIBLE_DEVICES. All processes use the same worker name.

  Combined log:
    /hive/miners/custom/fff/fff.log

  Per-GPU logs:
    /hive/miners/custom/fff/fff-gpu0.log
    /hive/miners/custom/fff/fff-gpu1.log
    ...

  The HiveOS statistics hook reports per-GPU hashrate, total accepted and
  rejected shares, and uptime. Logs are capped automatically.

REQUIREMENTS
  - NVIDIA Turing (RTX 20-series / Titan RTX) or newer.
  - A compatible NVIDIA driver.
  - No apt installation and no system CUDA installation are performed.
