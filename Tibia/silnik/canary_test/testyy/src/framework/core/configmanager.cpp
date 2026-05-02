/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "configmanager.h"

#include <cstdlib>
#include <string_view>

ConfigManager g_configs;

namespace
{
bool envFlagEnabled(const char* name)
{
    if (const char* value = std::getenv(name)) {
        const std::string_view raw{ value };
        return raw == "1" || raw == "true" || raw == "TRUE" || raw == "yes" || raw == "YES";
    }

    return false;
}

std::string envString(const char* name)
{
    if (const char* value = std::getenv(name)) {
        return value;
    }

    return {};
}
}

void ConfigManager::init()
{
    m_settings = std::make_shared<Config>();
    loadRuntimePolicy();
}

void ConfigManager::terminate()
{
    if (m_settings) {
        // ensure settings are saved
        m_settings->save();

        m_settings->unload();
        m_settings = nullptr;
    }

    for (auto config : m_configs) {
        config->unload();
        config = nullptr;
    }

    m_configs.clear();
}

ConfigPtr ConfigManager::getSettings()
{
    return m_settings;
}

ConfigPtr ConfigManager::get(const std::string& file)
{
    for (const auto& config : m_configs) {
        if (config->getFileName() == file) {
            return config;
        }
    }
    return nullptr;
}

ConfigPtr ConfigManager::loadSettings(const std::string& file)
{
    if (file.empty()) {
        g_logger.error("Must provide a configuration file to load.");
    } else {
        if (m_settings->load(file)) {
            return m_settings;
        }
    }
    return nullptr;
}

ConfigPtr ConfigManager::create(const std::string& file)
{
    auto config = load(file);
    if (!config) {
        config = std::make_shared<Config>();

        config->load(file);
        config->save();

        m_configs.emplace_back(config);
    }
    return config;
}

ConfigPtr ConfigManager::load(const std::string& file)
{
    if (file.empty()) {
        g_logger.error("Must provide a configuration file to load.");
        return nullptr;
    }
    auto config = get(file);
    if (!config) {
        config = std::make_shared<Config>();

        if (config->load(file)) {
            m_configs.emplace_back(config);
        } else {
            // cannot load config
            config = nullptr;
        }
    }
    return config;
}

bool ConfigManager::unload(const std::string& file)
{
    if (auto config = get(file)) {
        config->unload();
        remove(config);
        config = nullptr;
        return true;
    }
    return false;
}

void ConfigManager::remove(const ConfigPtr& config) { m_configs.remove(config); }

void ConfigManager::loadRuntimePolicy()
{
#ifdef OTCLIENT_PLAYER_BUILD
    m_devMode = false;
    m_clientLocked = true;
#else
    m_devMode = envFlagEnabled("OTC_DEV_MODE");
    m_clientLocked = !m_devMode;
#endif
    m_startupGameMode = envString("OTC_GAME_MODE");
    initBuiltinGameModes();
}

void ConfigManager::initBuiltinGameModes()
{
    m_gameModes.clear();

    // Classic 7.4
    GameModeConfig classic;
    classic.key = "classic74";
    classic.name = "Classic 7.4";
    classic.description = "Serwer w stylu Tibia 7.4";
    classic.allowedWorldIds = { 0 };
    classic.server.host = "tibia.reddaxe.pl";
    classic.server.port = 443;
    classic.server.protocol = 1412;
    classic.server.httpLogin = true;
    classic.server.httpLoginUrl = "https://tibia.reddaxe.pl/apik/v1/login.php";
    classic.features["hotkeys_items"] = false;
    classic.features["hotkeys_spells"] = true;
    classic.features["quick_loot"] = true;
    classic.features["auto_loot"] = true;
    classic.features["market"] = true;
    classic.features["action_bar"] = true;
    classic.features["smart_equip"] = true;
    classic.features["prey"] = true;
    classic.features["bestiary"] = true;
    classic.features["wheel"] = true;
    classic.features["analytics"] = true;
    m_gameModes["classic74"] = std::move(classic);

    // Modern 14.20+
    GameModeConfig modern;
    modern.key = "modern";
    modern.name = "Modern 14.20+";
    modern.description = "Pelna wersja Tibia";
    modern.allowedWorldIds = { 1 };
    modern.server.host = "tibia.reddaxe.pl";
    modern.server.port = 443;
    modern.server.protocol = 1412;
    modern.server.httpLogin = true;
    modern.server.httpLoginUrl = "https://tibia.reddaxe.pl/apik/v1/login.php";
    modern.features["hotkeys_items"] = true;
    modern.features["hotkeys_spells"] = true;
    modern.features["quick_loot"] = true;
    modern.features["auto_loot"] = true;
    modern.features["market"] = true;
    modern.features["action_bar"] = true;
    modern.features["smart_equip"] = true;
    modern.features["prey"] = true;
    modern.features["bestiary"] = true;
    modern.features["wheel"] = true;
    modern.features["analytics"] = true;
    m_gameModes["modern"] = std::move(modern);
}

int ConfigManager::getGameModeCount() const
{
    return static_cast<int>(m_gameModes.size());
}

std::vector<std::string> ConfigManager::getGameModeKeys() const
{
    std::vector<std::string> keys;
    keys.reserve(m_gameModes.size());
    for (const auto& [k, _] : m_gameModes)
        keys.push_back(k);
    return keys;
}

bool ConfigManager::hasGameMode(const std::string& key) const
{
    return m_gameModes.count(key) > 0;
}

std::string ConfigManager::getGameModeName(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.name : "";
}

std::string ConfigManager::getGameModeDescription(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.description : "";
}

std::string ConfigManager::getGameModeHost(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.server.host : "";
}

int ConfigManager::getGameModePort(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.server.port : 0;
}

int ConfigManager::getGameModeProtocol(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.server.protocol : 0;
}

bool ConfigManager::getGameModeHttpLogin(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.server.httpLogin : false;
}

std::string ConfigManager::getGameModeHttpLoginUrl(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    return it != m_gameModes.end() ? it->second.server.httpLoginUrl : "";
}

bool ConfigManager::getGameModeFeature(const std::string& key, const std::string& feature) const
{
    auto modeIt = m_gameModes.find(key);
    if (modeIt == m_gameModes.end())
        return false;
    auto featIt = modeIt->second.features.find(feature);
    return featIt != modeIt->second.features.end() ? featIt->second : false;
}

std::string ConfigManager::getGameModeAllowedWorldIds(const std::string& key) const
{
    auto it = m_gameModes.find(key);
    if (it == m_gameModes.end())
        return "";
    std::string result;
    for (size_t i = 0; i < it->second.allowedWorldIds.size(); ++i) {
        if (i > 0) result += ",";
        result += std::to_string(it->second.allowedWorldIds[i]);
    }
    return result;
}
