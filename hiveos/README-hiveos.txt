FFF Miner - HiveOS custom-miner package (Pearl/PRL)

VERIFIED END-TO-END ON A REAL RIG (2026-07-17): downloaded via GitHub
Releases, launched through the actual flight-sheet "Custom конфигурация"
path (miner stop / miner start, not just manual testing), running on 2 GPUs
simultaneously (RTX 4080 + RTX 4090), shares accepted by the pool. This
took several real bugs to get here -- see below, in case anything similar
ever needs re-diagnosing.

HOW TO USE (HiveOS "Custom конфигурация" dialog)
  Имя майнера:                    fff
  Установочный URL:               https://github.com/korjikkorjik/fff-miner/releases/download/v1.0.6/fff-hiveos.tar.gz
  Хэш алгоритм:                   pearlhash
  Кошелек и воркер шаблона:       %WAL%.%WORKER_NAME%
  Адрес пула:                     prl.kryptex.network:7048
                                   (regional alternatives also confirmed
                                   working, e.g. prl-ru.kryptex.network:7048;
                                   or de.pearl.herominers.com:1200)
  Пароль:                         x (or leave blank)
  Доп. параметры конфигурации:    array
                                   (or object for HeroMiners -- see the pool
                                   table in the main README; this field
                                   selects mining.authorize's param style)

  If wallet/pool don't come through correctly from the flight sheet, SSH in
  and edit fff.conf directly (/hive/miners/custom/fff.conf -- note: NOT in
  a subfolder, see below):

    WALLET=prl1p...your real address...
    WORKER_NAME=rig1
    POOL_HOST=prl.kryptex.network
    POOL_PORT=7048
    AUTH_STYLE=array

  Multiple GPUs are handled automatically: h-run.sh detects all GPUs via
  nvidia-smi and launches one fff process per GPU (CUDA_VISIBLE_DEVICES-
  pinned). All GPUs share the SAME worker name (no -gpuN suffix, fixed in
  v1.0.5) so the pool shows one combined worker for the whole rig instead
  of N separate ones. Per-card output still goes to its own log
  (fff-gpu0.log, fff-gpu1.log, ...) so h-stats.sh can report a proper
  per-card hashrate breakdown to the HiveOS dashboard (the "hs" array, one
  entry per GPU in nvidia-smi order) -- this also fixed `miner`/screen -r
  showing nothing: fff's output used to go only to the log file, now it's
  tee'd to the screen too, so live output is visible there again.

  Log size is capped (v1.0.6): fff runs for weeks and prints a [stats]
  line every few seconds per GPU, so h-run.sh checks every 5 minutes and
  trims any of fff.log/fff-gpuN.log back to its last 5MB once it exceeds
  20MB -- self-contained, doesn't depend on the rig's system logrotate/cron
  actually being configured. Check
  fff.log for the combined feed, or fff-gpuN.log for one card's own output.

REQUIREMENTS ON THE RIG
  - NVIDIA GPU, Turing (RTX 20xx/Titan RTX) or newer. Multiple GPUs
    supported.
  - Internet access + apt + sudo for the one-time CUDA 13.3 runtime install
    (~550MB, mostly libcublasLt -- happens automatically on first start).

=== BUGS FOUND AND FIXED GETTING HERE (all confirmed root-caused on a real
rig via direct SSH investigation, not guessed) ===

1. v1.0.0: files landed loose in the shared /hive/miners/custom/ root at a
   moment when a DIFFERENT custom miner (pcm-miner) was actually selected
   there, clobbering its control files -- looked like "flat archive breaks
   things." v1.0.1-v1.0.3 "fixed" this by wrapping the archive in a fff/
   subfolder. That was based on a wrong assumption. Root-caused via bug 7:
   HiveOS's real runtime path (miner-run) always expects
   h-manifest.conf/h-config.sh/h-run.sh/h-stats.sh directly AT
   /hive/miners/custom/ (the shared root) for WHICHEVER custom miner is
   currently selected -- there is no per-miner subfolder at runtime, only
   one "slot". A flat archive is actually correct; the real v1.0.0 bug was
   applying it while a different miner's flight sheet was still active
   (i.e. a switching/sequencing issue, not a packaging-shape issue).
   v1.0.4 reverted to a flat archive (confirmed working end-to-end).

2. v1.0.1/1.0.2: h-run.sh/h-config.sh/h-stats.sh had shebang
   `#!/hive/sbin/bash-hive`, which doesn't exist on a real rig -- broke
   every manual `./h-run.sh` invocation instantly. Turned out NOT to matter
   for the real flight-sheet path (see bug 3), but fixed anyway
   (#!/usr/bin/env bash) since manual/SSH testing depends on it.

3. HiveOS's real miner launcher (/hive/bin/miner-run) *sources* h-run.sh
   into its own shell (`source $MINER_DIR/h-run.sh`) rather than executing
   it as a subprocess -- so the shebang line is irrelevant for the real
   path, and more importantly `$0` inside h-run.sh refers to miner-run's
   own path, not h-run.sh's. `cd "$(dirname "$0")"` therefore cd's to the
   wrong directory (/hive/bin) when launched for real. Fixed: cd via
   `${MINER_DIR:-$(dirname "$0")}` -- miner-run already exports MINER_DIR;
   falls back to dirname "$0" for manual `./h-run.sh` testing, where $0 is
   correct.

4. miner-run calls h-config.sh expecting it to *define functions*
   (miner_ver(), miner_config_gen(), optionally miner_fork()) which it then
   calls at specific points -- not a flat top-to-bottom script. An
   undefined function call inside `( config_miner ) || exit $?` (a
   subshell) kills the ENTIRE miner-run process instantly with no visible
   error in the miner screen (looks exactly like "nothing happens", which
   is what made this so hard to find). Fixed: h-config.sh now defines
   miner_ver()/miner_config_gen()/miner_config_echo(); h-run.sh explicitly
   calls miner_config_gen after sourcing h-config.sh (sourcing alone no
   longer runs the resolution logic, since it's now inside a function).

5. miner_ver() originally returned $CUSTOM_VERSION. HiveOS interprets a
   non-empty MINER_VER as "this miner ships a versioned apt package,
   hive-miners-custom-$VERSION" and tries to apt-install it -- which
   doesn't exist for a plain custom-get-installed miner, so install_miner()
   fails and exits. Fixed: miner_ver() returns "" (empty) unconditionally.

6. THE BIG ONE: h-manifest.conf defined its own `CUSTOM_URL=<our github
   package link>`. This collides with wallet.conf's CUSTOM_URL, which is
   the POOL address, sourced by miner-run *before* h-manifest.conf is
   sourced -- so our own h-manifest.conf clobbered the real pool address
   with our package's download link. Result: fff tried to connect to
   "https" as hostname and "//github.com/.../fff-hiveos.tar.gz" as port
   ("Error: invalid digit found in string", instant exit, retry loop).
   HiveOS's real convention: CUSTOM_URL = pool address (owned by
   wallet.conf/flight sheet), CUSTOM_INSTALL_URL = package download URL
   (also owned by wallet.conf, separate variable) -- h-manifest.conf has NO
   business declaring either one. Fixed: removed CUSTOM_URL from
   h-manifest.conf entirely.

7. miner-run's actual runtime path is MINER_DIR=/hive/miners/$MINER_NAME
   where MINER_NAME is literally "custom" (from rig.conf's MINER=custom),
   never a per-miner subfolder -- confirmed by reading /hive/bin/miner-run
   directly. custom-get (HiveOS's download/extract script) just does
   `cd /hive/miners/custom && tar -xzv -f $archive`, i.e. it extracts
   whatever paths the archive contains, with no subfolder logic of its own
   -- a flat archive (as of v1.0.4) therefore lands files exactly where
   miner-run expects them, no extra copy step needed. custom-get does
   separately derive a "miner name" from the archive filename for its own
   caching bookkeeping (an "already installed, skip re-download" check, and
   a chown target) -- this is cosmetic for a flat archive (the derived
   directory just never exists, so that check is always a cache-miss,
   which only means an occasional redundant re-download, not a failure).
