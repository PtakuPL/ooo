## Aktualizacja 2026-02-21 (CI Linux/Windows, faza enum/fmt)

Aktualna, scalona analiza runow i poprawek (Linux + Windows) jest tutaj:

- `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_ci_linux_windows_analiza_poprawek_v3.md`

Szybki status:
- potwierdzone klasy bledow Linux: split Lua bindings -> `lzma_ret`/fmt -> `ThingCategory`/fmt,
- wdrozone fixy punktowe + globalny fallback enum formattera (`framework/pch.h`),
- aktualne runy Linux z fixami byly jeszcze w toku na moment zapisu raportu.

---

## Aktualizacja 2026-02-21 (status dokumentu)

Ten plik to głównie surowy log/historyczna rozmowa o warningach.  
Aktualna analiza przyczyn "znikających" buildów Linux i plan naprawczy CI:

- `Dokumentacja/01_Instalka_Klient/2026-02/2026-02-21_audyt_i18n_layout_ci_linux_windows.md`

Skrót: workflow Linux jest aktywny, ale ma zawężone `paths:` i dlatego część zmian OTUI/Lua/i18n nie uruchamia builda automatycznie.

---

Dobrze to teraz wracamy do problemów generacji poprawnych zdań w instalce . na gh actions build linux przeszedł ale ma pełno warnings. co to za waringi. Te mnie najbardziej insteresują 

OTC Linux Build (Release): Tibia/silnik/canary_test/testyy/src/framework/text/TextShaper.cpp#L139
ignoring return value of ‘FriBidiLevel fribidi_reorder_line(FriBidiFlags, const FriBidiCharType*, FriBidiStrIndex, FriBidiStrIndex, FriBidiParType, FriBidiLevel*, FriBidiChar*, FriBidiStrIndex*)’ declared with attribute ‘warn_unused_result’ [-Wunused-result]

