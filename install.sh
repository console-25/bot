#!/bin/bash

# ============================================================
# StrenoxCloud VPS Bot
# Noryx Licensed Installer
#
# Project: STRENOX-VPS-BOT
# ============================================================

set -euo pipefail


# ------------------------------------------------------------
# COLORS
# ------------------------------------------------------------

RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYN='\033[0;36m'
WHT='\033[1;37m'
NC='\033[0m'
GOLD='\033[38;5;220m'
PURPLE='\033[38;5;141m'
GREEN='\033[38;5;82m'
DGRAY='\033[38;5;244m'
BOLD='\033[1m'
DIM='\033[2m'


# ------------------------------------------------------------
# PATHS / PRODUCT IDENTITY
# ------------------------------------------------------------

APP_DIR="/opt/strenox-vps-bot"

CONFIG_DIR="/etc/strenox-vps-bot"

LICENSE_FILE="$CONFIG_DIR/license.nlm"

ENV_FILE="$CONFIG_DIR/bot.env"

SERVICE_FILE="/etc/systemd/system/bot.service"

NORYX_PROJECT="STRENOX-VPS-BOT"

NORYX_REQUIRED_FEATURES="vps"

BINARY_NAME="strenox-vps-bot-linux-x86_64"
BINARY_URL="https://github.com/console-25/bot/releases/latest/download/strenox-vps-bot-linux-x86_64"

REPO_RAW_BASE="https://raw.githubusercontent.com/console-25/bot/main"

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

NORYX_STAGE=""

NORYX_LICENSE=""


# ------------------------------------------------------------
# DISPLAY
# ------------------------------------------------------------

step() {
    echo -e "${GRN}[+]${NC} $1"
}

warn() {
    echo -e "${YEL}[!]${NC} $1"
}

err() {
    echo -e "${RED}[x]${NC} $1"
}


banner() {
    clear || true

    printf "${GOLD}"
    echo "╭────────────────────────────────────────────────────────────────────╮"
    echo "│                 NORYX LICENSE • PRODUCT GATEWAY                    │"
    echo "╰────────────────────────────────────────────────────────────────────╯"
    printf "${NC}"

    echo
    printf " ${GREEN}●${NC} %-18s ${GREEN}ONLINE${NC}\n" "Noryx Runtime"
    printf " ${PURPLE}◆${NC} %-18s ${WHT}%s${NC}\n" "Protected Product" "$NORYX_PROJECT"
    printf " ${GOLD}▣${NC} %-18s %s\n" "Trust Layer" "Ed25519 / NLM1"

    echo
    echo -e "${DGRAY} Noryx License Machine • Powered by StrenoxCloud • Made by Console${NC}"
    echo
}

# ------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------

cleanup() {
    if [ -n "${NORYX_STAGE:-}" ] && \
       [ -d "$NORYX_STAGE" ]; then

        rm -rf "$NORYX_STAGE"
    fi
}

trap cleanup EXIT


# ------------------------------------------------------------
# ROOT CHECK
# ------------------------------------------------------------

need_root() {
    if [ "$EUID" -ne 0 ]; then
        err "Run this installer as root:"
        echo
        echo "sudo ./install.sh"
        exit 1
    fi
}


# ------------------------------------------------------------
# NORYX PREREQUISITES
# ------------------------------------------------------------

install_license_prereqs() {
    step "Installing Noryx verification prerequisites..."

    apt-get update

    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        python3 \
        python3-cryptography \
        ca-certificates \
        curl
}


# ------------------------------------------------------------
# LOAD PUBLIC VERIFIER
# ------------------------------------------------------------

