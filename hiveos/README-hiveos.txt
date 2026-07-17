FFF Miner - HiveOS custom-miner package (Pearl/PRL)

WHAT'S VERIFIED (on a real HiveOS rig, 2026-07-17):
  - Download via GitHub Releases URL, extraction into
    /hive/miners/custom/fff/, CUDA 13.3 runtime auto-install (one-time,
    ~550MB), and live mining against prl.kryptex.network all confirmed
    working end-to-end.
  - "Кошелек и воркер шаблона: %WAL%.%WORKER_NAME%" confirmed correct --
    cross-checked against a real working PCM-miner Custom config on the
    same rig, which uses the identical template for the same pool.
  - Multi-GPU: h-run.sh launches one fff process per detected GPU (via
    nvidia-smi -L), each pinned with CUDA_VISIBLE_DEVICES, worker names
    suffixed -gpu0/-gpu1/etc when more than one GPU is present. fff itself
    has no multi-GPU awareness (always uses whatever GPU is visible), so
    this is handled entirely in h-run.sh.

KNOWN ISSUES FOUND AND FIXED ALONG THE WAY (history, in case something
regresses):
  - v1.0.0: archive had no top-level fff/ directory, so files extracted
    loose into the shared /hive/miners/custom/ root, colliding with every
    other custom miner's expected layout -- broke miner dispatch rig-wide
    until manually cleaned up. Fixed in v1.0.1+ (archive now wraps
    everything in fff/).
  - v1.0.1/v1.0.2: h-run.sh/h-config.sh/h-stats.sh had shebang
    `#!/hive/sbin/bash-hive`, which doesn't exist on a real rig -- every
    invocation failed instantly with "bad interpreter", leaving an empty
    miner screen and no log, which looked like a miner-selection problem
    but wasn't. Fixed in v1.0.2 (shebang is now #!/usr/bin/env bash).
  - v1.0.3: added multi-GPU support (see above) -- earlier versions only
    ever used the first GPU.

NOT VERIFIED:
  - Whether HiveOS's own flight-sheet-driven launch (via `miner start`)
    correctly populates $CUSTOM_TEMPLATE/$WAL/$URL/etc for h-config.sh to
    read -- testing so far has been via manually running ./h-run.sh over
    SSH with fff.conf filled in, which works but bypasses HiveOS's own
    variable passing. If flight-sheet fields don't come through, edit
    fff.conf directly instead (see below) -- confirmed to work.
  - Whether h-stats.sh's JSON shape (hs/hs_units/ar/uptime) is what the
    HiveOS agent wants for the dashboard. With multiple GPUs, all
    processes append to the same fff.log and h-stats.sh only reads the
    single most recent [stats] line (one GPU's snapshot, not an aggregate
    of all GPUs) -- not yet fixed, cosmetic only, does not affect mining.

HOW TO USE (HiveOS "Custom конфигурация" dialog)
  Имя майнера:                    fff
  Установочный URL:               https://github.com/korjikkorjik/fff-miner/releases/download/v1.0.3/fff-hiveos.tar.gz
  Хэш алгоритм:                   pearlhash
  Кошелек и воркер шаблона:       %WAL%.%WORKER_NAME%
                                   (HiveOS substitutes %WAL% with whatever
                                   wallet you already set for this coin in
                                   the flight sheet, no need to retype it
                                   here)
  Адрес пула:                     prl.kryptex.network:7048
                                   (regional alternatives also work, e.g.
                                   prl-ru.kryptex.network:7048 -- same pool,
                                   possibly lower latency; or
                                   de.pearl.herominers.com:1200)
  Пароль:                         x (or leave blank -- a real working
                                   PCM-miner config on this pool leaves it
                                   empty)
  Доп. параметры конфигурации:    array
                                   (or object for HeroMiners -- see the pool
                                   table in the main README; this field
                                   selects mining.authorize's param style)

  HiveOS downloads and extracts the archive to /hive/miners/custom/fff on
  the rig automatically once you apply and start.

  If wallet/pool don't come through correctly from the flight sheet, SSH
  into the rig and edit fff.conf directly instead
  (/hive/miners/custom/fff/fff.conf) -- confirmed to work reliably:

    WALLET=prl1p...your real address...
    WORKER_NAME=rig1
    POOL_HOST=prl.kryptex.network
    POOL_PORT=7048
    AUTH_STYLE=array

  Check fff.log after starting -- the "[h-run] starting GPU N as worker
  ..." lines show exactly what got resolved for each GPU.

REQUIREMENTS ON THE RIG
  - NVIDIA GPU, Turing (RTX 20xx/Titan RTX) or newer. Multiple GPUs
    supported (one fff process per GPU, launched automatically).
  - Internet access + apt + sudo for the one-time CUDA runtime install.
