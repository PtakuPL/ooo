#!/usr/bin/env python3
"""
NPC i18n detector - sprawdza czy plik NPC wymaga migracji i18n.
Użycie: python3 i18n_npc_detector.py <plik.lua>
Wypisuje: true/false

UWAGA: Ignoruje dynamiczne teksty (z konkatenacją ..)
"""

import re
import sys

def has_concatenation(line):
    """Sprawdź czy linia ma konkatenację (..)"""
    return ' .. ' in line or '"..' in line or '.. "' in line

def needs_migration(filepath):
    """Sprawdź czy plik NPC wymaga migracji i18n."""
    try:
        with open(filepath, "r", errors="ignore") as fp:
            content = fp.read()
    except:
        return False
    
    # 1. StdModule.say z text= BEZ i18nKey (tylko proste stringi)
    for m in re.finditer(r'(StdModule\.say\s*,\s*\{[^}]*?)text\s*=\s*"([^"]{5,})"', content, re.DOTALL):
        block = m.group(0)
        if 'i18nKey' not in block and not has_concatenation(block):
            return True
    
    # 2. npcHandler:say("...", npc, creature/player) - tylko proste stringi
    for m in re.finditer(r'npcHandler:say\(\s*"([^"]{5,})"\s*,\s*npc\s*,\s*(creature|player)\s*\)', content, re.DOTALL):
        line_start = content.rfind('\n', 0, m.start()) + 1
        line_end = content.find('\n', m.end())
        line = content[line_start:line_end] if line_end > 0 else content[line_start:]
        if not has_concatenation(line):
            return True
    
    # 3. addGreetKeyword bez i18nKey (tylko proste stringi)
    for m in re.finditer(r'(addGreetKeyword\s*\([^)]*?)(text\s*=\s*"[^"]+")([^}]*?\})', content, re.DOTALL):
        if 'i18nKey' not in m.group(0) and not has_concatenation(m.group(0)):
            return True
    
    # 4. addFarewellKeyword bez i18nKey (tylko proste stringi)
    for m in re.finditer(r'(addFarewellKeyword\s*\([^)]*?)(text\s*=\s*"[^"]+")([^}]*?\})', content, re.DOTALL):
        if 'i18nKey' not in m.group(0) and not has_concatenation(m.group(0)):
            return True
    
    # 5. npcConfig.voices z text bez i18nKey
    if 'npcConfig.voices' in content:
        start = content.find('npcConfig.voices')
        if start >= 0:
            brace_start = content.find('{', start)
            if brace_start >= 0:
                depth = 0
                brace_end = -1
                for i, c in enumerate(content[brace_start:], brace_start):
                    if c == '{':
                        depth += 1
                    elif c == '}':
                        depth -= 1
                        if depth == 0:
                            brace_end = i
                            break
                if brace_end >= 0:
                    block = content[brace_start:brace_end + 1]
                    if re.search(r'\{\s*text\s*=\s*"', block) and 'i18nKey' not in block:
                        return True
    
    # 6. setMessage(MESSAGE_GREET/FAREWELL/WALKAWAY/SENDTRADE, "...") - tylko proste stringi
    for m in re.finditer(r'npcHandler:setMessage\s*\(\s*MESSAGE_(GREET|FAREWELL|WALKAWAY|SENDTRADE)\s*,\s*"([^"]+)"', content):
        line_start = content.rfind('\n', 0, m.start()) + 1
        line_end = content.find('\n', m.end())
        line = content[line_start:line_end] if line_end > 0 else content[line_start:]
        if not has_concatenation(line):
            return True
    
    return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("false")
        sys.exit(0)
    
    result = needs_migration(sys.argv[1])
    print("true" if result else "false")
