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

#include "httplogin.h"

#include <framework/core/asyncdispatcher.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/resourcemanager.h>  // FIX-C2: g_resources.getWorkDir() for cacert.pem path
#include <httplib.h>
#include <iostream>
#include <algorithm>
#include <fstream>  // FIX35: std::ifstream for cacert.pem check
#include <nlohmann/json.hpp>
#include <string>

#ifdef __EMSCRIPTEN__
#include <emscripten/fetch.h>
#endif

using json = nlohmann::json;

LoginHttp::LoginHttp() {
    this->characters.clear();
    this->worlds.clear();
    this->session.clear();
    this->errorMessage.clear();
}

void LoginHttp::Logger(const auto& req, const auto& res) {
    // X7+CR-3: NIE logujemy body (dane wrażliwe) ani nagłówków (Set-Cookie itp.)
    std::cout << "======= LOG ======= " << std::endl;
    std::cout << "-- REQUEST --" << std::endl;
    std::cout << req.method << std::endl;
    std::cout << req.path << std::endl;
    // req.body pominięty — dane wrażliwe (email, password)
    // req.headers pominięte — mogą zawierać tokeny autoryzacji

    std::cout << "-- RESPONSE --" << std::endl;
    std::cout << res.version << std::endl;
    std::cout << res.status << std::endl;
    std::cout << res.reason << std::endl;
    // res.body pominięty — może zawierać session key
    // res.headers pominięte — mogą zawierać Set-Cookie, auth tokens
    std::cout << res.location << std::endl;

    std::cout << "========= " << std::endl;
}

// E10: setter launchToken — Lua woła http:setLaunchToken(token) przed httpLogin
void LoginHttp::setLaunchToken(const std::string& token) {
    // INS-CPP5: Walidacja formatu tokenu — max 512 znaków, tylko alfanumeryczne + _-.
    if (token.size() > 512) {
        std::cerr << "[LOGIN] WARNING: launchToken too long (" << token.size() << " chars), ignoring." << std::endl;
        return;
    }
    if (!std::all_of(token.begin(), token.end(), [](unsigned char c) {
            return std::isalnum(c) || c == '_' || c == '-' || c == '.';
        })) {
        std::cerr << "[LOGIN] WARNING: launchToken contains invalid characters, ignoring." << std::endl;
        return;
    }
    this->launchToken = token;
}

void LoginHttp::setSessionToken(const std::string& token) {
    if (token.size() > 256) {
        std::cerr << "[LOGIN] WARNING: sessionToken too long (" << token.size() << " chars), ignoring." << std::endl;
        return;
    }
    if (!std::all_of(token.begin(), token.end(), [](unsigned char c) {
            return std::isalnum(c);
        })) {
        std::cerr << "[LOGIN] WARNING: sessionToken contains invalid characters, ignoring." << std::endl;
        return;
    }
    this->sessionToken = token;
}

// FIX18: setter gameMode — Lua woła http:setGameMode(mode) przed httpLogin
void LoginHttp::setGameMode(const std::string& mode) {
    // INS-CPP6: Whitelist — tylko znane tryby gry
    if (mode != "classic74" && mode != "modern" && !mode.empty()) {
        std::cerr << "[LOGIN] WARNING: unknown gameMode '" << mode << "', ignoring." << std::endl;
        return;
    }
    this->gameMode = mode;
}

// INS-CPP1: startHttpLogin() usunięty — dead code.
// Nigdy nie był bindowany do Lua, nie parsował response, brak TLS verify.
// Jedyna ścieżka logowania to httpLogin() → loginHttpsJson() (z TLS) lub Emscripten fetch.

std::string LoginHttp::getCharacterList() { return this->characters; }

std::string LoginHttp::getWorldList() { return this->worlds; }

std::string LoginHttp::getSession() { return this->session; }

