FFF Miner - HiveOS custom-miner package (Pearl/PRL)

WHAT'S VERIFIED (tested in a WSL2 Ubuntu 22.04 environment with real GPU
passthrough to an RTX 4090, not on an actual HiveOS rig):
  - The `fff` Linux binary builds cleanly and self-tests correctly (GPU
    result matches independent CPU recomputation).
  - It connects to and mines live against prl.kryptex.network:7048 --
    real jobs received, real [stats] cycles at ~230 TH/s.
  - h-stats.sh's log-parsing logic (grep/awk against a real [stats] line)
    produces correct numbers.
  - The "Установочный URL" field of HiveOS's own Custom-miner dialog
    correctly picked up CUSTOM_URL from h-manifest.conf (confirmed from a
    screenshot) -- the package download step itself works.

WHAT'S NOT VERIFIED (no access to a real HiveOS rig to test against):
  - The exact env var names HiveOS exports for the other Custom-miner
    dialog fields (wallet/worker template, pool address, password, extra
    config). h-config.sh tries several plausible names per field (see
    "HOW TO USE" below) rather than a single guess, but none of it is
    confirmed against a live rig.
  - Whether h-stats.sh's JSON shape (hs/hs_units/ar/uptime) is exactly what
    the HiveOS agent wants for the dashboard to render correctly.
  - Whether the target rig's base OS matches the `ubuntu2204` CUDA repo
    h-run.sh uses to install libcudart/libcublas/libcublasLt on first run
    (~550MB download, mostly libcublasLt). If apt fails here, this is the
    first thing to fix -- check the rig's actual Ubuntu version and adjust
    the repo URL in h-run.sh.

HOW TO USE (HiveOS "Custom конфигурация" dialog)
  Имя майнера:                    fff
  Установочный URL:               https://raw.githubusercontent.com/korjikkorjik/fff-miner/main/hiveos/fff-hiveos.tar.gz
  Хэш алгоритм:                   pearlhash
  Кошелек и воркер шаблона:       <your real prl1p... address>.%WORKER_NAME%
                                   e.g. prl1pw37c...wt8.%WORKER_NAME%
  Адрес пула:                     prl.kryptex.network:7048
                                   (or de.pearl.herominers.com:1200)
  Пароль:                         x
  Доп. параметры конфигурации:    array
                                   (or object -- see the pool table in the
                                   main README; this field selects
                                   mining.authorize's param style)

  HiveOS downloads and extracts the archive to /hive/miners/custom/fff on
  the rig automatically once you apply and start.

  h-config.sh resolves these fields by trying, in order: $CUSTOM_TEMPLATE /
  $TEMPLATE / $CUSTOM_USER_TEMPLATE / $WAL for the wallet.worker template
  (split on the first "."), $URL / $STRATUM_URL / $POOL for the pool
  address (stratum+tcp:// / stratum+ssl:// prefix stripped if present),
  $PASS / $EMAIL for the password, and $CUSTOM_USER_CONFIG (trimmed) for
  the auth style. Check fff.log after first start -- the
  "[h-run] starting: ./fff ..." line shows exactly what got resolved. If
  wallet/pool didn't come through correctly, SSH into the rig and edit
  fff.conf directly instead (/hive/miners/custom/fff/fff.conf) -- that path
  is independent of flight-sheet variable names entirely.

REQUIREMENTS ON THE RIG
  - NVIDIA GPU, Turing (RTX 20xx/Titan RTX) or newer.
  - Internet access + apt + sudo for the one-time CUDA runtime install.
