#!/usr/bin/env python3
"""
Skrypt tłumaczenia monsters.json na język hiszpański (ES).
Wykorzystuje słowniki z translate_items_es.py.
"""

import json
import re
import sys
import os

# Importuj słowniki z items script
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from translate_items_es import (
    EXACT_TRANSLATIONS, WORD_DICT, FEMININE_NOUNS_ES,
    is_adjective, is_noun, agree_adjective, translate_compound
)

# === Dodatkowe tłumaczenia specyficzne dla potworów ===
MONSTER_EXACT = {
    # Common creatures
    "rat": "rata",
    "cave rat": "rata de cueva",
    "green frog": "rana verde",
    "toad": "sapo",
    "bug": "bicho",
    "rotworm": "gusano podrido",
    "carrion worm": "gusano carroñero",
    "larva": "larva",
    "spider": "araña",
    "poison spider": "araña venenosa",
    "giant spider": "araña gigante",
    "tarantula": "tarántula",
    "snake": "serpiente",
    "cobra": "cobra",
    "python": "pitón",
    "wolf": "lobo",
    "war wolf": "lobo de guerra",
    "winter wolf": "lobo invernal",
    "bear": "oso",
    "polar bear": "oso polar",
    "bat": "murciélago",
    "vampire bat": "murciélago vampiro",
    "dog": "perro",
    "hyena": "hiena",
    "lion": "león",
    "tiger": "tigre",
    "elephant": "elefante",
    "mammoth": "mamut",
    "deer": "ciervo",
    "rabbit": "conejo",
    "chicken": "gallina",
    "pig": "cerdo",
    "sheep": "oveja",
    "cow": "vaca",
    "horse": "caballo",
    "donkey": "burro",
    "cat": "gato",
    "skunk": "mofeta",
    "badger": "tejón",
    "fox": "zorro",
    "wild horse": "caballo salvaje",
    "crab": "cangrejo",
    "turtle": "tortuga",
    "crocodile": "cocodrilo",
    "wasp": "avispa",
    "bee": "abeja",
    "scorpion": "escorpión",
    "beetle": "escarabajo",
    "scarab": "escarabajo",
    "centipede": "ciempiés",
    "slime": "limo",
    "acid blob": "gota ácida",
    "lava blob": "gota de lava",
    "death blob": "gota mortal",
    "dragon": "dragón",
    "dragon lord": "señor dragón",
    "dragon hatchling": "cría de dragón",
    "frost dragon": "dragón de hielo",
    "undead dragon": "dragón no-muerto",
    "ghastly dragon": "dragón espectral",
    "wyrm": "wyrm",
    "elder wyrm": "wyrm anciano",
    "hydra": "hidra",
    "serpent spawn": "engendro serpiente",
    "sea serpent": "serpiente marina",
    "demon": "demonio",
    "fire devil": "diablo de fuego",
    "dark torturer": "torturador oscuro",
    "destroyer": "destructor",
    "juggernaut": "juggernaut",
    "plaguesmith": "herrero de plagas",
    "skeleton": "esqueleto",
    "skeleton warrior": "esqueleto guerrero",
    "undead gladiator": "gladiador no-muerto",
    "ghoul": "ghoul",
    "mummy": "momia",
    "vampire": "vampiro",
    "vampire lord": "señor vampiro",
    "lich": "liche",
    "bonelord": "señor de huesos",
    "priestess": "sacerdotisa",
    "banshee": "banshee",
    "ghost": "fantasma",
    "spectre": "espectro",
    "phantom": "fantasma",
    "wraith": "espectro",
    "gravedigger": "sepulturero",
    "necromancer": "nigromante",
    "dark magician": "mago oscuro",
    "warlock": "brujo",
    "witch": "bruja",
    "orc": "orco",
    "orc warrior": "guerrero orco",
    "orc leader": "líder orco",
    "orc berserker": "berserker orco",
    "orc shaman": "chamán orco",
    "orc rider": "jinete orco",
    "orc spearman": "lancero orco",
    "orc warlord": "señor de la guerra orco",
    "troll": "trol",
    "troll champion": "campeón trol",
    "island troll": "trol de isla",
    "swamp troll": "trol de pantano",
    "frost troll": "trol de hielo",
    "goblin": "goblin",
    "goblin assassin": "asesino goblin",
    "goblin leader": "líder goblin",
    "goblin scavenger": "carroñero goblin",
    "minotaur": "minotauro",
    "minotaur guard": "guardia minotauro",
    "minotaur mage": "mago minotauro",
    "minotaur archer": "arquero minotauro",
    "dwarf": "enano",
    "dwarf soldier": "soldado enano",
    "dwarf guard": "guardia enano",
    "dwarf geomancer": "geomante enano",
    "cyclops": "cíclope",
    "cyclops drone": "cíclope zángano",
    "cyclops smith": "herrero cíclope",
    "amazon": "amazona",
    "assassin": "asesino",
    "bandit": "bandido",
    "dark monk": "monje oscuro",
    "monk": "monje",
    "hunter": "cazador",
    "smuggler": "contrabandista",
    "pirate": "pirata",
    "pirate buccaneer": "bucanero pirata",
    "pirate corsair": "corsario pirata",
    "pirate cutthroat": "pirata despiadado",
    "pirate marauder": "pirata merodeador",
    "pirate skeleton": "esqueleto pirata",
    "pirate ghost": "fantasma pirata",
    "barbarian": "bárbaro",
    "barbarian headsplitter": "bárbaro rompecabezas",
    "barbarian bloodwalker": "bárbaro caminante de sangre",
    "barbarian skullhunter": "bárbaro cazacráneos",
    "barbarian brutetamer": "bárbaro domador de brutos",
    "valkyrie": "valquiria",
    "mad scientist": "científico loco",
    "dark apprentice": "aprendiz oscuro",
    "elder beholder": "beholder anciano",
    "energy elemental": "elemental de energía",
    "fire elemental": "elemental de fuego",
    "water elemental": "elemental de agua",
    "earth elemental": "elemental de tierra",
    "ice elemental": "elemental de hielo",
    "massive fire elemental": "elemental de fuego masivo",
    "massive water elemental": "elemental de agua masivo",
    "massive earth elemental": "elemental de tierra masivo",
    "massive energy elemental": "elemental de energía masivo",
    "djinn": "djinn",
    "blue djinn": "djinn azul",
    "green djinn": "djinn verde",
    "efreet": "efrit",
    "marid": "marid",
    "grim reaper": "segador sombrío",
    "wyvern": "guiverno",
    "gargoyle": "gárgola",
    "stone golem": "gólem de piedra",
    "iron golem": "gólem de hierro",
    "diamond golem": "gólem de diamante",
    "crystal golem": "gólem de cristal",
    "war golem": "gólem de guerra",
    "golem": "gólem",
    "behemoth": "behemoth",
    "medusa": "medusa",
    "nightmare": "pesadilla",
    "bog raider": "asaltante del pantano",
    "hero": "héroe",
    "black knight": "caballero negro",
    "dark knight": "caballero oscuro",
    "dragon knight": "caballero dragón",
    "frost giant": "gigante de hielo",
    "ancient scarab": "escarabajo antiguo",
    "giant scarab": "escarabajo gigante",
    "son of verminor": "hijo de Verminor",
    "hand of cursed fate": "mano del destino maldito",
    "lost soul": "alma perdida",
    "haunted treeling": "arbolito embrujado",
    "elder forest fury": "furia del bosque anciana",
    "forest fury": "furia del bosque",
    "carniphila": "carniphila",
    "wilting leaf golem": "gólem de hoja marchita",
    "swamp troll": "trol de pantano",
    "quara": "quara",
    "quara predator": "depredador quara",
    "quara hydromancer": "hidromante quara",
    "quara mantassin": "mantasín quara",
    "quara pincher": "pinzador quara",
    "quara constrictor": "constrictor quara",
    "deepling": "deepling",
    "deepling warrior": "guerrero deepling",
    "deepling guard": "guardia deepling",
    "deepling scout": "explorador deepling",
    "deepling spellsinger": "cantor de hechizos deepling",
    "kongra": "kongra",
    "sibang": "sibang",
    "merlkin": "merlkin",
    "terror bird": "ave del terror",
    "stampor": "stampor",
    "bonebeast": "bestia de huesos",
    "undead mine worker": "minero no-muerto",
    "crypt shambler": "vagabundo de cripta",
    "rot elemental": "elemental de putrefacción",
    "earth guardian": "guardián de tierra",
    "mad mage": "mago loco",
    "dark wizard": "mago oscuro",
    "black sheep": "oveja negra",
    "frost spider": "araña de hielo",
    "crystal spider": "araña de cristal",
    "wailing widow": "viuda sollozante",
    "poison frog": "rana venenosa",
    "thornback tortoise": "tortuga de espinas",
    "blood crab": "cangrejo de sangre",
    "massive water elemental": "elemental de agua masivo",
}