stage_noryx_bundle() {
    NORYX_STAGE="$(
        mktemp -d
    )"

    mkdir -p \
        "$NORYX_STAGE/noryx/verifier" \
        "$NORYX_STAGE/noryx/keys"

    if [ -f "$SCRIPT_DIR/noryx/verifier/verifier.py" ] && \
       [ -f "$SCRIPT_DIR/noryx/keys/public.pem" ]; then

        step "Using bundled Noryx public verifier..."

        cp -a \
            "$SCRIPT_DIR/noryx/." \
            "$NORYX_STAGE/noryx/"

    else

        step "Downloading Noryx public verifier..."

        curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            "$REPO_RAW_BASE/noryx/verifier/verifier.py" \
            -o "$NORYX_STAGE/noryx/verifier/verifier.py"

        curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            "$REPO_RAW_BASE/noryx/verifier/__init__.py" \
            -o "$NORYX_STAGE/noryx/verifier/__init__.py"

        curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            "$REPO_RAW_BASE/noryx/keys/public.pem" \
            -o "$NORYX_STAGE/noryx/keys/public.pem"

        printf '%s\n' \
            '# Noryx public verifier package' \
            > "$NORYX_STAGE/noryx/__init__.py"
    fi

    if [ ! -f "$NORYX_STAGE/noryx/__init__.py" ]; then

        printf '%s\n' \
            '# Noryx public verifier package' \
            > "$NORYX_STAGE/noryx/__init__.py"
    fi

    if [ ! -s "$NORYX_STAGE/noryx/verifier/verifier.py" ] || \
       [ ! -s "$NORYX_STAGE/noryx/keys/public.pem" ]; then

        err "Noryx verifier bundle is incomplete."
        exit 1
    fi
}


# ------------------------------------------------------------
# NORYX PRODUCT GATEWAY UI
# ------------------------------------------------------------