void LoginHttp::httpLogin(const std::string& host, const std::string& path,
                          uint16_t port, const std::string& email,
                          const std::string& password, int request_id,
                          bool httpLogin) {
#ifndef __EMSCRIPTEN__
    (void)g_asyncDispatcher.submit_task(
        [this, host, path, port, email, password, request_id] {
        httplib::Result result =
            this->loginHttpsJson(host, path, port, email, password);
        // X2b: BRAK fallbacku na HTTP — jeśli HTTPS fail, to fail.
        // Usunięto: if (httpLogin && ...) { result = loginHttpJson(...); }

        if (result && result->status == Success) {
            g_dispatcher.addEvent([this, request_id] {
                g_lua.callGlobalField("EnterGame", "loginSuccess", request_id,
                this->getSession(), this->getWorldList(),
                this->getCharacterList());
            });
        } else {
            int status = 0;
            std::string msg = "";
            if (result) {
                status = result->status;
                try {
                    const auto body = json::parse(result->body);
                    if (body.contains("errorMessage")) {
                        msg = body["errorMessage"];
                    } else {
                        msg = "Unexpected JSON format.";
                    }
                } catch (const std::exception&) {
                    msg = to_string(result.error());
                }
            } else {
                status = -1;
                // CR-2: Zaktualizowany komunikat — HTTPS-only, bez wzmianki o HTTP/port 80
                msg = "Cannot connect to login server (HTTPS).\nCheck:\n- Server address and port\n- Apache / nginx running\n- login.php accessible\n- TLS certificate valid\n- Cloudflare / firewall rules";
            }

            g_dispatcher.addEvent([this, request_id, status, msg] {
                g_lua.callGlobalField("EnterGame", "loginFailed", request_id, msg,
                status);
            });
        }
    });
#else
    (void)g_asyncDispatcher.submit_task(
        [this, host, path, port, email, password, request_id] {
        emscripten_fetch_attr_t attr;
        emscripten_fetch_attr_init(&attr);
        strncpy(attr.requestMethod, "POST", sizeof(attr.requestMethod) - 1);
        static const char* const headers[] = {
            "Content-Type", "application/json; charset=utf-8",
            0,
        };
        attr.requestHeaders = headers;
        attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY | EMSCRIPTEN_FETCH_SYNCHRONOUS;
        // E10: launchToken dołączany do body logowania
        json body = json{ {"email", email}, {"password", password}, {"stayloggedin", true}, {"type", "login"} };
        if (!this->launchToken.empty()) {
            body["launchToken"] = this->launchToken;
        }
        if (!this->sessionToken.empty()) {
            body["sessionToken"] = this->sessionToken;
        }
        // FIX18: gameMode dołączany do body logowania
        if (!this->gameMode.empty()) {
            body["gameMode"] = this->gameMode;
        }
        std::string bodyStr = body.dump(1);
        attr.requestData = bodyStr.data();
        attr.requestDataSize = bodyStr.length();

        std::string url = "https://" + (host.length() > 0 ? host : "127.0.0.1") + ":" + std::to_string(port) + path;
        emscripten_fetch_t* fetch = emscripten_fetch(&attr, url.c_str());
        // X2b: BRAK fallbacku na HTTP w Emscripten — tylko HTTPS.

        // FIX56: Zapisz status PRZED emscripten_fetch_close(), bo close zwalnia struct.
        int savedStatus = (fetch) ? fetch->status : -1;
        std::string savedData;
        if (fetch && fetch->data && fetch->numBytes > 0) {
            savedData.assign(fetch->data, fetch->numBytes);
        }

        if (savedStatus == 200 && !parseJsonResponse(savedData)) {
            savedStatus = -1;
        }

        emscripten_fetch_close(fetch);

        if (savedStatus == 200) {
            g_dispatcher.addEvent([this, request_id] {
                g_lua.callGlobalField("EnterGame", "loginSuccess", request_id,
                this->getSession(), this->getWorldList(),
                this->getCharacterList());
            });
        } else {
            int status = savedStatus;
            std::string msg = "";
            if (this->errorMessage.length() == 0) {
                msg = "Unknown error";
            } else {
                msg = this->errorMessage;
            }

            g_dispatcher.addEvent([this, request_id, status, msg] {
                g_lua.callGlobalField("EnterGame", "loginFailed", request_id, msg,
                status);
            });
        }
    });
#endif
}

