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

#include <framework/core/application.h>
#include <framework/core/config.h>
#include <framework/core/configmanager.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/module.h>
#include <framework/core/modulemanager.h>
#include <framework/core/resourcemanager.h>
#include <framework/luaengine/luainterface.h>
#include <framework/platform/platform.h>
#include <framework/proxy/proxy.h>
#include <framework/stdext/net.h>
#include <framework/util/crypt.h>

#ifdef FRAMEWORK_GRAPHICS
#include "framework/graphics/fontmanager.h"
#include "framework/graphics/graphics.h"
#include "framework/graphics/particleeffect.h"
#include "framework/graphics/particlemanager.h"
#include "framework/graphics/shadermanager.h"
#include "framework/graphics/texturemanager.h"
#include "framework/input/mouse.h"
#include "framework/platform/platformwindow.h"
#include "framework/ui/ui.h"
#endif

// Sound includes moved to luafunctions_ui.cpp

#ifdef FRAMEWORK_NET
#include <framework/net/httplogin.h>
#include <framework/net/protocol.h>
#include <framework/net/protocolhttp.h>
#include <framework/net/server.h>
#endif

#include <regex>

// InputMessage/OutputMessage includes moved to luafunctions_ui.cpp

void Application::registerLuaFunctions()
{
    // conversion globals
    g_lua.bindGlobalFunction("torect", [](const std::string_view v) { return stdext::from_string<Rect>(v); });
    g_lua.bindGlobalFunction("topoint", [](const std::string_view v) { return stdext::from_string<Point>(v); });
    g_lua.bindGlobalFunction("tocolor", [](const std::string_view v) { return stdext::from_string<Color>(v); });
    g_lua.bindGlobalFunction("tosize", [](const std::string_view v) { return stdext::from_string<Size>(v); });
    g_lua.bindGlobalFunction("recttostring", [](const Rect& v) { return stdext::to_string(v); });
    g_lua.bindGlobalFunction("pointtostring", [](const Point& v) { return stdext::to_string(v); });
    g_lua.bindGlobalFunction("colortostring", [](const Color& v) { return stdext::to_string(v); });
    g_lua.bindGlobalFunction("sizetostring", [](const Size& v) { return stdext::to_string(v); });
    g_lua.bindGlobalFunction("iptostring", [](const uint32_t v) { return stdext::ip_to_string(v); });
    g_lua.bindGlobalFunction("stringtoip", [](const std::string_view v) { return stdext::string_to_ip(v); });
    g_lua.bindGlobalFunction("listSubnetAddresses", [](const uint32_t a, const uint8_t b) { return stdext::listSubnetAddresses(a, b); });
    g_lua.bindGlobalFunction("ucwords", [](std::string s) { return stdext::ucwords(s); });
    g_lua.bindGlobalFunction("regexMatch", [](std::string s, const std::string& exp) {
        int limit = 10000;
        std::vector<std::vector<std::string>> ret;
        if (s.empty() || exp.empty())
            return ret;
        try {
            std::smatch m;
            const std::regex e(exp, std::regex::ECMAScript);
            while (std::regex_search(s, m, e)) {
                ret.emplace_back();
                for (auto x : m)
                    ret[ret.size() - 1].push_back(x);
                s = m.suffix().str();
                if (--limit == 0)
                    return ret;
            }
        } catch (...) {
        }
        return ret;
    });

    // Platform
    g_lua.registerSingletonClass("g_platform");
    g_lua.bindSingletonFunction("g_platform", "spawnProcess", &Platform::spawnProcess, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getProcessId", &Platform::getProcessId, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "isProcessRunning", &Platform::isProcessRunning, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "copyFile", &Platform::copyFile, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "fileExists", &Platform::fileExists, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "removeFile", &Platform::removeFile, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "killProcess", &Platform::killProcess, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getTempPath", &Platform::getTempPath, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "openUrl", &Platform::openUrl, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getCPUName", &Platform::getCPUName, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getTotalSystemMemory", &Platform::getTotalSystemMemory, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getOSName", &Platform::getOSName, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getFileModificationTime", &Platform::getFileModificationTime, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getDevice", &Platform::getDevice, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getDeviceShortName", &Platform::getDeviceShortName, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "getOsShortName", &Platform::getOsShortName, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "isDesktop", &Platform::isDesktop, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "isMobile", &Platform::isMobile, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "isBrowser", &Platform::isBrowser, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "isConsole", &Platform::isConsole, &g_platform);
    g_lua.bindSingletonFunction("g_platform", "openDir", &Platform::openDir, &g_platform);

    // Application
    g_lua.registerSingletonClass("g_app");
    g_lua.bindSingletonFunction("g_app", "setName", &Application::setName, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "setCompactName", &Application::setCompactName, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "setOrganizationName", &Application::setOrganizationName, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "isRunning", &Application::isRunning, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "isStopping", &Application::isStopping, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getName", &Application::getName, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getCompactName", &Application::getCompactName, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getVersion", &Application::getVersion, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildCompiler", &Application::getBuildCompiler, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildDate", &Application::getBuildDate, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildRevision", &Application::getBuildRevision, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildCommit", &Application::getBuildCommit, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildType", &Application::getBuildType, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getBuildArch", &Application::getBuildArch, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getOs", &Application::getOs, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "getStartupOptions", &Application::getStartupOptions, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "exit", &Application::exit, static_cast<Application*>(&g_app));
    g_lua.bindSingletonFunction("g_app", "restart", &Application::restart, static_cast<Application*>(&g_app));

    // Crypt
    g_lua.registerSingletonClass("g_crypt");
    g_lua.bindSingletonFunction("g_crypt", "genUUID", &Crypt::genUUID, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "setMachineUUID", &Crypt::setMachineUUID, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "getMachineUUID", &Crypt::getMachineUUID, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "encrypt", &Crypt::encrypt, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "decrypt", &Crypt::decrypt, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "rsaSetPublicKey", &Crypt::rsaSetPublicKey, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "rsaSetPrivateKey", &Crypt::rsaSetPrivateKey, &g_crypt);
    g_lua.bindSingletonFunction("g_crypt", "rsaGetSize", &Crypt::rsaGetSize, &g_crypt);

    // Clock
    g_lua.registerSingletonClass("g_clock");
    g_lua.bindSingletonFunction("g_clock", "micros", &Clock::micros, &g_clock);
    g_lua.bindSingletonFunction("g_clock", "millis", &Clock::millis, &g_clock);
    g_lua.bindSingletonFunction("g_clock", "seconds", &Clock::seconds, &g_clock);
    g_lua.bindSingletonFunction("g_clock", "realMillis", &Clock::realMillis, &g_clock);
    g_lua.bindSingletonFunction("g_clock", "realMicros", &Clock::realMicros, &g_clock);

    // ConfigManager
    g_lua.registerSingletonClass("g_configs");
    g_lua.bindSingletonFunction("g_configs", "getSettings", &ConfigManager::getSettings, &g_configs);
    g_lua.bindSingletonFunction("g_configs", "get", &ConfigManager::get, &g_configs);
    g_lua.bindSingletonFunction("g_configs", "loadSettings", &ConfigManager::loadSettings, &g_configs);
    g_lua.bindSingletonFunction("g_configs", "load", &ConfigManager::load, &g_configs);
    g_lua.bindSingletonFunction("g_configs", "unload", &ConfigManager::unload, &g_configs);
    g_lua.bindSingletonFunction("g_configs", "create", &ConfigManager::create, &g_configs);

    // Logger
    g_lua.registerSingletonClass("g_logger");
    g_lua.bindSingletonFunction("g_logger", "log", static_cast<void(Logger::*)(Fw::LogLevel, const std::string_view)>(&Logger::log), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "fireOldMessages", &Logger::fireOldMessages, &g_logger);
    g_lua.bindSingletonFunction("g_logger", "setLogFile", &Logger::setLogFile, &g_logger);
    g_lua.bindSingletonFunction("g_logger", "setOnLog", &Logger::setOnLog, &g_logger);
    g_lua.bindSingletonFunction("g_logger", "debug", static_cast<void(Logger::*)(const std::string_view)>(&Logger::debug), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "info", static_cast<void(Logger::*)(const std::string_view)>(&Logger::info), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "warning", static_cast<void(Logger::*)(const std::string_view)>(&Logger::warning), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "error", static_cast<void(Logger::*)(const std::string_view)>(&Logger::error), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "fatal", static_cast<void(Logger::*)(const std::string_view)>(&Logger::fatal), &g_logger);
    g_lua.bindSingletonFunction("g_logger", "setLevel", &Logger::setLevel, &g_logger);
    g_lua.bindSingletonFunction("g_logger", "getLevel", &Logger::getLevel, &g_logger);

    // Login Http
    g_lua.registerClass<LoginHttp>();
    g_lua.bindClassStaticFunction<LoginHttp>("create", [] { return std::make_shared<LoginHttp>(); });
    g_lua.bindClassMemberFunction<LoginHttp>("httpLogin", &LoginHttp::httpLogin);

    // Http
    g_lua.registerSingletonClass("g_http");
    g_lua.bindSingletonFunction("g_http", "setUserAgent", &Http::setUserAgent, &g_http);
    g_lua.bindSingletonFunction("g_http", "setEnableTimeOutOnReadWrite", &Http::setEnableTimeOutOnReadWrite, &g_http);
    g_lua.bindSingletonFunction("g_http", "addCustomHeader", &Http::addCustomHeader, &g_http);
    g_lua.bindSingletonFunction("g_http", "get", &Http::get, &g_http);
    g_lua.bindSingletonFunction("g_http", "post", &Http::post, &g_http);
    g_lua.bindSingletonFunction("g_http", "download", &Http::download, &g_http);
    g_lua.bindSingletonFunction("g_http", "ws", &Http::ws, &g_http);
    g_lua.bindSingletonFunction("g_http", "wsSend", &Http::wsSend, &g_http);
    g_lua.bindSingletonFunction("g_http", "wsClose", &Http::wsClose, &g_http);
    g_lua.bindSingletonFunction("g_http", "cancel", &Http::cancel, &g_http);

    // ModuleManager
    g_lua.registerSingletonClass("g_modules");
    g_lua.bindSingletonFunction("g_modules", "discoverModules", &ModuleManager::discoverModules, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "autoLoadModules", &ModuleManager::autoLoadModules, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "discoverModule", &ModuleManager::discoverModule, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "ensureModuleLoaded", &ModuleManager::ensureModuleLoaded, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "unloadModules", &ModuleManager::unloadModules, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "reloadModules", &ModuleManager::reloadModules, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "getModule", &ModuleManager::getModule, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "getModules", &ModuleManager::getModules, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "getCurrentModule", &ModuleManager::getCurrentModule, &g_modules);
    g_lua.bindSingletonFunction("g_modules", "enableAutoReload", &ModuleManager::enableAutoReload, &g_modules);

    // EventDispatcher
    g_lua.registerSingletonClass("g_dispatcher");
    g_lua.bindSingletonFunction("g_dispatcher", "addEvent", &EventDispatcher::addEvent, &g_dispatcher);
    g_lua.bindSingletonFunction("g_dispatcher", "scheduleEvent", &EventDispatcher::scheduleEvent, &g_dispatcher);
    g_lua.bindSingletonFunction("g_dispatcher", "cycleEvent", &EventDispatcher::cycleEvent, &g_dispatcher);

    // ResourceManager
    g_lua.registerSingletonClass("g_resources");
    g_lua.bindSingletonFunction("g_resources", "addSearchPath", &ResourceManager::addSearchPath, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "setupUserWriteDir", &ResourceManager::setupUserWriteDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "setWriteDir", &ResourceManager::setWriteDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "searchAndAddPackages", &ResourceManager::searchAndAddPackages, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "removeSearchPath", &ResourceManager::removeSearchPath, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "fileExists", &ResourceManager::fileExists, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "directoryExists", &ResourceManager::directoryExists, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getRealDir", &ResourceManager::getRealDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getWorkDir", &ResourceManager::getWorkDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getUserDir", &ResourceManager::getUserDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getWriteDir", &ResourceManager::getWriteDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getSearchPaths", &ResourceManager::getSearchPaths, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getRealPath", &ResourceManager::getRealPath, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "listDirectoryFiles", &ResourceManager::listDirectoryFiles, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getDirectoryFiles", &ResourceManager::getDirectoryFiles, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "readFileContents", &ResourceManager::readFileContents, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "writeFileContents", &ResourceManager::writeFileContents, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "guessFilePath", &ResourceManager::guessFilePath, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "isFileType", &ResourceManager::isFileType, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getFileName", &ResourceManager::getFileName, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "getFileTime", &ResourceManager::getFileTime, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "makeDir", &ResourceManager::makeDir, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "deleteFile", &ResourceManager::deleteFile, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "resolvePath", &ResourceManager::resolvePath, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "fileChecksum", &ResourceManager::fileChecksum, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "filesChecksums", &ResourceManager::filesChecksums, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "selfChecksum", &ResourceManager::selfChecksum, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "updateFiles", &ResourceManager::updateFiles, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "updateExecutable", &ResourceManager::updateExecutable, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "createArchive", &ResourceManager::createArchive, &g_resources);
    g_lua.bindSingletonFunction("g_resources", "decompressArchive", &ResourceManager::decompressArchive, &g_resources);

    // OTCv8 proxy system
    g_lua.registerSingletonClass("g_proxy");
    g_lua.bindSingletonFunction("g_proxy", "addProxy", &ProxyManager::addProxy, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "removeProxy", &ProxyManager::removeProxy, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "clear", &ProxyManager::clear, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "setMaxActiveProxies", &ProxyManager::setMaxActiveProxies, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "getProxies", &ProxyManager::getProxies, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "getProxiesDebugInfo", &ProxyManager::getProxiesDebugInfo, &g_proxy);
    g_lua.bindSingletonFunction("g_proxy", "getPing", &ProxyManager::getPing, &g_proxy);

    // Config
    g_lua.registerClass<Config>();
    g_lua.bindClassMemberFunction<Config>("save", &Config::save);
    g_lua.bindClassMemberFunction<Config>("setValue", &Config::setValue);
    g_lua.bindClassMemberFunction<Config>("setList", &Config::setList);
    g_lua.bindClassMemberFunction<Config>("getValue", &Config::getValue);
    g_lua.bindClassMemberFunction<Config>("getList", &Config::getList);
    g_lua.bindClassMemberFunction<Config>("exists", &Config::exists);
    g_lua.bindClassMemberFunction<Config>("remove", &Config::remove);
    g_lua.bindClassMemberFunction<Config>("setNode", &Config::setNode);
    g_lua.bindClassMemberFunction<Config>("getNode", &Config::getNode);
    g_lua.bindClassMemberFunction<Config>("getNodeSize", &Config::getNodeSize);
    g_lua.bindClassMemberFunction<Config>("getOrCreateNode", &Config::getOrCreateNode);
    g_lua.bindClassMemberFunction<Config>("mergeNode", &Config::mergeNode);
    g_lua.bindClassMemberFunction<Config>("getFileName", &Config::getFileName);
    g_lua.bindClassMemberFunction<Config>("clear", &Config::clear);

    // Module
    g_lua.registerClass<Module>();
    g_lua.bindClassMemberFunction<Module>("load", &Module::load);
    g_lua.bindClassMemberFunction<Module>("unload", &Module::unload);
    g_lua.bindClassMemberFunction<Module>("reload", &Module::reload);
    g_lua.bindClassMemberFunction<Module>("canReload", &Module::canReload);
    g_lua.bindClassMemberFunction<Module>("canUnload", &Module::canUnload);
    g_lua.bindClassMemberFunction<Module>("isLoaded", &Module::isLoaded);
    g_lua.bindClassMemberFunction<Module>("isReloadble", &Module::isReloadable);
    g_lua.bindClassMemberFunction<Module>("isSandboxed", &Module::isSandboxed);
    g_lua.bindClassMemberFunction<Module>("getDescription", &Module::getDescription);
    g_lua.bindClassMemberFunction<Module>("getName", &Module::getName);
    g_lua.bindClassMemberFunction<Module>("getAuthor", &Module::getAuthor);
    g_lua.bindClassMemberFunction<Module>("getWebsite", &Module::getWebsite);
    g_lua.bindClassMemberFunction<Module>("getVersion", &Module::getVersion);
    g_lua.bindClassMemberFunction<Module>("getSandbox", &Module::getSandbox);
    g_lua.bindClassMemberFunction<Module>("isAutoLoad", &Module::isAutoLoad);
    g_lua.bindClassMemberFunction<Module>("getAutoLoadPriority", &Module::getAutoLoadPriority);

    // Event
    g_lua.registerClass<Event>();
    g_lua.bindClassMemberFunction<Event>("cancel", &Event::cancel);
    g_lua.bindClassMemberFunction<Event>("execute", &Event::execute);
    g_lua.bindClassMemberFunction<Event>("isCanceled", &Event::isCanceled);
    g_lua.bindClassMemberFunction<Event>("isExecuted", &Event::isExecuted);

    // ScheduledEvent
    g_lua.registerClass<ScheduledEvent, Event>();
    g_lua.bindClassMemberFunction<ScheduledEvent>("nextCycle", &ScheduledEvent::nextCycle);
    g_lua.bindClassMemberFunction<ScheduledEvent>("ticks", &ScheduledEvent::ticks);
    g_lua.bindClassMemberFunction<ScheduledEvent>("remainingTicks", &ScheduledEvent::remainingTicks);
    g_lua.bindClassMemberFunction<ScheduledEvent>("delay", &ScheduledEvent::delay);
    g_lua.bindClassMemberFunction<ScheduledEvent>("cyclesExecuted", &ScheduledEvent::cyclesExecuted);
    g_lua.bindClassMemberFunction<ScheduledEvent>("maxCycles", &ScheduledEvent::maxCycles);

#ifdef FRAMEWORK_GRAPHICS
    // GraphicalApplication
    g_lua.bindSingletonFunction("g_app", "isOnInputEvent", &GraphicalApplication::isOnInputEvent, &g_app);

    g_lua.bindSingletonFunction("g_app", "optimize", &GraphicalApplication::optimize, &g_app);
    g_lua.bindSingletonFunction("g_app", "forceEffectOptimization", &GraphicalApplication::forceEffectOptimization, &g_app);
    g_lua.bindSingletonFunction("g_app", "setDrawEffectOnTop", &GraphicalApplication::setDrawEffectOnTop, &g_app);

    g_lua.bindSingletonFunction("g_app", "getFps", &GraphicalApplication::getFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "getMaxFps", &GraphicalApplication::getMaxFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "setMaxFps", &GraphicalApplication::setMaxFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "getTargetFps", &GraphicalApplication::getTargetFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "setTargetFps", &GraphicalApplication::setTargetFps, &g_app);
    g_lua.bindSingletonFunction("g_app", "resetTargetFps", &GraphicalApplication::resetTargetFps, &g_app);

    g_lua.bindSingletonFunction("g_app", "isDrawingTexts", &GraphicalApplication::isDrawingTexts, &g_app);
    g_lua.bindSingletonFunction("g_app", "setDrawTexts", &GraphicalApplication::setDrawTexts, &g_app);
    g_lua.bindSingletonFunction("g_app", "setLoadingAsyncTexture", &GraphicalApplication::setLoadingAsyncTexture, &g_app);
    g_lua.bindSingletonFunction("g_app", "isEncrypted", &GraphicalApplication::isEncrypted, &g_app);
    g_lua.bindSingletonFunction("g_app", "isScaled", &GraphicalApplication::isScaled, &g_app);

    g_lua.bindSingletonFunction("g_app", "setHUDScale", &GraphicalApplication::setHUDScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setCreatureInformationScale", &GraphicalApplication::setCreatureInformationScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setAnimatedTextScale", &GraphicalApplication::setAnimatedTextScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "setStaticTextScale", &GraphicalApplication::setStaticTextScale, &g_app);
    g_lua.bindSingletonFunction("g_app", "doScreenshot", &GraphicalApplication::doScreenshot, &g_app);
    g_lua.bindSingletonFunction("g_app", "doMapScreenshot", &GraphicalApplication::doMapScreenshot, &g_app);

    // PlatformWindow
    g_lua.registerSingletonClass("g_window");
    g_lua.bindSingletonFunction("g_window", "move", &PlatformWindow::move, &g_window);
    g_lua.bindSingletonFunction("g_window", "resize", &PlatformWindow::resize, &g_window);
    g_lua.bindSingletonFunction("g_window", "show", &PlatformWindow::show, &g_window);
    g_lua.bindSingletonFunction("g_window", "hide", &PlatformWindow::hide, &g_window);
    g_lua.bindSingletonFunction("g_window", "poll", &PlatformWindow::poll, &g_window);
    g_lua.bindSingletonFunction("g_window", "maximize", &PlatformWindow::maximize, &g_window);
    g_lua.bindSingletonFunction("g_window", "restoreMouseCursor", &PlatformWindow::restoreMouseCursor, &g_window);
    g_lua.bindSingletonFunction("g_window", "showMouse", &PlatformWindow::showMouse, &g_window);
    g_lua.bindSingletonFunction("g_window", "hideMouse", &PlatformWindow::hideMouse, &g_window);
    g_lua.bindSingletonFunction("g_window", "setTitle", &PlatformWindow::setTitle, &g_window);
    g_lua.bindSingletonFunction("g_window", "setMouseCursor", &PlatformWindow::setMouseCursor, &g_window);
    g_lua.bindSingletonFunction("g_window", "setMinimumSize", &PlatformWindow::setMinimumSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "setFullscreen", &PlatformWindow::setFullscreen, &g_window);
    g_lua.bindSingletonFunction("g_window", "setVerticalSync", &PlatformWindow::setVerticalSync, &g_window);
    g_lua.bindSingletonFunction("g_window", "setIcon", &PlatformWindow::setIcon, &g_window);
    g_lua.bindSingletonFunction("g_window", "setClipboardText", &PlatformWindow::setClipboardText, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplaySize", &PlatformWindow::getDisplaySize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getClipboardText", &PlatformWindow::getClipboardText, &g_window);
    g_lua.bindSingletonFunction("g_window", "getPlatformType", &PlatformWindow::getPlatformType, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayWidth", &PlatformWindow::getDisplayWidth, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayHeight", &PlatformWindow::getDisplayHeight, &g_window);
    g_lua.bindSingletonFunction("g_window", "getUnmaximizedSize", &PlatformWindow::getUnmaximizedSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getSize", &PlatformWindow::getSize, &g_window);
    g_lua.bindSingletonFunction("g_window", "getWidth", &PlatformWindow::getWidth, &g_window);
    g_lua.bindSingletonFunction("g_window", "getHeight", &PlatformWindow::getHeight, &g_window);
    g_lua.bindSingletonFunction("g_window", "getUnmaximizedPos", &PlatformWindow::getUnmaximizedPos, &g_window);
    g_lua.bindSingletonFunction("g_window", "getPosition", &PlatformWindow::getPosition, &g_window);
    g_lua.bindSingletonFunction("g_window", "getX", &PlatformWindow::getX, &g_window);
    g_lua.bindSingletonFunction("g_window", "getY", &PlatformWindow::getY, &g_window);
    g_lua.bindSingletonFunction("g_window", "getMousePosition", &PlatformWindow::getMousePosition, &g_window);
    g_lua.bindSingletonFunction("g_window", "getKeyboardModifiers", &PlatformWindow::getKeyboardModifiers, &g_window);
    g_lua.bindSingletonFunction("g_window", "isKeyPressed", &PlatformWindow::isKeyPressed, &g_window);
    g_lua.bindSingletonFunction("g_window", "isMouseButtonPressed", &PlatformWindow::isMouseButtonPressed, &g_window);
    g_lua.bindSingletonFunction("g_window", "isVisible", &PlatformWindow::isVisible, &g_window);
    g_lua.bindSingletonFunction("g_window", "isFullscreen", &PlatformWindow::isFullscreen, &g_window);
    g_lua.bindSingletonFunction("g_window", "isMaximized", &PlatformWindow::isMaximized, &g_window);
    g_lua.bindSingletonFunction("g_window", "hasFocus", &PlatformWindow::hasFocus, &g_window);
    g_lua.bindSingletonFunction("g_window", "getDisplayDensity", &PlatformWindow::getDisplayDensity, &g_window);
    g_lua.bindSingletonFunction("g_window", "setKeyDelay", &PlatformWindow::setKeyDelay, &g_window);

    // Input
    g_lua.registerSingletonClass("g_mouse");
    g_lua.bindSingletonFunction("g_mouse", "loadCursors", &Mouse::loadCursors, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "addCursor", &Mouse::addCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "pushCursor", &Mouse::pushCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "popCursor", &Mouse::popCursor, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "isCursorChanged", &Mouse::isCursorChanged, &g_mouse);
    g_lua.bindSingletonFunction("g_mouse", "isPressed", &Mouse::isPressed, &g_mouse);

    // Graphics
    g_lua.registerSingletonClass("g_graphics");
    g_lua.bindSingletonFunction("g_graphics", "getViewportSize", &Graphics::getViewportSize, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getVendor", &Graphics::getVendor, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getRenderer", &Graphics::getRenderer, &g_graphics);
    g_lua.bindSingletonFunction("g_graphics", "getVersion", &Graphics::getVersion, &g_graphics);

    // Textures
    g_lua.registerSingletonClass("g_textures");
    g_lua.bindSingletonFunction("g_textures", "preload", &TextureManager::preload, &g_textures);
    g_lua.bindSingletonFunction("g_textures", "clearCache", &TextureManager::clearCache, &g_textures);
    g_lua.bindSingletonFunction("g_textures", "liveReload", &TextureManager::liveReload, &g_textures);

    // UI
    g_lua.registerSingletonClass("g_ui");
    g_lua.bindSingletonFunction("g_ui", "clearStyles", &UIManager::clearStyles, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "importStyle", &UIManager::importStyle, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyle", &UIManager::getStyle, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyleName", &UIManager::getStyleName, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getStyleClass", &UIManager::getStyleClass, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "loadUI", &UIManager::loadUI, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "loadUIFromString", &UIManager::loadUIFromString, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "displayUI", &UIManager::displayUI, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "createWidget", &UIManager::createWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "createWidgetFromOTML", &UIManager::createWidgetFromOTML, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getRootWidget", &UIManager::getRootWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getDraggingWidget", &UIManager::getDraggingWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "getPressedWidget", &UIManager::getPressedWidget, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "setDebugBoxesDrawing", &UIManager::setDebugBoxesDrawing, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isDrawingDebugBoxes", &UIManager::isDrawingDebugBoxes, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isMouseGrabbed", &UIManager::isMouseGrabbed, &g_ui);
    g_lua.bindSingletonFunction("g_ui", "isKeyboardGrabbed", &UIManager::isKeyboardGrabbed, &g_ui);

    // FontManager
    g_lua.registerSingletonClass("g_fonts");
    g_lua.bindSingletonFunction("g_fonts", "clearFonts", &FontManager::clearFonts, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "clearGlyphCaches", &FontManager::clearGlyphCaches, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "setLocaleTag", &FontManager::setLocaleTag, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "getLocaleTag", &FontManager::getLocaleTag, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "importFont", &FontManager::importFont, &g_fonts);
    g_lua.bindSingletonFunction("g_fonts", "fontExists", &FontManager::fontExists, &g_fonts);

    // ParticleManager
    g_lua.registerSingletonClass("g_particles");
    g_lua.bindSingletonFunction("g_particles", "importParticle", &ParticleManager::importParticle, &g_particles);
    g_lua.bindSingletonFunction("g_particles", "getEffectsTypes", &ParticleManager::getEffectsTypes, &g_particles);
    g_lua.bindSingletonFunction("g_particles", "terminate", &ParticleManager::terminate, &g_particles);

    // ShaderManager
    g_lua.registerSingletonClass("g_shaders");
    g_lua.bindSingletonFunction("g_shaders", "createShader", &ShaderManager::createShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "createFragmentShader", &ShaderManager::createFragmentShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "createFragmentShaderFromCode", &ShaderManager::createFragmentShaderFromCode, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupMapShader", &ShaderManager::setupMapShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupItemShader", &ShaderManager::setupItemShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupOutfitShader", &ShaderManager::setupOutfitShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "setupMountShader", &ShaderManager::setupMountShader, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "addMultiTexture", &ShaderManager::addMultiTexture, &g_shaders);
    g_lua.bindSingletonFunction("g_shaders", "getShader", &ShaderManager::getShader, &g_shaders);
    g_lua.bindClassStaticFunction("g_shaders", "clear", [] {
        g_mainDispatcher.addEvent([] { g_shaders.clear(); });
    });

    // UI, layout, text edit, QR code, shader, particle, network, and sound
    // bindings are in luafunctions_ui.cpp to avoid MSVC ICE C1001.
    extern void registerLuaFunctions_UI();
    registerLuaFunctions_UI();
}
