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
    h-config.sh expects ($WALLET, $WORKER_NAME, $CUSTOM_URL). If the miner
    fails to start with a wallet error, edit fff.conf directly instead
    (see below) -- that path doesn't depend on flight-sheet variables at
    all.
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
  1. Upload this folder as /hive/miners/custom/fff on the rig (or package
     as fff-hiveos.tar.gz and set CUSTOM_URL in h-manifest.conf to a URL
     you host it at, per HiveOS's custom-miner docs).
  2. In the flight sheet, either fill in wallet/worker normally and hope
     h-config.sh picks them up, OR (more reliable, since untested) SSH into
     the rig and edit fff.conf directly in the miner folder.
  3. First start will pause ~1-2 minutes to install CUDA runtime libs if
     they're not already present -- this is expected, not a hang.
  4. If it doesn't work, the miner's own log (fff.log in the miner folder)
     has full detail -- the underlying `fff` binary's own [net]/[job]/
     [stats]/[share] lines are unchanged from the Windows version, only the
     HiveOS wrapper scripts around it are new/unverified.

REQUIREMENTS ON THE RIG
  - NVIDIA GPU, Turing (RTX 20xx/Titan RTX) or newer.
  - Internet access + apt + sudo for the one-time CUDA runtime install.