httplib::Result LoginHttp::loginHttpsJson(const std::string& host,
                                          const std::string& path,
                                          const uint16_t port,
                                          const std::string& email,
                                          const std::string& password) {
    httplib::SSLClient client(host, port);

    // INS-CPP2: Timeouty HTTP — zapobiegają zawieszeniu wątku na nieosiągalnym serwerze
    client.set_connection_timeout(10, 0);   // 10s na nawiązanie połączenia
    client.set_read_timeout(15, 0);         // 15s na odczyt odpowiedzi
    client.set_write_timeout(10, 0);        // 10s na wysłanie requestu

    client.set_logger(
        [this](const auto& req, const auto& res) { LoginHttp::Logger(req, res); });

    // FIX-C2: Buduj ścieżkę do cacert.pem względem katalogu roboczego klienta
    // zamiast hardkodowanego "./cacert.pem" (które zależy od cwd przy uruchomieniu).
    std::string certPath = g_resources.getWorkDir() + "cacert.pem";
    client.set_ca_cert_path(certPath);
    client.enable_server_certificate_verification(true);  // X2: TLS hard-fail — odrzucaj nieważne certy

    // FIX35: Loguj warning jeśli cacert.pem nie istnieje.
    {
        std::ifstream certCheck(certPath);
        if (!certCheck.good()) {
            std::cerr << "[LOGIN] WARNING: cacert.pem not found at " << certPath << ". TLS connections will fail." << std::endl;
        }
    }

    // E10: launchToken dołączany do body logowania
    json body = { {"email", email}, {"password", password}, {"stayloggedin", true}, {"type", "login"} };
    if (!this->launchToken.empty()) {
        body["launchToken"] = this->launchToken;
    }
    if (!this->sessionToken.empty()) {
        body["sessionToken"] = this->sessionToken;
    }
    // FIX18: gameMode dołączany do body logowania
    if (!this->gameMode.empty()) {
        body["gameMode"] = this->gameMode;
    }
    const httplib::Headers headers = { {"User-Agent", "Mozilla/5.0"} };

    httplib::Result response =
        client.Post(path, headers, body.dump(), "application/json");
    if (!response) {
        std::cout << "HTTPS error: unknown" << std::endl;
    } else if (response->status != Success) {
        std::cout << "HTTPS error: " << to_string(response.error())
            << std::endl;
    } else {
        std::cout << "HTTPS status: " << to_string(response.error())
            << std::endl;
    }

    if (response && response->status == Success &&
        !parseJsonResponse(response->body)) {
        response->status = -1;
    }

    return response;
}