MONSTER_WORD_DICT = {
    "aggressive": "agresivo",
    "ancient": "antiguo",
    "baby": "bebé",
    "blazing": "llameante",
    "blood": "sangre",
    "bone": "hueso",
    "burning": "ardiente",
    "cave": "cueva",
    "corrupted": "corrompido",
    "crazed": "enloquecido",
    "crystal": "cristal",
    "cursed": "maldito",
    "dark": "oscuro",
    "deadly": "mortal",
    "death": "muerte",
    "deathly": "mortífero",
    "deep": "profundo",
    "dire": "terrible",
    "doom": "perdición",
    "elder": "anciano",
    "elite": "élite",
    "enraged": "enfurecido",
    "eternal": "eterno",
    "evil": "malvado",
    "fallen": "caído",
    "fierce": "feroz",
    "fire": "fuego",
    "forest": "bosque",
    "frenzied": "frenético",
    "frost": "hielo",
    "fury": "furia",
    "giant": "gigante",
    "gloomy": "sombrío",
    "great": "gran",
    "greater": "mayor",
    "guardian": "guardián",
    "haunted": "embrujado",
    "hellfire": "fuego infernal",
    "hellish": "infernal",
    "high": "alto",
    "ice": "hielo",
    "infernal": "infernal",
    "jungle": "jungla",
    "king": "rey",
    "lesser": "menor",
    "lost": "perdido",
    "mad": "loco",
    "marsh": "pantano",
    "massive": "masivo",
    "master": "maestro",
    "mighty": "poderoso",
    "mountain": "montaña",
    "mutant": "mutante",
    "mystic": "místico",
    "noble": "noble",
    "ominous": "ominoso",
    "outcast": "paria",
    "pirate": "pirata",
    "plague": "plaga",
    "poison": "veneno",
    "raging": "furioso",
    "ravenous": "voraz",
    "renegade": "renegado",
    "rift": "grieta",
    "rogue": "pícaro",
    "rotten": "podrido",
    "savage": "salvaje",
    "shadow": "sombra",
    "solitary": "solitario",
    "spectral": "espectral",
    "stone": "piedra",
    "storm": "tormenta",
    "sun": "sol",
    "swamp": "pantano",
    "thunder": "trueno",
    "twisted": "retorcido",
    "undead": "no-muerto",
    "unholy": "profano",
    "venom": "veneno",
    "vicious": "vicioso",
    "void": "vacío",
    "war": "guerra",
    "wild": "salvaje",
    "winter": "invierno",
    "withered": "marchito",
    "young": "joven",
    "warrior": "guerrero",
    "guard": "guardia",
    "mage": "mago",
    "archer": "arquero",
    "scout": "explorador",
    "leader": "líder",
    "lord": "señor",
    "hunter": "cazador",
    "knight": "caballero",
    "priest": "sacerdote",
    "priestess": "sacerdotisa",
    "shaman": "chamán",
    "berserker": "berserker",
    "champion": "campeón",
    "captain": "capitán",
    "commander": "comandante",
    "general": "general",
    "chieftain": "jefe tribal",
    "warlord": "señor de la guerra",
    "rider": "jinete",
    "worker": "trabajador",
    "soldier": "soldado",
    "minion": "secuaz",
    "servant": "sirviente",
    "henchman": "secuaz",
    "slave": "esclavo",
    "spawn": "engendro",
    "hatchling": "cría",
    "whelp": "cachorro",
    "pup": "cachorro",
    "cub": "cachorro",
    "brood": "cría",
    "larva": "larva",
    "drone": "zángano",
    "queen": "reina",
    "broodmother": "madre de crías",
    "matriarch": "matriarca",
    "patriarch": "patriarca",
    "outlaw": "forajido",
    "ravager": "devastador",
    "stalker": "acechador",
    "lurker": "acechador",
    "crawler": "reptador",
    "creeper": "reptador",
    "seeker": "buscador",
    "warden": "guardián",
    "keeper": "guardián",
    "sentinel": "centinela",
    "protector": "protector",
    "defender": "defensor",
    "avenger": "vengador",
    "slayer": "matador",
    "reaper": "segador",
    "bringer": "portador",
    "herald": "heraldo",
    "harbinger": "presagio",
    "prophet": "profeta",
    "seer": "vidente",
    "oracle": "oráculo",
    "hermit": "ermitaño",
    "pilgrim": "peregrino",
    "nomad": "nómada",
    "wanderer": "vagabundo",
}