noryx_license_gate_ui() {

    # Fixed-width Noryx box renderer.
    # Keep ANSI colors outside padded text so terminal alignment stays clean.

    noryx_box_top() {
        printf "${PURPLE}╭"
        printf '─%.0s' {1..68}
        printf "╮${NC}\n"
    }

    noryx_box_separator() {
        printf "${PURPLE}├"
        printf '─%.0s' {1..68}
        printf "┤${NC}\n"
    }

    noryx_box_bottom() {
        printf "${PURPLE}╰"
        printf '─%.0s' {1..68}
        printf "╯${NC}\n"
    }

    noryx_box_empty() {
        printf "${PURPLE}│${NC}"
        printf '%68s' ""
        printf "${PURPLE}│${NC}\n"
    }

    noryx_box_row() {
        local CONTENT="$1"

        # 66 printable characters with one space on each side.
        printf "${PURPLE}│${NC} %-66s ${PURPLE}│${NC}\n" "$CONTENT"
    }


    noryx_box_top
    noryx_box_row "NORYX LICENSE GATE"
    noryx_box_separator

    noryx_box_empty
    noryx_box_row "Product       ${NORYX_PROJECT}"
    noryx_box_row "License       NLM1 signed artifact"
    noryx_box_row "Signature     Ed25519"
    noryx_box_row "Verification  Offline / public key"
    noryx_box_row "Required      ${NORYX_REQUIRED_FEATURES}"
    noryx_box_empty
    noryx_box_row "Your license remains hidden while you type."
    noryx_box_row "The token is never printed back to the terminal."
    noryx_box_empty

    noryx_box_bottom

    echo

    read -rsp \
        "$(echo -e "${GOLD}${BOLD}  License token ❯ ${NC}")" \
        NORYX_LICENSE

    echo
    echo

    if [ -z "$NORYX_LICENSE" ]; then

        echo -e "${RED}╭────────────────────────────────────────────────────────────────────╮${NC}"
        echo -e "${RED}│                                                                    │${NC}"
        echo -e "${RED}│                     ✖ LICENSE REQUIRED                             │${NC}"
        echo -e "${RED}│                                                                    │${NC}"
        echo -e "${RED}╰────────────────────────────────────────────────────────────────────╯${NC}"

        return 1
    fi


    echo -e "${DGRAY}  ┌─ Noryx Trust Verification ─────────────────────────────────────┐${NC}"
    echo -e "${DGRAY}  │${NC}"
    echo -e "${DGRAY}  │${NC}  ◌ Reading NLM1 license artifact"
    sleep 0.12

    echo -e "${DGRAY}  │${NC}  ◌ Loading embedded Noryx public key"
    sleep 0.12

    echo -e "${DGRAY}  │${NC}  ◌ Verifying cryptographic signature"
    sleep 0.12

    echo -e "${DGRAY}  │${NC}  ◌ Checking product entitlement"
    sleep 0.12

    echo -e "${DGRAY}  │${NC}  ◌ Checking expiration and features"
    sleep 0.12

    echo -e "${DGRAY}  │${NC}"
    echo -e "${DGRAY}  └────────────────────────────────────────────────────────────────┘${NC}"

    echo


    NORYX_LICENSE="$NORYX_LICENSE" \
    NORYX_STAGE="$NORYX_STAGE" \
    NORYX_PROJECT="$NORYX_PROJECT" \
    NORYX_REQUIRED_FEATURES="$NORYX_REQUIRED_FEATURES" \
    python3 - <<'PYVERIFY'
import os
import sys

stage = os.environ["NORYX_STAGE"]

sys.path.insert(
    0,
    stage,
)

from noryx.verifier import verify


token = os.environ[
    "NORYX_LICENSE"
].strip()

project = os.environ[
    "NORYX_PROJECT"
]

required = {
    value.strip().lower()
    for value in os.environ.get(
        "NORYX_REQUIRED_FEATURES",
        "",
    ).split(",")
    if value.strip()
}


valid, message, payload = verify(
    token,
    expected_project=project,
)


RESET = "\033[0m"
BOLD = "\033[1m"

GOLD = "\033[38;5;220m"
PURPLE = "\033[38;5;141m"
GREEN = "\033[38;5;82m"
RED = "\033[38;5;203m"
GRAY = "\033[38;5;245m"
WHITE = "\033[97m"


def fail(title, reason):
    print(
        f"{RED}"
        "╭────────────────────────────────────────────────────────────────────╮"
    )

    print(
        f"│  ✖ {title:<63}│"
    )

    print(
        "╰────────────────────────────────────────────────────────────────────╯"
        f"{RESET}"
    )

    print()

    print(
        f" {RED}Reason:{RESET} "
        f"{reason}"
    )


if not valid or not payload:

    fail(
        "NORYX LICENSE REJECTED",
        message,
    )

    raise SystemExit(1)


features = {
    str(value).strip().lower()
    for value in payload.get(
        "features",
        [],
    )
    if str(value).strip()
}


missing = sorted(
    required - features
)


if missing:

    fail(
        "LICENSE ENTITLEMENT MISSING",
        "Missing feature(s): "
        + ", ".join(missing),
    )

    raise SystemExit(1)


print(
    f"{GREEN}"
    "╭────────────────────────────────────────────────────────────────────╮"
)

print(
    "│                                                                    │"
)

print(
    "│                 ✓ TRUST VERIFICATION PASSED                       │"
)

print(
    "│                                                                    │"
)

print(
    "╰────────────────────────────────────────────────────────────────────╯"
    f"{RESET}"
)

print()

checks = [
    "NLM1 artifact format",
    "Ed25519 cryptographic signature",
    f"Product binding: {project}",
    "License expiration",
    "Signed feature entitlements",
]

for check in checks:

    print(
        f" {GREEN}✓{RESET} "
        f"{check}"
    )


print()

print(
    f"{PURPLE}"
    "╭────────────────────────────────────────────────────────────────────╮"
    f"{RESET}"
)

print(
    f"{PURPLE}│{RESET} "
    f"{GOLD}{BOLD}LICENSE ACCEPTED{RESET}"
)

print(
    f"{PURPLE}"
    "├────────────────────────────────────────────────────────────────────┤"
    f"{RESET}"
)


rows = [
    (
        "License ID",
        payload.get(
            "license_id",
            "Unknown",
        ),
    ),
    (
        "Customer",
        payload.get(
            "customer",
            "Unknown",
        ),
    ),
    (
        "Plan",
        payload.get(
            "plan",
            "Unknown",
        ),
    ),
    (
        "Project",
        payload.get(
            "project",
            "Unknown",
        ),
    ),
    (
        "Expires",
        payload.get(
            "expires_at",
            "Unknown",
        ),
    ),
]


for label, value in rows:

    print(
        f"{PURPLE}│{RESET}  "
        f"{GRAY}{label:<12}{RESET}"
        f"{WHITE}{value}{RESET}"
    )


print(
    f"{PURPLE}│{RESET}"
)


features_text = ", ".join(
    payload.get(
        "features",
        [],
    )
)


print(
    f"{PURPLE}│{RESET}  "
    f"{GRAY}{'Features':<12}{RESET}"
    f"{WHITE}{features_text}{RESET}"
)


print(
    f"{PURPLE}"
    "╰────────────────────────────────────────────────────────────────────╯"
    f"{RESET}"
)

print()

print(
    f" {GREEN}{BOLD}● LICENSE STATUS: ACTIVE{RESET}"
)

print(
    f" {GRAY}Noryx cryptographic verification complete.{RESET}"
)

PYVERIFY

    STATUS=$?

    unset NORYX_LICENSE

    echo

    if [ "$STATUS" -eq 0 ]; then

        echo -e "${GREEN}${BOLD}  ✓ ACCESS GRANTED${NC}"
        echo -e "${DGRAY}  Product entitlement confirmed.${NC}"
        echo

        return 0

    else

        echo -e "${RED}${BOLD}  ✖ ACCESS DENIED${NC}"
        echo -e "${DGRAY}  A valid Noryx license is required to continue.${NC}"
        echo

        return "$STATUS"
    fi
}

