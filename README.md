# StrenoxCloud VPS Bot

Licensed LXC/LXD VPS management bot protected by **Noryx License Machine**.

## Requirements

Use a supported Linux VPS intended for LXC/LXD operation.

You also need:

- a Discord bot token
- the required Discord administrator information
- a valid Noryx license for `STRENOX-VPS-BOT`
- root access for installation

## Install

Clone the public repository:

```bash
git clone https://github.com/console-25/bot.git
cd bot
```

Make the installer executable:

```bash
chmod +x install.sh
```

Run the installer:

```bash
sudo ./install.sh
```

The installer will guide you through the required configuration.

## Noryx license

During installation you will be prompted for your Noryx license.

Your license is verified for:

- signature authenticity
- product assignment
- expiration
- required feature entitlement

A license issued for another Noryx product will not authorize this bot.

## Test your license first

You can test the Noryx license gate without performing the full installation:

```bash
./install.sh --license-test
```

This is useful when confirming that a newly issued license is valid.

## Runtime protection

Successful installation does not bypass licensing.

The installed compiled bot performs another Noryx license verification before normal startup.

The authorization flow is:

```text
Noryx Installer Gate
        ↓
Product Installation
        ↓
Noryx Runtime Gate
        ↓
StrenoxCloud VPS Bot
```

## Installed files

The application is installed under:

```text
/opt/strenox-vps-bot/
```

Protected configuration and license data are stored under:

```text
/etc/strenox-vps-bot/
```

Do not share your Noryx license token or Discord bot token publicly.

## Integrity

The public release includes a SHA-256 checksum for the compiled Linux executable:

```text
bin/strenox-vps-bot-linux-x86_64.sha256
```

## Source distribution

The production bot is distributed as a compiled Linux executable.

Private application source and Noryx signing keys are not included in the public repository.

## Support

When requesting support, never post:

- Discord bot tokens
- Noryx license tokens
- passwords
- private keys
- environment files

You may safely provide relevant error messages with credentials removed.

---

**Noryx License Machine**  
Powered by StrenoxCloud