def translate_monster_name(name):
    """Translate a monster name to Spanish."""
    if not name:
        return name

    # Merge monster dictionaries into items dictionaries for translate_compound
    for k, v in MONSTER_WORD_DICT.items():
        if k not in WORD_DICT:
            WORD_DICT[k] = v
    for k, v in MONSTER_EXACT.items():
        if k not in EXACT_TRANSLATIONS:
            EXACT_TRANSLATIONS[k] = v

    # Add monster-specific feminine nouns
    FEMININE_NOUNS_ES.update({
        "araña", "serpiente", "rata", "rana", "tarántula", "cobra", "hidra",
        "medusa", "pesadilla", "amazona", "valquiria", "bruja", "momia",
        "banshee", "sacerdotisa", "viuda", "gárgola", "hiena", "oveja",
        "vaca", "gallina", "abeja", "avispa", "babosa", "hormiga",
        "mariposa", "polilla", "luciérnaga", "larva", "cría", "sanguijuela",
        "oruga", "tortuga", "cucaracha", "planta",
    })

    name_stripped = name.strip()
    name_lower = name_stripped.lower()

    # Remove article "a " or "an "
    article_removed = False
    base_name = name_lower
    if name_lower.startswith("a "):
        base_name = name_lower[2:]
        article_removed = True
    elif name_lower.startswith("an "):
        base_name = name_lower[3:]
        article_removed = True

    # Check monster-specific exact match
    if base_name in MONSTER_EXACT:
        result = MONSTER_EXACT[base_name]
        if article_removed:
            # Add Spanish article
            if result and result[0] in 'aeiouáéíóú':
                return f"un {result}" if not any(result.startswith(f) for f in FEMININE_NOUNS_ES) else f"una {result}"
            # Check gender for article
            first_word = result.split()[0] if result else ""
            if first_word in FEMININE_NOUNS_ES:
                return f"una {result}"
            return f"un {result}"
        return result

    # Check items EXACT_TRANSLATIONS
    if base_name in EXACT_TRANSLATIONS:
        result = EXACT_TRANSLATIONS[base_name]
        if article_removed:
            first_word = result.split()[0] if result else ""
            if first_word in FEMININE_NOUNS_ES:
                return f"una {result}"
            return f"un {result}"
        return result

    # Try translate_compound (from items)
    compound_result = translate_compound(base_name)
    if compound_result.lower() != base_name:
        if article_removed:
            first_word = compound_result.split()[0] if compound_result else ""
            if first_word in FEMININE_NOUNS_ES:
                return f"una {compound_result}"
            return f"un {compound_result}"
        return compound_result

    # Try with monster-specific word dict
    words = base_name.split()
    if len(words) >= 2:
        translated_words = []
        any_translated = False
        for w in words:
            if w in MONSTER_WORD_DICT:
                translated_words.append(MONSTER_WORD_DICT[w])
                any_translated = True
            elif w in WORD_DICT and WORD_DICT[w]:
                translated_words.append(WORD_DICT[w])
                any_translated = True
            else:
                translated_words.append(w)

        if any_translated:
            result = " ".join(translated_words)
            if article_removed:
                return f"un {result}"
            return result

    # Fallback - keep original (proper noun)
    return name_stripped