6/175] Building CXX object src/CMakeFiles/otclient.dir/framework/platform/unixcrashhandler.cpp.o
[47/175] Building CXX object src/CMakeFiles/otclient.dir/framework/platform/unixplatform.cpp.o
[48/175] Building CXX object src/CMakeFiles/otclient.dir/framework/platform/win32platform.cpp.o
[49/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/demangle.cpp.o
[50/175] Building CXX object src/CMakeFiles/otclient.dir/framework/net/protocol.cpp.o
[51/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/math.cpp.o
[52/175] Building CXX object src/CMakeFiles/otclient.dir/framework/platform/win32crashhandler.cpp.o
[53/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/string.cpp.o
[54/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/time.cpp.o
[55/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/net.cpp.o
[56/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/uri.cpp.o
[57/175] Building CXX object src/CMakeFiles/otclient.dir/framework/stdext/qrcodegen.cpp.o
[58/175] Building CXX object src/CMakeFiles/otclient.dir/framework/util/color.cpp.o
[59/175] Building CXX object src/CMakeFiles/otclient.dir/framework/proxy/proxy.cpp.o
[60/175] Building CXX object src/CMakeFiles/otclient.dir/framework/proxy/proxy_client.cpp.o
[61/175] Building CXX object src/CMakeFiles/otclient.dir/framework/net/packet_player.cpp.o
[62/175] Building CXX object src/CMakeFiles/otclient.dir/framework/net/packet_recorder.cpp.o
[63/175] Building CXX object src/CMakeFiles/otclient.dir/framework/util/crypt.cpp.o
[64/175] Building CXX object src/CMakeFiles/otclient.dir/client/animator.cpp.o
[65/175] Building CXX object src/CMakeFiles/otclient.dir/client/attachedeffect.cpp.o
[66/175] Building CXX object src/CMakeFiles/otclient.dir/client/animatedtext.cpp.o
[67/175] Building CXX object src/CMakeFiles/otclient.dir/client/attachableobject.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/attachableobject.cpp:29:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/attachableobject.cpp:33:
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[68/175] Building CXX object src/CMakeFiles/otclient.dir/framework/luafunctions.cpp.o
[69/175] Building CXX object src/CMakeFiles/otclient.dir/client/attachedeffectmanager.cpp.o
[70/175] Building CXX object src/CMakeFiles/otclient.dir/client/creatures.cpp.o
[71/175] Building CXX object src/CMakeFiles/otclient.dir/client/container.cpp.o
[72/175] Building CXX object src/CMakeFiles/otclient.dir/client/client.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.cpp:23:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[73/175] Building CXX object src/CMakeFiles/otclient.dir/client/gameconfig.cpp.o
[74/175] Building CXX object src/CMakeFiles/otclient.dir/client/houses.cpp.o
[75/175] Building CXX object src/CMakeFiles/otclient.dir/client/creature.cpp.o
[76/175] Building CXX object src/CMakeFiles/otclient.dir/client/itemtype.cpp.o
[77/175] Building CXX object src/CMakeFiles/otclient.dir/client/effect.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/effect.cpp:26:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[78/175] Building CXX object src/CMakeFiles/otclient.dir/client/item.cpp.o
[79/175] Building CXX object src/CMakeFiles/otclient.dir/client/game.cpp.o
[80/175] Building CXX object src/CMakeFiles/otclient.dir/client/lightview.cpp.o
[81/175] Building CXX object src/CMakeFiles/otclient.dir/client/localplayer.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setFlatDamageHealing(uint16_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:524:20: warning: unused variable ‘oldFlatBonus’ [-Wunused-variable]
  524 |     const uint16_t oldFlatBonus = m_flatDamageHealing;
      |                    ^~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setAttackInfo(uint16_t, uint8_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:535:20: warning: unused variable ‘oldAttackValue’ [-Wunused-variable]
  535 |     const uint16_t oldAttackValue = m_attackValue;
      |                    ^~~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:536:19: warning: unused variable ‘oldAttackElement’ [-Wunused-variable]
  536 |     const uint8_t oldAttackElement = m_attackElement;
      |                   ^~~~~~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setConvertedDamage(double, uint8_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:548:18: warning: unused variable ‘oldConvertedDamage’ [-Wunused-variable]
  548 |     const double oldConvertedDamage = m_convertedDamage;
      |                  ^~~~~~~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:549:19: warning: unused variable ‘oldConvertedElement’ [-Wunused-variable]
  549 |     const uint8_t oldConvertedElement = m_convertedElement;
      |                   ^~~~~~~~~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setImbuements(double, double, double, double, double)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:562:18: warning: unused variable ‘oldLifeLeech’ [-Wunused-variable]
  562 |     const double oldLifeLeech = m_lifeLeech;
      |                  ^~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:563:18: warning: unused variable ‘oldManaLeech’ [-Wunused-variable]
  563 |     const double oldManaLeech = m_manaLeech;
      |                  ^~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:564:18: warning: unused variable ‘oldCritChance’ [-Wunused-variable]
  564 |     const double oldCritChance = m_critChance;
      |                  ^~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:565:18: warning: unused variable ‘oldCritDamage’ [-Wunused-variable]
  565 |     const double oldCritDamage = m_critDamage;
      |                  ^~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:566:18: warning: unused variable ‘oldOnslaught’ [-Wunused-variable]
  566 |     const double oldOnslaught = m_onslaught;
      |                  ^~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setDefenseInfo(uint16_t, uint16_t, double, double, uint16_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:583:20: warning: unused variable ‘oldDefense’ [-Wunused-variable]
  583 |     const uint16_t oldDefense = m_defense;
      |                    ^~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:584:20: warning: unused variable ‘oldArmor’ [-Wunused-variable]
  584 |     const uint16_t oldArmor = m_armor;
      |                    ^~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:585:18: warning: unused variable ‘oldMitigation’ [-Wunused-variable]
  585 |     const double oldMitigation = m_mitigation;
      |                  ^~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:586:18: warning: unused variable ‘oldDodge’ [-Wunused-variable]
  586 |     const double oldDodge = m_dodge;
      |                  ^~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:587:20: warning: unused variable ‘oldDamageReflection’ [-Wunused-variable]
  587 |     const uint16_t oldDamageReflection = m_damageReflection;
      |                    ^~~~~~~~~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setForgeBonuses(double, double, double)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:614:18: warning: unused variable ‘oldMomentum’ [-Wunused-variable]
  614 |     const double oldMomentum = m_momentum;
      |                  ^~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:615:18: warning: unused variable ‘oldTranscendence’ [-Wunused-variable]
  615 |     const double oldTranscendence = m_transcendence;
      |                  ^~~~~~~~~~~~~~~~
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:616:18: warning: unused variable ‘oldAmplification’ [-Wunused-variable]
  616 |     const double oldAmplification = m_amplification;
      |                  ^~~~~~~~~~~~~~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp: In member function ‘void LocalPlayer::setExperienceRate(Otc::ExperienceRate_t, uint16_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/localplayer.cpp:630:20: warning: unused variable ‘oldValue’ [-Wunused-variable]
  630 |     const uint16_t oldValue = m_experienceRates[type];
      |                    ^~~~~~~~
[82/175] Building CXX object src/CMakeFiles/otclient.dir/client/mapio.cpp.o
[83/175] Building CXX object src/CMakeFiles/otclient.dir/client/luavaluecasts_client.cpp.o
[84/175] Building CXX object src/CMakeFiles/otclient.dir/client/map.cpp.o
[85/175] Building CXX object src/CMakeFiles/otclient.dir/client/minimap.cpp.o
[86/175] Building CXX object src/CMakeFiles/otclient.dir/client/mapview.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/mapview.cpp:26:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[87/175] Building CXX object src/CMakeFiles/otclient.dir/client/outfit.cpp.o
[88/175] Building CXX object src/CMakeFiles/otclient.dir/client/missile.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/missile.cpp:27:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[89/175] Building CXX object src/CMakeFiles/otclient.dir/client/protocolcodes.cpp.o
[90/175] Building CXX object src/CMakeFiles/otclient.dir/client/position.cpp.o
[91/175] Building CXX object src/CMakeFiles/otclient.dir/client/player.cpp.o
[92/175] Building CXX object src/CMakeFiles/otclient.dir/client/luafunctions.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/luafunctions.cpp:26:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[93/175] Building CXX object src/CMakeFiles/otclient.dir/client/protocolgame.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/protocolgame.cpp: In member function ‘virtual void ProtocolGame::onRecv(const InputMessagePtr&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/protocolgame.cpp:70:23: warning: unused variable ‘padding’ [-Wunused-variable]
   70 |             const int padding = inputMessage->getU8();
      |                       ^~~~~~~
[94/175] Building CXX object src/CMakeFiles/otclient.dir/client/protocolgamesend.cpp.o
[95/175] Building CXX object src/CMakeFiles/otclient.dir/client/protocolgameparse.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/protocolgameparse.cpp: In member function ‘void ProtocolGame::parseCyclopediaCharacterInfo(const InputMessagePtr&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/protocolgameparse.cpp:4741:12: warning: enumeration value ‘CYCLOPEDIA_CHARACTERINFO_WHEEL’ not handled in switch [-Wswitch]
 4741 |     switch (type) {
      |            ^
[96/175] Building CXX object src/CMakeFiles/otclient.dir/client/spriteappearances.cpp.o
[97/175] Building CXX object src/CMakeFiles/otclient.dir/client/statictext.cpp.o
[98/175] Building CXX object src/CMakeFiles/otclient.dir/client/spritemanager.cpp.o
[99/175] Building CXX object src/CMakeFiles/otclient.dir/client/thing.cpp.o
[100/175] Building CXX object src/CMakeFiles/otclient.dir/client/towns.cpp.o
[101/175] Building CXX object src/CMakeFiles/otclient.dir/client/thingtype.cpp.o
[102/175] Building CXX object src/CMakeFiles/otclient.dir/client/thingtypemanager.cpp.o
[103/175] Building CXX object src/CMakeFiles/otclient.dir/client/tile.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/tile.cpp:27:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/tile.cpp:31:
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/tile.cpp: In member function ‘void Tile::drawCreature(const Point&, int, bool, uint8_t, const LightViewPtr&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/tile.cpp:137:17: warning: unused variable ‘newDest’ [-Wunused-variable]
  137 |     const auto& newDest = dest - drawElevation * g_drawPool.getScaleFactor();
      |                 ^~~~~~~
[104/175] Building CXX object src/CMakeFiles/otclient.dir/client/uicreature.cpp.o
[105/175] Building CXX object src/CMakeFiles/otclient.dir/client/uigraph.cpp.o
[106/175] Building CXX object src/CMakeFiles/otclient.dir/client/uiitem.cpp.o
[107/175] Building CXX object src/CMakeFiles/otclient.dir/client/uieffect.cpp.o
[108/175] Building CXX object src/CMakeFiles/otclient.dir/client/uimissile.cpp.o
[109/175] Building CXX object src/CMakeFiles/otclient.dir/client/uimapanchorlayout.cpp.o
[110/175] Building CXX object src/CMakeFiles/otclient.dir/client/uimap.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.cpp:23:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[111/175] Building CXX object src/CMakeFiles/otclient.dir/client/uisprite.cpp.o
[112/175] Building CXX object src/CMakeFiles/otclient.dir/androidmain.cpp.o
[113/175] Building CXX object src/CMakeFiles/otclient.dir/client/uiminimap.cpp.o
[114/175] Building CXX object src/CMakeFiles/otclient.dir/client/uiprogressrect.cpp.o
[115/175] Building CXX object src/CMakeFiles/otclient.dir/framework/core/adaptativeframecounter.cpp.o
[116/175] Building CXX object src/CMakeFiles/otclient.dir/main.cpp.o
In file included from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/client.h:27,
                 from /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/main.cpp:23:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/ui/uiwidget.h:89:18: warning: ‘virtual void UIWidget::draw(const Rect&, DrawPoolType)’ was hidden [-Woverloaded-virtual=]
   89 |     virtual void draw(const Rect& visibleRect, DrawPoolType drawPane);
      |                  ^~~~
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/client/uimap.h:38:10: note:   by ‘void UIMap::draw(DrawPoolType)’
   38 |     void draw(DrawPoolType drawPane);
      |          ^~~~
[117/175] Building CXX object src/CMakeFiles/otclient.dir/framework/input/mouse.cpp.o
[118/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/apngloader.cpp.o
[119/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/animatedtexture.cpp.o
[120/175] Building CXX object src/CMakeFiles/otclient.dir/framework/core/garbagecollection.cpp.o
[121/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/coordsbuffer.cpp.o
[122/175] Building CXX object src/CMakeFiles/otclient.dir/framework/core/graphicalapplication.cpp.o
[123/175] Building CXX object src/CMakeFiles/otclient.dir/framework/text/TextShaper.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/text/TextShaper.cpp: In function ‘std::vector<unsigned int> applyBidiReordering(const std::vector<unsigned int>&, TextDirection, std::vector<signed char>&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/text/TextShaper.cpp:139:23: warning: ignoring return value of ‘FriBidiLevel fribidi_reorder_line(FriBidiFlags, const FriBidiCharType*, FriBidiStrIndex, FriBidiStrIndex, FriBidiParType, FriBidiLevel*, FriBidiChar*, FriBidiStrIndex*)’ declared with attribute ‘warn_unused_result’ [-Wunused-result]
  139 |   fribidi_reorder_line(0, bidiTypes.data(), len, 0, parType,
      |   ~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  140 |                         levels.data(), visual.data(), nullptr);
      |                         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[124/175] Building CXX object src/CMakeFiles/otclient.dir/framework/text/LocaleShaping.cpp.o
[125/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/textureatlas.cpp.o
[126/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/bitmapfont.cpp.o
[127/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/cachedtext.cpp.o
[128/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/fontmanager.cpp.o
[129/175] Building CXX object src/CMakeFiles/otclient.dir/framework/text/TTFFont.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/text/TTFFont.cpp: In member function ‘void TTFFont::drawText(const std::u32string&, float, float, const ShapeParams&, const Color&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/text/TTFFont.cpp:461:14: warning: variable ‘bounds’ set but not used [-Wunused-but-set-variable]
  461 |   const Rect bounds = buildQuads(text32, params, quads);
      |              ^~~~~~
[130/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/graphics.cpp.o
[131/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/drawpool.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpool.cpp: In member function ‘DrawPool::PoolState DrawPool::getState(const TexturePtr&, Texture*, const Color&)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpool.cpp:171:93: warning: suggest parentheses around ‘&&’ within ‘||’ [-Wparentheses]
  171 |         if (texture->isEmpty() || !texture->canCacheInAtlas() || texture->canCacheInAtlas() && m_atlas) {
      |                                                                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~
[132/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/image.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/image.cpp: In member function ‘bool Image::nextMipmap()’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/image.cpp:186:17: warning: suggest parentheses around ‘&&’ within ‘||’ [-Wparentheses]
  186 |     if (iw == 1 && ih == 1 || m_pixels.empty())
      |         ~~~~~~~~^~~~~~~~~~
[133/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/painter.cpp.o
[134/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/paintershaderprogram.cpp.o
[135/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/particleaffector.cpp.o
[136/175] Building CXX object src/CMakeFiles/otclient.dir/framework/graphics/drawpoolmanager.cpp.o
/home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpoolmanager.cpp: In member function ‘void DrawPoolManager::init(uint16_t)’:
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpoolmanager.cpp:49:16: warning: enumeration value ‘LIGHT’ not handled in switch [-Wswitch]
   49 |         switch (static_cast<DrawPoolType>(i)) {
      |                ^
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpoolmanager.cpp:49:16: warning: enumeration value ‘FOREGROUND’ not handled in switch [-Wswitch]
Warning: /home/runner/work/ooo/ooo/Tibia/silnik/canary_test/testyy/src/framework/graphics/drawpoolmanager.cpp:49:16: warning: enumeration value ‘LAST’ not handled in switch [-Wswitch]

---

## Aktualizacja 2026-02-21 (GitHub Actions)

Zweryfikowane runy:
- `22246581096` (push, master)
- `22246594550` (workflow_dispatch, master)

Root-cause faila kompilacji:
- `Tibia/silnik/canary_test/testyy/src/framework/luafunctions.cpp:184-193`
- brak deklaracji `Http` i `g_http` podczas rejestracji Lua (`g_http`).

Wdrożona poprawka:
- dodany include `#include <framework/net/protocolhttp.h>` w `framework/luafunctions.cpp`.

Dodatkowe poprawki workflow Linux:
- poprawione ścieżki cleanup nested `.git` (`../oryginall/...`),
- dodane `libxmu-dev` do pakietów systemowych (zgodnie z ostrzeżeniami GLEW).

Uwaga:
- warning `git exit code 128` w `Post Checkout repository` był skutkiem nested `.git` i nie był główną przyczyną nieudanego buildu.
