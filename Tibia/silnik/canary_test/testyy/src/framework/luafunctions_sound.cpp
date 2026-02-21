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
 // This file contains sound-related Lua bindings (SoundManager, SoundSource,
 // SoundChannel, SoundEffect, etc.).

#include <framework/luaengine/luainterface.h>

#ifdef FRAMEWORK_SOUND
#include <framework/sound/combinedsoundsource.h>
#include <framework/sound/soundchannel.h>
#include <framework/sound/soundeffect.h>
#include <framework/sound/soundmanager.h>
#include <framework/sound/soundsource.h>
#include <framework/sound/streamsoundsource.h>
#endif

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", off)
#endif

void registerLuaFunctions_Sound()
{
#ifdef FRAMEWORK_SOUND
    // SoundManager
    g_lua.registerSingletonClass("g_sounds");
    g_lua.bindSingletonFunction("g_sounds", "preload", &SoundManager::preload, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "play", &SoundManager::play, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "getChannel", &SoundManager::getChannel, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "stopAll", &SoundManager::stopAll, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "enableAudio", &SoundManager::enableAudio, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "disableAudio", &SoundManager::disableAudio, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "setAudioEnabled", &SoundManager::setAudioEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "isAudioEnabled", &SoundManager::isAudioEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "setPosition", &SoundManager::setPosition, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "createSoundEffect", &SoundManager::createSoundEffect, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "isEaxEnabled", &SoundManager::isEaxEnabled, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "loadClientFiles", &SoundManager::loadClientFiles, &g_sounds);
    g_lua.bindSingletonFunction("g_sounds", "getAudioFileNameById", &SoundManager::getAudioFileNameById, &g_sounds);

    g_lua.registerClass<SoundSource>();
    g_lua.bindClassStaticFunction<SoundSource>("create", [] { return std::make_shared<SoundSource>(); });
    g_lua.bindClassMemberFunction<SoundSource>("setName", &SoundSource::setName);
    g_lua.bindClassMemberFunction<SoundSource>("play", &SoundSource::play);
    g_lua.bindClassMemberFunction<SoundSource>("stop", &SoundSource::stop);
    g_lua.bindClassMemberFunction<SoundSource>("isPlaying", &SoundSource::isPlaying);
    g_lua.bindClassMemberFunction<SoundSource>("setGain", &SoundSource::setGain);
    g_lua.bindClassMemberFunction<SoundSource>("setPosition", &SoundSource::setPosition);
    g_lua.bindClassMemberFunction<SoundSource>("setVelocity", &SoundSource::setVelocity);
    g_lua.bindClassMemberFunction<SoundSource>("setFading", &SoundSource::setFading);
    g_lua.bindClassMemberFunction<SoundSource>("setLooping", &SoundSource::setLooping);
    g_lua.bindClassMemberFunction<SoundSource>("setRelative", &SoundSource::setRelative);
    g_lua.bindClassMemberFunction<SoundSource>("setReferenceDistance", &SoundSource::setReferenceDistance);
    g_lua.bindClassMemberFunction<SoundSource>("setEffect", &SoundSource::setEffect);
    g_lua.bindClassMemberFunction<SoundSource>("removeEffect", &SoundSource::removeEffect);
    g_lua.registerClass<CombinedSoundSource, SoundSource>();
    g_lua.registerClass<StreamSoundSource, SoundSource>();

    g_lua.registerClass<SoundEffect>();
    g_lua.bindClassMemberFunction<SoundEffect>("setPreset", &SoundEffect::setPreset);

    g_lua.registerClass<SoundChannel>();
    g_lua.bindClassMemberFunction<SoundChannel>("play", &SoundChannel::play);
    g_lua.bindClassMemberFunction<SoundChannel>("stop", &SoundChannel::stop);
    g_lua.bindClassMemberFunction<SoundChannel>("enqueue", &SoundChannel::enqueue);
    g_lua.bindClassMemberFunction<SoundChannel>("enable", &SoundChannel::enable);
    g_lua.bindClassMemberFunction<SoundChannel>("disable", &SoundChannel::disable);
    g_lua.bindClassMemberFunction<SoundChannel>("setGain", &SoundChannel::setGain);
    g_lua.bindClassMemberFunction<SoundChannel>("getGain", &SoundChannel::getGain);
    g_lua.bindClassMemberFunction<SoundChannel>("setEnabled", &SoundChannel::setEnabled);
    g_lua.bindClassMemberFunction<SoundChannel>("isEnabled", &SoundChannel::isEnabled);
    g_lua.bindClassMemberFunction<SoundChannel>("getId", &SoundChannel::getId);
#endif
}

#if defined(_MSC_VER) && !defined(__clang__)
#pragma optimize("", on)
#endif
