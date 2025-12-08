# Canary Server Configuration Documentation

This document provides comprehensive documentation for configuring the Canary server, with emphasis on internationalization settings and client compatibility.

## Table of Contents

1. [Configuration Overview](#configuration-overview)
2. [Core Settings](#core-settings)
3. [Network Configuration](#network-configuration)
4. [Database Configuration](#database-configuration)
5. [Game Settings](#game-settings)
6. [I18N Configuration](#i18n-configuration)
7. [Performance Tuning](#performance-tuning)
8. [Security Settings](#security-settings)

---

## Configuration Overview

The main configuration file is `config.lua.dist`. Copy it to `config.lua` before starting the server.

### Configuration File Location
```
canary/
├── config.lua.dist    # Template configuration
├── config.lua         # Active configuration (create from .dist)
└── key.pem            # RSA key for encryption
```

---

## Core Settings

### Server Information

```lua
-- Server name displayed to clients
serverName = "Canary"

-- Owner information
ownerName = "Server Owner"
ownerEmail = "owner@example.com"

-- Server URL
url = "https://yourserver.com"

-- Server location
location = "Europe"
```

### World Configuration

```lua
-- World type affects PvP rules
-- Options: "pvp", "no-pvp", "pvp-enforced"
worldType = "pvp"

-- World name
worldName = "Main"

-- IP and port settings
ip = "127.0.0.1"
loginProtocolPort = 7171
gameProtocolPort = 7172
statusProtocolPort = 7171
```

---

## Network Configuration

### Connection Settings

```lua
-- Maximum players online
maxPlayers = 1000

-- Connection retry delay (milliseconds)
retryDelay = 2000

-- Free premium status for all players
freePremium = false

-- Login message
motd = "Welcome to Canary Server!"

-- One character per account online
onePlayerOnlinePerAccount = true
```

### Protocol Settings

```lua
-- Client version
clientVersionMin = 1300
clientVersionMax = 1320
clientVersionStr = "13.20"

-- RSA key for protocol encryption
RSAKey = [[
-----BEGIN RSA KEY-----
...
-----END RSA KEY-----
]]
```

---

## Database Configuration

### MySQL/MariaDB

```lua
-- Database connection
mysqlHost = "127.0.0.1"
mysqlUser = "canary"
mysqlPass = "password"
mysqlDatabase = "canary"
mysqlPort = 3306
mysqlSock = ""

-- Connection pool
mysqlMaxConnections = 10
```

### Database Schema

The database must be initialized using `schema.sql`:

```bash
mysql -u canary -p canary < schema.sql
```

---

## Game Settings

### Experience and Rates

```lua
-- Experience rate multiplier
rateExperience = 1.0
rateSkill = 1.0
rateLoot = 1.0
rateMagic = 1.0
rateSpawn = 1.0

-- Party bonus
rateExperienceParty = 1.5

-- Stamina settings
staminaSystem = true
rateStaminaLoss = 1.0
rateStaminaGain = 3.0

-- Experience stages (in stages.lua)
useStages = true
```

### Combat Settings

```lua
-- PvP settings
worldType = "pvp"
hotkeyAimbotEnabled = true
protectionLevel = 1
killsToRedSkull = 3
killsToBlackSkull = 6

-- Death penalties
deathLosePercent = 10.0
```

### House Settings

```lua
-- House rent period: "never", "daily", "weekly", "monthly", "yearly"
houseRentPeriod = "weekly"

-- House price per square meter
housePriceEachSQM = 1000

-- Require premium for house ownership
housePremiumNeeded = true
```

---

## I18N Configuration

### Overview

Canary server sends messages in a base language. The OTClient handles translation based on the user's selected locale.
Set the server fallback using `serverDefaultLocale` in `config.lua`; this value seeds new players and is used whenever a client did not send a locale preference.

### Server-Side Messages

Server messages are defined in Lua scripts. Keep them simple for easy translation:

```lua
-- In scripts/
player:sendTextMessage(MESSAGE_INFO_DESCR, "You gained experience!")
```

### Client Integration

The testyy (OTClient) handles translation through its locale system:

1. **Locale files** in `data/locales/` contain translations
2. **tr() function** wraps translatable strings
3. **neededtranslations.lua** catalogs all strings

### Supported Languages (53)

The client supports these language codes:

| Code | Language | Region |
|------|----------|--------|
| en | English | Base |
| de | German | Western Europe |
| es | Spanish | Western Europe |
| fr | French | Western Europe |
| it | Italian | Western Europe |
| pt | Portuguese | Western Europe |
| pl | Polish | Eastern Europe |
| ru | Russian | Slavic |
| zh | Chinese | Asia |
| ja | Japanese | Asia |
| ko | Korean | Asia |
| ar | Arabic (RTL) | Middle East |
| he | Hebrew (RTL) | Middle East |
| tr | Turkish | Middle East |
| ... | ... | ... |

See `testyy/data/locales/` for all 53 locale files.

### Adding Server Messages

When adding new server messages, follow these guidelines:

1. **Use simple, clear English**
```lua
-- Good
"You need more gold coins."
-- Avoid
"Insufficient funds for transaction."
```

2. **Avoid concatenation with variables in the middle**
```lua
-- Good
local msg = string.format("You gained %d gold coins.", amount)
-- Avoid
local msg = "You gained " .. amount .. " gold coins."
```

3. **Keep terms consistent**
```lua
-- Always use same terms
"Gold Coins"       -- not "gold", "money", "gp"
"Experience"       -- not "XP", "exp"
"Health Points"    -- not "HP", "health"
```

---

## Performance Tuning

### Thread Settings

```lua
-- Dispatcher threads
dispatcherThreads = 2

-- Database threads
databaseThreads = 2

-- Map threads
mapThreads = 1
```

### Cache Settings

```lua
-- Cache creature names
cacheCreatureNames = true

-- Cache items
cacheItems = true

-- Map cache
mapCacheDepth = 12
```

### Memory Settings

```lua
-- Garbage collection settings (in Lua)
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 200)
```

### View Distance

```lua
-- Maximum view distance
mapViewportX = 8
mapViewportY = 6
```

---

## Security Settings

### Account Security

```lua
-- Account manager
accountManager = false

-- Password type: "plain", "sha1", "sha256", "sha512"
passwordType = "sha1"

-- Minimum password length
minPasswordLength = 6

-- Maximum login attempts
maxLoginAttempts = 10
loginAttemptsResetTime = 300 -- seconds
```

### Anti-Cheat

```lua
-- Check client version
checkProtocolVersion = true

-- Anti-bot measures
antiBotEnabled = true

-- Movement validation
validateMovement = true
```

### Rate Limiting

```lua
-- Actions per second limit
actionsPerSecond = 20

-- Messages per second limit
messagesPerSecond = 4

-- Auto-kick for abuse
kickOnAbuse = true
```

---

## Environment Variables

Configuration can also be set via environment variables:

```bash
export CANARY_DB_HOST=localhost
export CANARY_DB_USER=canary
export CANARY_DB_PASS=secret
export CANARY_DB_NAME=canary
```

---

## Docker Configuration

For Docker deployment, use the provided docker-compose.yml:

```yaml
version: '3.8'
services:
  canary:
    build: .
    ports:
      - "7171:7171"
      - "7172:7172"
    environment:
      - CANARY_DB_HOST=db
    depends_on:
      - db
  
  db:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=canary
```

---

## Troubleshooting

### Common Issues

1. **Client version mismatch**
   - Check `clientVersionMin` and `clientVersionMax`
   - Ensure client DAT/SPR files match

2. **Database connection failed**
   - Verify MySQL credentials
   - Check MySQL service is running
   - Ensure database exists

3. **RSA key error**
   - Generate new key: `openssl genrsa -out key.pem 1024`
   - Ensure key matches client key

4. **Port already in use**
   - Check for other processes: `lsof -i :7171`
   - Change port in configuration

---

## Version Information

- **Canary Version**: Latest
- **Supported Protocols**: 12.x - 13.x
- **Database**: MySQL 5.7+ / MariaDB 10.3+
- **Languages**: 53 supported in client

---

*This documentation is part of the Canary Server I18N initiative.*