# ------------------------------------------------------------
# VERIFY LICENSE BEFORE HEAVY INSTALLATION
# ------------------------------------------------------------

verify_noryx_license() {

    if noryx_license_gate_ui; then
        return 0
    fi

    echo -e "${RED}Installation stopped by Noryx License Gate.${NC}"

    exit 1
}

# ------------------------------------------------------------
# OS
# ------------------------------------------------------------

choose_os() {
    echo

    echo -e "${WHT}Select your OS:${NC}"

    echo -e \
        "  ${YEL}1)${NC} Ubuntu"

    echo -e \
        "  ${YEL}2)${NC} Debian"

    read -rp \
        "$(echo -e "${CYN}Enter choice [1-2]: ${NC}")" \
        OS_CHOICE
}


install_lxd_ubuntu() {
    step "Updating system..."

    apt update
    apt upgrade -y

    step "Installing LXC utilities..."

    apt install \
        lxc \
        lxc-utils \
        -y

    step "Installing snapd..."

    apt install \
        snapd \
        -y

    systemctl enable \
        --now \
        snapd.socket

    step "Installing LXD..."

    snap install lxd

    step "Initializing LXD..."

    lxd init --auto

    step "Installing bridge / uidmap tools..."

    apt install \
        bridge-utils \
        uidmap \
        -y
}


install_lxd_debian() {
    step "Updating system..."

    apt update
    apt upgrade -y

    step "Installing snapd..."

    apt install \
        snapd \
        -y

    systemctl enable \
        --now \
        snapd.socket

    ln -sf \
        /var/lib/snapd/snap \
        /snap

    step "Installing LXD..."

    snap install lxd

    step "Initializing LXD..."

    lxd init --auto
}


# ------------------------------------------------------------
# PYTHON
# ------------------------------------------------------------

install_python_stack() {
    step "Compiled StrenoxCloud runtime selected."
    step "No Python bot dependencies are required."
}

# ------------------------------------------------------------
# DEPLOY PRODUCT
# ------------------------------------------------------------

