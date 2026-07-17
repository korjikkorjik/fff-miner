FFF Miner - HiveOS custom-miner package (Pearl/PRL)

WHAT'S VERIFIED (tested in a WSL2 Ubuntu 22.04 environment with real GPU
passthrough to an RTX 4090, not on an actual HiveOS rig):
  - The `fff` Linux binary builds cleanly and self-tests correctly (GPU
    result matches independent CPU recomputation).
  - It connects to and mines live against prl.kryptex.network:7048 --
    real jobs received, real [stats] cycles at ~230 TH/s.
  - h-stats.sh's log-parsing logic (grep/awk against a real [stats] line)
    produces correct numbers.

WHAT'S NOT VERIFIED (no access to a real HiveOS rig to test against):
  - Whether HiveOS's actual flight-sheet variable names match what
    h-config.sh expects ($WALLET, $WORKER_NAME for wallet/worker;
    $CUSTOM_USER_CONFIG -- the flight sheet's free-text "extra config"
    field -- for pool, expected as "host:port:auth_style", e.g.
    "prl.kryptex.network:7048:array" or
    "de.pearl.herominers.com:1200:object"). If the miner fails to start
    with a wallet error, edit fff.conf directly instead (see below) --
    that path doesn't depend on flight-sheet variables at all.
    NOTE: $CUSTOM_URL is deliberately NOT used for pool address -- that
    name is HiveOS's own reserved manifest field (set in h-manifest.conf,
    below) for the miner package's own download URL, not a runtime variable.
  - Whether h-manifest.conf's exact field set matches what your HiveOS
    version's UI expects.
  - Whether h-stats.sh's JSON shape (hs/hs_units/ar/uptime) is exactly what
    the HiveOS agent wants for the dashboard to render correctly.
  - Whether the target rig's base OS matches the `ubuntu2204` CUDA repo
    h-run.sh uses to install libcudart/libcublas/libcublasLt on first run
    (~550MB download, mostly libcublasLt). If apt fails here, this is the
    first thing to fix -- check the rig's actual Ubuntu version and adjust
    the repo URL in h-run.sh.

HOW TO USE
  1. In the HiveOS flight sheet, add a Custom miner and paste this exact
     URL into the "Miner URL" / CUSTOM_URL field:
       https://raw.githubusercontent.com/korjikkorjik/fff-miner/main/hiveos/fff-hiveos.tar.gz
     HiveOS downloads and extracts this archive to
     /hive/miners/custom/fff on the rig automatically.
  2. In the flight sheet, either fill in wallet/worker normally and put
     "host:port:auth_style" (e.g. "prl.kryptex.network:7048:array") in the
     miner's extra-config field and hope h-config.sh picks it up, OR (more
     reliable, since untested) SSH into the rig after the first deploy and
     edit fff.conf directly in the miner folder
     (/hive/miners/custom/fff/fff.conf).
  3. First start will pause ~1-2 minutes to install CUDA runtime libs if
     they're not already present -- this is expected, not a hang.
  4. If it doesn't work, the miner's own log (fff.log in the miner folder)
     has full detail -- the underlying `fff` binary's own [net]/[job]/
     [stats]/[share] lines are unchanged from the Windows version, only the
     HiveOS wrapper scripts around it are new/unverified.

REQUIREMENTS ON THE RIG
  - NVIDIA GPU, Turing (RTX 20xx/Titan RTX) or newer.
  - Internet access + apt + sudo for the one-time CUDA runtime install.
