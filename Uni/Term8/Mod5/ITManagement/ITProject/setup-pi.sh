#!/bin/bash
# =============================================================================
# CareCircle AI — Raspberry Pi 3 Setup (NO apt-get required)
#
# Tools installed without touching the system package manager:
#   • Node.js 20  →  nvm  (downloads pre-built ARM binaries from nodejs.org)
#   • Docker      →  static binary tarball from download.docker.com
#                    (only if Docker is not already present; only on 64-bit OS)
#   • PostgreSQL  →  Docker container  |  OR  native postgres if already there
#
# Usage:  bash setup-pi.sh
# Runs from: ~/Projects/calm-care-display  (already cloned on the Pi)
# =============================================================================
set -euo pipefail

PROJECT_DIR="$HOME/Projects/calm-care-display"
BACKEND_DIR="$PROJECT_DIR/backend"
LOG="$PROJECT_DIR/setup.log"

# ── colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
step() { echo -e "\n${GREEN}[STEP]${NC} $*" | tee -a "$LOG"; }
info() { echo -e "${CYAN}       $*${NC}" | tee -a "$LOG"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG"; }
die() {
  echo -e "\n${RED}[ERROR]${NC} $*\n" | tee -a "$LOG"
  exit 1
}

echo "=============================================" | tee "$LOG"
echo " CareCircle AI — Pi Setup  $(date)" | tee -a "$LOG"
echo "=============================================" | tee -a "$LOG"

# detect architecture  (armv7l = 32-bit Raspbian | aarch64 = 64-bit OS)
ARCH=$(uname -m)
info "Architecture detected: $ARCH"

# ─────────────────────────────────────────────────────────────────────────────
# 0. Sanity check
# ─────────────────────────────────────────────────────────────────────────────
[ -d "$PROJECT_DIR" ] || die "Project not found at $PROJECT_DIR — make sure the repo is cloned there."
cd "$PROJECT_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# 1. Swap space  (no apt needed — plain dd + mkswap)
# ─────────────────────────────────────────────────────────────────────────────
step "1/7  Swap space"
SWAP_MB=$(free -m | awk '/^Swap:/{print $2}')
if [ "$SWAP_MB" -lt 1024 ]; then
  if [ ! -f /swapfile ]; then
    warn "Less than 1 GB swap — creating a 2 GB swapfile (Node builds need it on 1 GB RAM)"
    sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress 2>&1 | tee -a "$LOG"
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile >>"$LOG" 2>&1
    sudo swapon /swapfile
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl vm.swappiness=10 >>"$LOG" 2>&1
  else
    sudo swapon /swapfile 2>/dev/null || true
  fi
  info "Swap now: $(free -h | awk '/^Swap:/{print $2}')"
else
  info "Swap already OK (${SWAP_MB} MB). Skipping."
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2. Node.js 20 via nvm  (pure bash — zero apt required)
# ─────────────────────────────────────────────────────────────────────────────
step "2/7  Node.js 20 via nvm"

# Load nvm if it's already installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v nvm &>/dev/null; then
  info "Downloading nvm installer..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash >>"$LOG" 2>&1
  \. "$HOME/.nvm/nvm.sh"
fi

NODE_VERSION=$(node --version 2>/dev/null | grep -oP '(?<=v)\d+' || echo "0")
if [ "$NODE_VERSION" -lt 20 ]; then
  info "Installing Node.js 20 LTS (pre-built ARM binary — no compilation needed)..."
  nvm install 20 >>"$LOG" 2>&1
  nvm use 20 >>"$LOG" 2>&1
  nvm alias default 20 >>"$LOG" 2>&1
fi

# Make node/npm available in this shell session from nvm
\. "$HOME/.nvm/nvm.sh"
info "Node: $(node --version)   npm: $(npm --version)"

# ─────────────────────────────────────────────────────────────────────────────
# 3. Docker  (static binary — no apt required)
# ─────────────────────────────────────────────────────────────────────────────
step "3/7  Docker"
DOCKER_OK=false
DOCKER_CMD="docker"

if command -v docker &>/dev/null; then
  info "Docker already installed: $(docker --version)"
  DOCKER_OK=true
  sudo systemctl enable docker >>"$LOG" 2>&1 || true
  sudo systemctl start docker >>"$LOG" 2>&1 || true
fi

if [ "$DOCKER_OK" = false ]; then
  if [ "$ARCH" = "aarch64" ]; then
    DOCKER_VER="29.4.0"
    DOCKER_URL="https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VER}.tgz"
    info "Downloading Docker ${DOCKER_VER} static binary for aarch64..."
    curl -fsSL "$DOCKER_URL" -o /tmp/docker.tgz 2>&1 | tee -a "$LOG"
    tar xzf /tmp/docker.tgz -C /tmp >>"$LOG" 2>&1
    sudo cp /tmp/docker/* /usr/local/bin/ >>"$LOG" 2>&1
    rm -rf /tmp/docker /tmp/docker.tgz

    # Create the dockerd systemd unit (no apt, manually written)
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{ "storage-driver": "overlay2" }
EOF

    sudo tee /etc/systemd/system/docker.service >/dev/null <<EOF
[Unit]
Description=Docker Engine (static binary)
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable docker >>"$LOG" 2>&1
    sudo systemctl start docker >>"$LOG" 2>&1
    sleep 3
    DOCKER_OK=true
    info "Docker installed: $(docker --version)"

  elif [ "$ARCH" = "armv7l" ]; then
    # ⚠️  The official Docker static armhf bundle ships a 64-bit dockerd
    # inside, which won't execute on a 32-bit kernel. We fall through to
    # the native-postgres path below instead of failing loudly.
    warn "32-bit OS (armv7l): Docker static binary won't work here."
    warn "Checking for a natively-installed Postgres instead..."
    DOCKER_OK=false
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4. PostgreSQL
#    Priority: Docker container → native postgres already on the Pi
# ─────────────────────────────────────────────────────────────────────────────
step "4/7  PostgreSQL"
DB_URL="postgres://postgres:postgres@localhost:5433/carecircle"

if [ "$DOCKER_OK" = true ] && sudo docker info &>/dev/null 2>&1; then
  info "Starting PostgreSQL 16 in Docker..."

  # Use plain 'docker run' — avoids needing docker-compose or any plugin
  if ! sudo docker ps -a --format '{{.Names}}' | grep -q "^carecircle-db$"; then
    sudo docker run -d \
      --name carecircle-db \
      --restart always \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=postgres \
      -e POSTGRES_DB=carecircle \
      -p 5433:5432 \
      -v carecircle-pgdata:/var/lib/postgresql/data \
      postgres:16-alpine >>"$LOG" 2>&1
  else
    sudo docker start carecircle-db >>"$LOG" 2>&1 || true
  fi

  info "Waiting for PostgreSQL to accept connections..."
  RETRIES=24
  until sudo docker exec carecircle-db pg_isready -U postgres -q 2>/dev/null; do
    RETRIES=$((RETRIES - 1))
    [ "$RETRIES" -le 0 ] && die "PostgreSQL container never became ready. Check: sudo docker logs carecircle-db"
    echo -n "."
    sleep 3
  done
  echo " ready!"

else
  # ── Fallback: native postgres ─────────────────────────────────────────────
  if command -v pg_isready &>/dev/null || command -v psql &>/dev/null; then
    warn "No Docker — using native PostgreSQL already on this Pi."

    # Determine the postgres socket / port
    PG_PORT=$(pg_lsclusters 2>/dev/null | awk 'NR>1{print $3; exit}' || echo "5432")
    PG_HOST="localhost"

    # Create the database and user if they don't exist
    sudo -u postgres psql -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE carecircle OWNER postgres;" 2>/dev/null || true

    # Rewrite .env to match the native port
    DB_URL="postgres://postgres:postgres@${PG_HOST}:${PG_PORT}/carecircle"
    info "Native Postgres running on port $PG_PORT"
  else
    die "Neither Docker nor a native PostgreSQL was found on this Pi.

  Options to unblock:
  a) Flash a 64-bit OS (e.g. Raspberry Pi OS Lite 64-bit) — Docker will then
     work via the static binary this script installs.
  b) Install postgres from a portable binary:
       https://www.enterprisedb.com/download-postgresql-binaries
     then re-run this script (it will detect postgres automatically).
  c) Run PostgreSQL on another machine on the same network and point
     the .env DATABASE_URL at it (then re-run this script)."
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. Backend — install, migrate, seed
# ─────────────────────────────────────────────────────────────────────────────
step "5/7  Backend setup"
cd "$BACKEND_DIR"

# Write / patch .env
cat >.env <<EOF
DATABASE_URL=${DB_URL}
JWT_SECRET=supersecretkeychangeinproduction
JWT_REFRESH_SECRET=supersecretrefreshkeychangeinproduction
PORT=3001
HOST=0.0.0.0
NODE_ENV=production
EOF
info ".env written."

npm install >>"$LOG" 2>&1
info "npm install done"

npm run db:migrate >>"$LOG" 2>&1
info "Migrations applied"

npm run db:seed >>"$LOG" 2>&1
info "Database seeded (Eleanor Hayes, Maria, David, medications, routines)"

# ─────────────────────────────────────────────────────────────────────────────
# 6. Frontend — build with Node.js SSR target
# ─────────────────────────────────────────────────────────────────────────────
step "6/7  Building frontend (may take 3-8 min on Pi 3)"
cd "$PROJECT_DIR"
npm install >>"$LOG" 2>&1

# NITRO_PRESET=node → bundle for Node.js, not Cloudflare Workers (the default)
# NODE_OPTIONS cap → prevent OOM on 1 GB RAM
export NITRO_PRESET="node"
export NODE_OPTIONS="--max-old-space-size=768"
npm run build >>"$LOG" 2>&1
info "Frontend build complete. SSR server at .output/server/index.mjs"

# ─────────────────────────────────────────────────────────────────────────────
# 7. systemd services — auto-start everything on boot
# ─────────────────────────────────────────────────────────────────────────────
step "7/7  Installing systemd services"

NODE_BIN=$(which node)
NPX_BIN=$(which npx)

# 7a. PostgreSQL container auto-start (if Docker is in use)
if [ "$DOCKER_OK" = true ]; then
  sudo tee /etc/systemd/system/carecircle-db.service >/dev/null <<EOF
[Unit]
Description=CareCircle — PostgreSQL container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=sudo docker start carecircle-db
ExecStop=sudo docker stop carecircle-db
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl enable carecircle-db >>"$LOG" 2>&1
fi

# 7b. Backend (Fastify)
sudo tee /etc/systemd/system/carecircle-backend.service >/dev/null <<EOF
[Unit]
Description=CareCircle — Fastify Backend API
After=network.target carecircle-db.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$BACKEND_DIR
Environment=NODE_ENV=production
ExecStart=$NODE_BIN $NPX_BIN tsx src/server.ts
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# 7c. Frontend SSR (Nitro / Node.js)
FRONTEND_SERVER="$PROJECT_DIR/.output/server/index.mjs"
sudo tee /etc/systemd/system/carecircle-frontend.service >/dev/null <<EOF
[Unit]
Description=CareCircle — TanStack Start SSR Frontend
After=network.target carecircle-backend.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment=NODE_ENV=production
Environment=PORT=3000
ExecStart=$NODE_BIN $FRONTEND_SERVER
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable carecircle-backend >>"$LOG" 2>&1
sudo systemctl enable carecircle-frontend >>"$LOG" 2>&1

# Start services now
[ "$DOCKER_OK" = true ] && {
  sudo systemctl start carecircle-db
  sleep 4
}
sudo systemctl start carecircle-backend
sleep 3
sudo systemctl start carecircle-frontend

# ─────────────────────────────────────────────────────────────────────────────
# Done!
# ─────────────────────────────────────────────────────────────────────────────
PI_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "============================================================"
echo -e "${GREEN} ✓ Setup complete!${NC}"
echo "============================================================"
echo ""
echo "  PostgreSQL  → port 5433"
echo "  Backend API → http://${PI_IP}:3001   (/health to verify)"
echo "  Frontend    → http://${PI_IP}:3000"
echo ""
echo "  Seed credentials:"
echo "    maria@carecircle.app  /  password123"
echo "    david@carecircle.app  /  password123"
echo ""
echo "  Service commands:"
echo "    sudo systemctl status  carecircle-backend"
echo "    sudo systemctl status  carecircle-frontend"
echo "    sudo journalctl -u carecircle-backend  -f"
echo "    sudo journalctl -u carecircle-frontend -f"
echo ""
echo "  Full setup log: $LOG"
echo ""
echo "  NOTE: nvm was added to your shell profile."
echo "  Run  [ source ~/.bashrc ]  or open a new terminal to"
echo "  use 'node' and 'npm' directly without the script."
echo ""