deploy_bot() {
    step "Deploying compiled StrenoxCloud VPS Bot..."

    mkdir -p \
        "$APP_DIR"

    LOCAL_BINARY="$SCRIPT_DIR/bin/$BINARY_NAME"
    LOCAL_CHECKSUM="$SCRIPT_DIR/bin/$BINARY_NAME.sha256"

    TEMP_BINARY=""
    TEMP_CHECKSUM=""


    if [ -s "$LOCAL_BINARY" ] && \
       [ -s "$LOCAL_CHECKSUM" ]; then

        step "Using bundled compiled application."

        BOT_BINARY="$LOCAL_BINARY"
        CHECKSUM_FILE="$LOCAL_CHECKSUM"

    else

        step "Downloading compiled application from GitHub Releases..."

        TEMP_BINARY="$(mktemp)"
        TEMP_CHECKSUM="$(mktemp)"


        if ! curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            "$BINARY_URL" \
            -o "$TEMP_BINARY"; then

            rm -f \
                "$TEMP_BINARY" \
                "$TEMP_CHECKSUM"

            err "Could not download compiled application."
            exit 1
        fi


        if ! curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            "$BINARY_URL.sha256" \
            -o "$TEMP_CHECKSUM"; then

            rm -f \
                "$TEMP_BINARY" \
                "$TEMP_CHECKSUM"

            err "Could not download release checksum."
            exit 1
        fi


        BOT_BINARY="$TEMP_BINARY"
        CHECKSUM_FILE="$TEMP_CHECKSUM"
    fi


    EXPECTED_HASH="$(
        awk 'NR==1 {print $1}' "$CHECKSUM_FILE"
    )"

    ACTUAL_HASH="$(
        sha256sum "$BOT_BINARY" \
        | awk '{print $1}'
    )"


    if [ -z "$EXPECTED_HASH" ] || \
       [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then

        err "Compiled application checksum verification failed."

        rm -f \
            "$TEMP_BINARY" \
            "$TEMP_CHECKSUM"

        exit 1
    fi


    step "Compiled release checksum verified."


    install \
        -m 0755 \
        "$BOT_BINARY" \
        "$APP_DIR/strenox-vps-bot"


    rm -f \
        "$TEMP_BINARY" \
        "$TEMP_CHECKSUM"


    step "Compiled bot installed."
}

# ------------------------------------------------------------
# PRODUCT CONFIGURATION
# ------------------------------------------------------------

configure_env() {
    echo
    echo -e "${WHT}────────── Bot Configuration ──────────${NC}"

    read -rsp \
        "$(echo -e "${CYN}Discord Bot Token: ${NC}")" \
        DISCORD_TOKEN

    echo

    read -rp \
        "$(echo -e "${CYN}Main Admin Discord ID: ${NC}")" \
        MAIN_ADMIN_ID

    if [ -z "$DISCORD_TOKEN" ] || \
       [ -z "$MAIN_ADMIN_ID" ]; then

        err \
            "Discord token and Admin ID cannot be empty."

        exit 1
    fi

    mkdir -p \
        "$CONFIG_DIR"

    chmod \
        0700 \
        "$CONFIG_DIR"


    # Signed license token.
    printf \
        '%s\n' \
        "$NORYX_LICENSE" \
        > "$LICENSE_FILE"

    chmod \
        0600 \
        "$LICENSE_FILE"


    # Runtime secrets/config.
    cat > "$ENV_FILE" <<EOF_ENV
DISCORD_TOKEN=$DISCORD_TOKEN
MAIN_ADMIN_ID=$MAIN_ADMIN_ID
BOT_NAME="VPS Bot"
NORYX_LICENSE_FILE=$LICENSE_FILE
NORYX_REQUIRED_FEATURES=$NORYX_REQUIRED_FEATURES
EOF_ENV

    chmod \
        0600 \
        "$ENV_FILE"


    unset DISCORD_TOKEN
    unset NORYX_LICENSE

    step \
        "Protected configuration saved to $CONFIG_DIR"
}


# ------------------------------------------------------------
# VERIFY INSTALLED COPY
# ------------------------------------------------------------

preflight_runtime_license() {
    step "Running installed-license preflight..."

    PYTHONPATH="$APP_DIR" \
    NORYX_LICENSE_FILE="$LICENSE_FILE" \
    NORYX_REQUIRED_FEATURES="$NORYX_REQUIRED_FEATURES" \
    python3 - <<'PY'
import os
from pathlib import Path

from noryx.verifier import verify


token = Path(
    os.environ[
        "NORYX_LICENSE_FILE"
    ]
).read_text(
    encoding="utf-8"
).strip()


valid, message, payload = verify(
    token,
    expected_project="STRENOX-VPS-BOT",
)


if not valid or not payload:
    print(
        message
    )

    raise SystemExit(1)


required = {
    value.strip().lower()
    for value in os.environ.get(
        "NORYX_REQUIRED_FEATURES",
        "",
    ).split(",")
    if value.strip()
}


features = {
    str(value).strip().lower()
    for value in payload.get(
        "features",
        [],
    )
    if str(value).strip()
}


missing = sorted(
    required - features
)


if missing:
    print(
        "Missing feature(s): "
        + ", ".join(missing)
    )

    raise SystemExit(1)


print(
    "✔ Installed Noryx license verified."
)
PY
}


