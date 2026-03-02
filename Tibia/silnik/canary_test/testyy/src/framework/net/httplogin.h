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

// Makro CPPHTTPLIB_OPENSSL_SUPPORT jest już dodawane przez system budowania (CMake/compile definitions).
// Aby uniknąć ostrzeżeń o redefinicji, definiujemy je tylko jeśli nie zostało ustawione wcześniej.
#ifndef CPPHTTPLIB_OPENSSL_SUPPORT
#define CPPHTTPLIB_OPENSSL_SUPPORT
#endif
#include <framework/luaengine/luaobject.h>
#include <httplib.h>

class LoginHttp final : public LuaObject
{
public:
    LoginHttp();

    void startHttpLogin(const std::string& host, const std::string& path,
                        uint16_t port, const std::string& email,
                        const std::string& password);

    void Logger(const auto& req, const auto& res);

    std::string getCharacterList();

    std::string getWorldList();

    std::string getSession();

    bool parseJsonResponse(const std::string& body);

    void httpLogin(const std::string& host, const std::string& path,
                   uint16_t port, const std::string& email,
                   const std::string& password, int request_id, bool httpLogin);

    // E10: Ustawia launchToken (z launchera) — dodawany do JSON body przy loginie.
    // Launcher przekazuje token przez zmienną OTC_LAUNCH_TOKEN.
    void setLaunchToken(const std::string& token);

    // FIX18: Ustawia gameMode (classic74/modern) — dodawany do JSON body przy loginie.
    // Bez tego login.php zapisuje sesję jako 'modern' i ticket mismatch dla classic74.
    void setGameMode(const std::string& mode);

    // B6: Ticket request — po udanym loginie, przed połączeniem z game serverem.
    // Wysyła sessionKey + characterName + gameMode + worldName do ticket.php,
    // odbiera podpisany ticket HMAC do przesłania do Canary.
    void requestTicket(const std::string& host, const std::string& path,
                       uint16_t port, const std::string& sessionKey,
                       const std::string& characterName,
                       const std::string& gameMode,
                       const std::string& worldName, int request_id);

    httplib::Result loginHttpsJson(const std::string& host,
                                   const std::string& path, uint16_t port,
                                   const std::string& email,
                                   const std::string& password);

    enum Result : int { Success = 200, Error = -1 };

private:
    std::string characters;
    std::string worlds;
    std::string session;
    std::string errorMessage;
    std::string launchToken;  // E10: token z launchera (OTC_LAUNCH_TOKEN)
    std::string gameMode;      // FIX18: tryb gry (classic74/modern)
};