// ============================================================
// B6: requestTicket — żądanie ticketu HMAC przed połączeniem z game serverem
// Flow: klient → POST ticket.php {sessionKey, characterName, gameMode, worldName}
//       ticket.php → {ticket: "HMAC_SIGNED_TOKEN", expiresAt: unix_ts}
//       klient → przekazuje ticket do g_game.loginWorld (Faza C)
// ============================================================
void LoginHttp::requestTicket(const std::string& host, const std::string& path,
                              uint16_t port, const std::string& sessionKey,
                              const std::string& characterName,
                              const std::string& gameMode,
                              const std::string& worldName, int request_id) {
#ifndef __EMSCRIPTEN__
    (void)g_asyncDispatcher.submit_task(
        [this, host, path, port, sessionKey, characterName, gameMode, worldName, request_id] {
        httplib::SSLClient client(host, port);
        // INS-CPP2: Timeouty HTTP — zapobiegają zawieszeniu wątku
        client.set_connection_timeout(10, 0);
        client.set_read_timeout(15, 0);
        client.set_write_timeout(10, 0);
        // FIX-C2: użyj dynamicznej ścieżki do cacert.pem
        std::string certPath = g_resources.getWorkDir() + "cacert.pem";
        client.set_ca_cert_path(certPath);
        client.enable_server_certificate_verification(true);  // TLS hard-fail

        // INS-CPP7: Sprawdź czy cacert.pem istnieje (analogicznie do loginHttpsJson)
        {
            std::ifstream certCheck(certPath);
            if (!certCheck.good()) {
                std::cerr << "[TICKET] WARNING: cacert.pem not found at " << certPath << ". TLS connections will fail." << std::endl;
            }
        }

        const json body = {
            {"sessionKey", sessionKey},
            {"characterName", characterName},
            {"gameMode", gameMode},
            {"worldName", worldName},
            {"type", "ticket"}
        };
        const httplib::Headers headers = {{"User-Agent", "Mozilla/5.0"}};

        httplib::Result response =
            client.Post(path, headers, body.dump(), "application/json");

        if (response && response->status == Success) {
            try {
                auto respJson = json::parse(response->body);
                if (respJson.contains("ticket")) {
                    std::string ticket = respJson["ticket"].get<std::string>();
                    g_dispatcher.addEvent([this, request_id, ticket] {
                        g_lua.callGlobalField("EnterGame", "onTicketSuccess",
                                              request_id, ticket);
                    });
                    return;
                }
            } catch (const std::exception& e) {
                std::cout << "Ticket JSON parse error: " << e.what() << std::endl;
            }
        }

        // Ticket request failed
        std::string msg = "Ticket request failed.";
        int status = 0;
        if (response) {
            status = response->status;
            try {
                auto errJson = json::parse(response->body);
                if (errJson.contains("errorMessage")) {
                    msg = errJson["errorMessage"].get<std::string>();
                }
            } catch (...) {
                g_logger.warning("Failed to parse ticket error JSON");
            }
        } else {
            status = -1;
            msg = "Cannot connect to ticket server (HTTPS).";
        }

        g_dispatcher.addEvent([this, request_id, status, msg] {
            g_lua.callGlobalField("EnterGame", "onTicketFailed",
                                  request_id, msg, status);
        });
    });
#else
    // Emscripten: ticket request via emscripten_fetch (HTTPS only)
    (void)g_asyncDispatcher.submit_task(
        [this, host, path, port, sessionKey, characterName, gameMode, worldName, request_id] {
        emscripten_fetch_attr_t attr;
        emscripten_fetch_attr_init(&attr);
        strncpy(attr.requestMethod, "POST", sizeof(attr.requestMethod) - 1);
        static const char* const headers[] = {
            "Content-Type", "application/json; charset=utf-8",
            0,
        };
        attr.requestHeaders = headers;
        attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY | EMSCRIPTEN_FETCH_SYNCHRONOUS;

        json body = {
            {"sessionKey", sessionKey},
            {"characterName", characterName},
            {"gameMode", gameMode},
            {"worldName", worldName},
            {"type", "ticket"}
        };
        std::string bodyStr = body.dump(1);
        attr.requestData = bodyStr.data();
        attr.requestDataSize = bodyStr.length();

        std::string url = "https://" + (host.length() > 0 ? host : "127.0.0.1") +
                          ":" + std::to_string(port) + path;
        emscripten_fetch_t* fetch = emscripten_fetch(&attr, url.c_str());

        if (fetch && fetch->status == 200) {
            try {
                auto respJson = json::parse(std::string(fetch->data, fetch->numBytes));
                if (respJson.contains("ticket")) {
                    std::string ticket = respJson["ticket"].get<std::string>();
                    emscripten_fetch_close(fetch);
                    g_dispatcher.addEvent([this, request_id, ticket] {
                        g_lua.callGlobalField("EnterGame", "onTicketSuccess",
                                              request_id, ticket);
                    });
                    return;
                }
            } catch (...) {
                g_logger.warning("Failed to parse ticket response JSON (emscripten)");
            }
        }

        std::string msg = "Ticket request failed.";
        int status = fetch ? fetch->status : -1;
        emscripten_fetch_close(fetch);

        g_dispatcher.addEvent([this, request_id, status, msg] {
            g_lua.callGlobalField("EnterGame", "onTicketFailed",
                                  request_id, msg, status);
        });
    });
#endif
}

bool LoginHttp::parseJsonResponse(const std::string& body) {
    json responseJson;
    try {
        responseJson = json::parse(body);
    } catch (...) {
        g_logger.info("Failed to parse json response");
        return false;
    }

    if (responseJson.contains("errorMessage")) {
        this->errorMessage = to_string(responseJson.at("errorMessage"));
        return false;
    }

    if (!responseJson.contains("session")) {
        g_logger.info("No session data");
        return false;
    }

    if (responseJson.contains("playdata")) {
        json playdata = responseJson.at("playdata");

        this->characters = "{}";
        if (playdata.contains("characters")) {
            this->characters = to_string(playdata.at("characters"));
        }

        this->worlds = "{}";
        if (playdata.contains("worlds")) {
            this->worlds = to_string(playdata.at("worlds"));
        }
    }

    this->session = to_string(responseJson.at("session"));

    // INS-CPP8: Wyczyść launchToken po udanym loginie — jednorazowe użycie
    this->launchToken.clear();

    return true;
}