# ------------------------------------------------------------
# SYSTEMD
# ------------------------------------------------------------

create_service() {
    step "Creating systemd service..."

    cat > "$SERVICE_FILE" <<EOF_SERVICE
[Unit]
Description=StrenoxCloud VPS Bot (Noryx Licensed)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_FILE
Environment=PYTHONUNBUFFERED=1
ExecStart=$APP_DIR/strenox-vps-bot
Restart=on-failure
RestartPreventExitStatus=78
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF_SERVICE


    systemctl daemon-reload

    step "Starting bot..."

    systemctl restart bot

    step "Enabling bot on boot..."

    systemctl enable bot
}


# ------------------------------------------------------------
# COMPLETE
# ------------------------------------------------------------

final_message() {
    echo

    echo -e "${WHT}────────────────────────────────────────────────────────────${NC}"

    echo -e \
        "${GRN} Installation complete. Noryx license verified.${NC}"

    echo -e "${WHT}────────────────────────────────────────────────────────────${NC}"

    echo -e \
        " ${CYN}Application:${NC} $APP_DIR"

    echo -e \
        " ${CYN}License:${NC}     $LICENSE_FILE"

    echo -e \
        " ${CYN}Config:${NC}      $ENV_FILE"

    echo -e \
        " ${CYN}Service:${NC}     bot.service"

    echo -e \
        " ${CYN}Status:${NC}      systemctl status bot"

    echo -e \
        " ${CYN}Logs:${NC}        journalctl -u bot -f"

    echo -e \
        " ${CYN}Restart:${NC}     systemctl restart bot"

    echo -e "${WHT}────────────────────────────────────────────────────────────${NC}"

    echo
}



license_test_mode() {

    banner

    echo -e " ${GOLD}${BOLD}SHOWCASE / VALIDATION MODE${NC}"
    echo -e " ${DGRAY}Safe preview only. No packages, services, Discord, LXD, or bot startup.${NC}"
    echo

    stage_noryx_bundle

    if noryx_license_gate_ui; then

        STATUS=0

        echo

        echo -e "${GREEN}"
        echo "╭────────────────────────────────────────────────────────────────────╮"
        echo "│                                                                    │"
        echo "│          ✓ NORYX LICENSE GATE IS FULLY OPERATIONAL                │"
        echo "│                                                                    │"
        echo "╰────────────────────────────────────────────────────────────────────╯"
        echo -e "${NC}"

    else

        STATUS=$?

        echo

        echo -e "${RED}"
        echo "╭────────────────────────────────────────────────────────────────────╮"
        echo "│                                                                    │"
        echo "│               ✖ REQUEST BLOCKED BY NORYX                          │"
        echo "│                                                                    │"
        echo "╰────────────────────────────────────────────────────────────────────╯"
        echo -e "${NC}"

    fi

    unset NORYX_LICENSE

    return "$STATUS"
}

if [ "${1:-}" = "--license-test" ]; then
    license_test_mode
    exit $?
fi

main() {
    banner

    need_root


    # License is checked before LXD/LXC and product installation.
    install_license_prereqs

    stage_noryx_bundle

    verify_noryx_license


    choose_os

    case "$OS_CHOICE" in

        1)
            install_lxd_ubuntu
            ;;

        2)
            install_lxd_debian
            ;;

        *)
            err "Invalid OS choice."
            exit 1
            ;;

    esac


    install_python_stack

    deploy_bot

    configure_env

    preflight_runtime_license

    create_service

    final_message
}


main "$@"