def main():
    monsters_path = "/home/ptaku/serweryt/Tibia/silnik/canary_test/i18n/es/monsters.json"
    backup_path = monsters_path + ".bak"

    print(f"📖 Wczytywanie {monsters_path}...")

    with open(monsters_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    total = len(data)
    es_prefix_count = 0
    translated_count = 0
    kept_original_count = 0

    print(f"📊 Znaleziono {total} wpisów")

    # Backup
    with open(backup_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"💾 Backup zapisany: {backup_path}")

    # Process
    new_data = {}
    for key, value in data.items():
        if isinstance(value, str) and value.startswith("[ES] "):
            es_prefix_count += 1
            original_name = value[5:]
            translated = translate_monster_name(original_name)

            if translated.lower() != original_name.lower():
                translated_count += 1
                new_data[key] = translated
            else:
                kept_original_count += 1
                new_data[key] = original_name
        else:
            new_data[key] = value

    print(f"\n📊 Wyniki:")
    print(f"   Wpisów z [ES]: {es_prefix_count}")
    print(f"   ✅ Przetłumaczonych: {translated_count}")
    print(f"   ⚠️ Zachowano oryginał (bez [ES]): {kept_original_count}")
    print(f"   📝 Bez zmian (już przetłumaczone): {total - es_prefix_count}")

    with open(monsters_path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Zapisano: {monsters_path}")


if __name__ == "__main__":
    main()
