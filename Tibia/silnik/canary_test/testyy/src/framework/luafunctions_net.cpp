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

 // Split from luafunctions_ui.cpp to reduce template instantiation pressure
 // per translation unit and avoid MSVC ICE C1001.
 // This file contains network-related Lua bindings (Server, Connection,
 // Protocol, InputMessage, OutputMessage).

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_NET
#include <framework/net/protocol.h>
#include <framework/net/server.h>
#endif

#include "net/inputmessage.h"
#include "net/outputmessage.h"

void registerLuaFunctions_Net()
{
#ifdef FRAMEWORK_NET
#ifndef __EMSCRIPTEN__
    // Server
    g_lua.registerClass<Server>();
    g_lua.bindClassStaticFunction<Server>("create", &Server::create);
    g_lua.bindClassMemberFunction<Server>("close", &Server::close);
    g_lua.bindClassMemberFunction<Server>("isOpen", &Server::isOpen);
    g_lua.bindClassMemberFunction<Server>("acceptNext", &Server::acceptNext);
#endif

    // Connection
#ifdef __EMSCRIPTEN__
    g_lua.registerClass<WebConnection>();
    g_lua.bindClassMemberFunction<WebConnection>("getIp", &WebConnection::getIp);
#else
    g_lua.registerClass<Connection>();
    g_lua.bindClassMemberFunction<Connection>("getIp", &Connection::getIp);
#endif

    // Protocol
    g_lua.registerClass<Protocol>();
    g_lua.bindClassStaticFunction<Protocol>("create", [] { return std::make_shared<Protocol>(); });
    g_lua.bindClassMemberFunction<Protocol>("connect", &Protocol::connect);
    g_lua.bindClassMemberFunction<Protocol>("disconnect", &Protocol::disconnect);
    g_lua.bindClassMemberFunction<Protocol>("isConnected", &Protocol::isConnected);
    g_lua.bindClassMemberFunction<Protocol>("isConnecting", &Protocol::isConnecting);
    g_lua.bindClassMemberFunction<Protocol>("getConnection", &Protocol::getConnection);
    g_lua.bindClassMemberFunction<Protocol>("setConnection", &Protocol::setConnection);
    g_lua.bindClassMemberFunction<Protocol>("send", &Protocol::send);
    g_lua.bindClassMemberFunction<Protocol>("recv", &Protocol::recv);
    g_lua.bindClassMemberFunction<Protocol>("setXteaKey", &Protocol::setXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("getXteaKey", &Protocol::getXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("generateXteaKey", &Protocol::generateXteaKey);
    g_lua.bindClassMemberFunction<Protocol>("enableXteaEncryption", &Protocol::enableXteaEncryption);
    g_lua.bindClassMemberFunction<Protocol>("enabledSequencedPackets", &Protocol::enabledSequencedPackets);
    g_lua.bindClassMemberFunction<Protocol>("enableChecksum", &Protocol::enableChecksum);

    // InputMessage
    g_lua.registerClass<InputMessage>();
    g_lua.bindClassStaticFunction<InputMessage>("create", [] { return std::make_shared<InputMessage>(); });
    g_lua.bindClassMemberFunction<InputMessage>("setBuffer", &InputMessage::setBuffer);
    g_lua.bindClassMemberFunction<InputMessage>("getBuffer", &InputMessage::getBuffer);
    g_lua.bindClassMemberFunction<InputMessage>("skipBytes", &InputMessage::skipBytes);
    g_lua.bindClassMemberFunction<InputMessage>("getU8", &InputMessage::getU8);
    g_lua.bindClassMemberFunction<InputMessage>("getU16", &InputMessage::getU16);
    g_lua.bindClassMemberFunction<InputMessage>("getU32", &InputMessage::getU32);
    g_lua.bindClassMemberFunction<InputMessage>("getU64", &InputMessage::getU64);
    g_lua.bindClassMemberFunction<InputMessage>("getString", &InputMessage::getString);
    g_lua.bindClassMemberFunction<InputMessage>("peekU8", &InputMessage::peekU8);
    g_lua.bindClassMemberFunction<InputMessage>("peekU16", &InputMessage::peekU16);
    g_lua.bindClassMemberFunction<InputMessage>("peekU32", &InputMessage::peekU32);
    g_lua.bindClassMemberFunction<InputMessage>("peekU64", &InputMessage::peekU64);
    g_lua.bindClassMemberFunction<InputMessage>("decryptRsa", &InputMessage::decryptRsa);
    g_lua.bindClassMemberFunction<InputMessage>("getReadSize", &InputMessage::getReadSize);
    g_lua.bindClassMemberFunction<InputMessage>("getUnreadSize", &InputMessage::getUnreadSize);
    g_lua.bindClassMemberFunction<InputMessage>("getMessageSize", &InputMessage::getMessageSize);
    g_lua.bindClassMemberFunction<InputMessage>("eof", &InputMessage::eof);

    // OutputMessage
    g_lua.registerClass<OutputMessage>();
    g_lua.bindClassStaticFunction<OutputMessage>("create", [] { return std::make_shared<OutputMessage>(); });
    g_lua.bindClassMemberFunction<OutputMessage>("setBuffer", &OutputMessage::setBuffer);
    g_lua.bindClassMemberFunction<OutputMessage>("getBuffer", &OutputMessage::getBuffer);
    g_lua.bindClassMemberFunction<OutputMessage>("reset", &OutputMessage::reset);
    g_lua.bindClassMemberFunction<OutputMessage>("addU8", &OutputMessage::addU8);
    g_lua.bindClassMemberFunction<OutputMessage>("addU16", &OutputMessage::addU16);
    g_lua.bindClassMemberFunction<OutputMessage>("addU32", &OutputMessage::addU32);
    g_lua.bindClassMemberFunction<OutputMessage>("addU64", &OutputMessage::addU64);
    g_lua.bindClassMemberFunction<OutputMessage>("addString", &OutputMessage::addString);
    g_lua.bindClassMemberFunction<OutputMessage>("addPaddingBytes", &OutputMessage::addPaddingBytes);
    g_lua.bindClassMemberFunction<OutputMessage>("encryptRsa", &OutputMessage::encryptRsa);
    g_lua.bindClassMemberFunction<OutputMessage>("getMessageSize", &OutputMessage::getMessageSize);
    g_lua.bindClassMemberFunction<OutputMessage>("setMessageSize", &OutputMessage::setMessageSize);
    g_lua.bindClassMemberFunction<OutputMessage>("getWritePos", &OutputMessage::getWritePos);
    g_lua.bindClassMemberFunction<OutputMessage>("setWritePos", &OutputMessage::setWritePos);
#endif
}
