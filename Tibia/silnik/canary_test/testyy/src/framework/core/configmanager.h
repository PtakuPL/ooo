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

#pragma once

#include "config.h"
#include <map>
#include <string>
#include <vector>

struct GameModeServer {
    std::string host;
    int port{ 443 };
    int protocol{ 1412 };
    bool httpLogin{ true };
    std::string httpLoginUrl;
};

struct GameModeConfig {
    std::string key;
    std::string name;
    std::string description;
    std::vector<int> allowedWorldIds;
    GameModeServer server;
    std::map<std::string, bool> features;
};

 // @bindsingleton g_configs
class ConfigManager
{
public:
    void init();
    void terminate();

    bool isDevMode() const { return m_devMode; }
    bool isClientLocked() const { return m_clientLocked; }
    std::string getStartupGameMode() const { return m_startupGameMode; }

    // LUA-003: GameModes — read-only access from Lua
    int getGameModeCount() const;
    std::vector<std::string> getGameModeKeys() const;
    bool hasGameMode(const std::string& key) const;
    std::string getGameModeName(const std::string& key) const;
    std::string getGameModeDescription(const std::string& key) const;
    std::string getGameModeHost(const std::string& key) const;
    int getGameModePort(const std::string& key) const;
    int getGameModeProtocol(const std::string& key) const;
    bool getGameModeHttpLogin(const std::string& key) const;
    std::string getGameModeHttpLoginUrl(const std::string& key) const;
    bool getGameModeFeature(const std::string& key, const std::string& feature) const;
    std::string getGameModeAllowedWorldIds(const std::string& key) const;

    ConfigPtr getSettings();
    ConfigPtr get(const std::string& file);

    ConfigPtr create(const std::string& file);
    ConfigPtr loadSettings(const std::string& file);
    ConfigPtr load(const std::string& file);

    bool unload(const std::string& file);
    void remove(const ConfigPtr& config);

protected:
    ConfigPtr m_settings;
    bool m_devMode{ false };
    bool m_clientLocked{ true };
    std::string m_startupGameMode;
    std::map<std::string, GameModeConfig> m_gameModes;

private:
    void loadRuntimePolicy();
    void initBuiltinGameModes();

    std::list<ConfigPtr> m_configs;
};

extern ConfigManager g_configs;
