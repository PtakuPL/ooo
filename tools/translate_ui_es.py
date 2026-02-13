#!/usr/bin/env python3
"""
Skrypt tłumaczenia otclient_modules.json i html.json na język hiszpański (ES).
Obsługuje tekst UI klienta gry i strony internetowej.
"""

import json
import re
import sys
import os

# ====================
# UI Translation Dict
# ====================
UI_TRANSLATIONS = {
    # Common UI elements
    "Cancel": "Cancelar",
    "Ok": "Aceptar",
    "OK": "Aceptar",
    "Yes": "Sí",
    "No": "No",
    "Apply": "Aplicar",
    "Save": "Guardar",
    "Close": "Cerrar",
    "Open": "Abrir",
    "Add": "Agregar",
    "Remove": "Eliminar",
    "Delete": "Eliminar",
    "Edit": "Editar",
    "Create": "Crear",
    "Update": "Actualizar",
    "Search": "Buscar",
    "Filter": "Filtrar",
    "Sort": "Ordenar",
    "Refresh": "Actualizar",
    "Reset": "Restablecer",
    "Clear": "Limpiar",
    "Select": "Seleccionar",
    "Confirm": "Confirmar",
    "Continue": "Continuar",
    "Back": "Volver",
    "Next": "Siguiente",
    "Previous": "Anterior",
    "Submit": "Enviar",
    "Send": "Enviar",
    "Load": "Cargar",
    "Import": "Importar",
    "Export": "Exportar",
    "Copy": "Copiar",
    "Paste": "Pegar",
    "Cut": "Cortar",
    "Undo": "Deshacer",
    "Redo": "Rehacer",
    "Help": "Ayuda",
    "Info": "Info",
    "About": "Acerca de",
    "Settings": "Configuración",
    "Options": "Opciones",
    "Preferences": "Preferencias",
    "Configuration": "Configuración",
    "Profile": "Perfil",
    "Account": "Cuenta",
    "Login": "Iniciar Sesión",
    "Logout": "Cerrar Sesión",
    "Register": "Registrarse",
    "Password": "Contraseña",
    "Username": "Nombre de Usuario",
    "Email": "Correo Electrónico",
    "Name": "Nombre",
    "Description": "Descripción",
    "Type": "Tipo",
    "Status": "Estado",
    "Level": "Nivel",
    "Experience": "Experiencia",
    "Health": "Salud",
    "Mana": "Maná",
    "Speed": "Velocidad",
    "Attack": "Ataque",
    "Defense": "Defensa",
    "Armor": "Armadura",
    "Magic": "Magia",
    "Distance": "Distancia",
    "Melee": "Cuerpo a Cuerpo",
    "Range": "Rango",
    "Damage": "Daño",
    "Healing": "Curación",
    "Protection": "Protección",
    "Resistance": "Resistencia",
    "Immunity": "Inmunidad",
    "Weakness": "Debilidad",
    "Strength": "Fuerza",
    "Dexterity": "Destreza",
    "Intelligence": "Inteligencia",
    "Wisdom": "Sabiduría",
    "Vitality": "Vitalidad",
    "Stamina": "Estamina",
    "Soul": "Alma",
    "Capacity": "Capacidad",
    "Weight": "Peso",
    "Value": "Valor",
    "Price": "Precio",
    "Cost": "Costo",
    "Amount": "Cantidad",
    "Quantity": "Cantidad",
    "Total": "Total",
    "Free": "Gratis",
    "Premium": "Premium",
    "VIP": "VIP",
    "Online": "En línea",
    "Offline": "Desconectado",
    "Server": "Servidor",
    "Client": "Cliente",
    "World": "Mundo",
    "Character": "Personaje",
    "Player": "Jugador",
    "Monster": "Monstruo",
    "NPC": "NPC",
    "Item": "Objeto",
    "Spell": "Hechizo",
    "Skill": "Habilidad",
    "Quest": "Misión",
    "Achievement": "Logro",
    "Map": "Mapa",
    "Minimap": "Minimapa",
    "Chat": "Chat",
    "Message": "Mensaje",
    "Channel": "Canal",
    "Trade": "Comercio",
    "Buy": "Comprar",
    "Sell": "Vender",
    "Offer": "Oferta",
    "Inventory": "Inventario",
    "Equipment": "Equipo",
    "Backpack": "Mochila",
    "Container": "Contenedor",
    "Depot": "Depósito",
    "Bank": "Banco",
    "Market": "Mercado",
    "Store": "Tienda",
    "Shop": "Tienda",
    "Auction": "Subasta",
    "Guild": "Gremio",
    "Party": "Grupo",
    "Friend": "Amigo",
    "Friends": "Amigos",
    "Enemy": "Enemigo",
    "Enemies": "Enemigos",
    "Ignore": "Ignorar",
    "Block": "Bloquear",
    "Mute": "Silenciar",
    "Report": "Reportar",
    "Bug": "Error",
    "Warning": "Advertencia",
    "Error": "Error",
    "Success": "Éxito",
    "Failed": "Fallido",
    "Loading...": "Cargando...",
    "Loading": "Cargando",
    "Saving...": "Guardando...",
    "Connecting...": "Conectando...",
    "Disconnected": "Desconectado",
    "Connected": "Conectado",
    "Timeout": "Tiempo agotado",
    "Retry": "Reintentar",
    "Reconnect": "Reconectar",

    # Game-specific UI
    "Battle": "Batalla",
    "Use": "Usar",
    "Use with crosshair": "Usar con punto de mira",
    "Use on target": "Usar en objetivo",
    "Use on yourself": "Usar en ti mismo",
    "Equip/unequip": "Equipar/desequipar",
    "Assign Object": "Asignar Objeto",
    "Assign Spell": "Asignar Hechizo",
    "Assign Text": "Asignar Texto",
    "Select Object": "Seleccionar Objeto",
    "Parameter": "Parámetro",
    "words": "palabras",
    "name": "nombre",
    "Send automatically": "Enviar automáticamente",
    "Text:": "Texto:",
    "Protocol": "Protocolo",
    "Port": "Puerto",
    "Host": "Servidor",
    "New Server": "Nuevo Servidor",
    "Remove from Loot List": "Quitar de Lista de Botín",
    "Hide party members": "Ocultar miembros del grupo",
    "Hide non-skull players": "Ocultar jugadores sin calavera",
    "Hide monsters": "Ocultar monstruos",
    "Hide Npcs": "Ocultar NPCs",
    "Hide players": "Ocultar jugadores",
    "Music volume: %d": "Volumen de música: %d",
    "Enable music sound": "Activar sonido de música",
    "Enable audio": "Activar audio",
    "Please enter a group name:": "Por favor ingresa un nombre de grupo:",
    "Add VIP group (User-Created groups left: %s)": "Agregar grupo VIP (grupos creados por usuario restantes: %s)",
    "Please enter a character name": "Por favor ingresa un nombre de personaje",
    "Add to VIP list": "Agregar a lista VIP",
}

# Game window / client-specific UI strings
GAME_UI = {
    "Hotkeys": "Teclas Rápidas",
    "Console": "Consola",
    "Health Bar": "Barra de Salud",
    "Mana Bar": "Barra de Maná",
    "Experience Bar": "Barra de Experiencia",
    "Skills": "Habilidades",
    "Spells": "Hechizos",
    "VIP List": "Lista VIP",
    "Battle List": "Lista de Batalla",
    "Quest Log": "Registro de Misiones",
    "Prey": "Presa",
    "Imbuing": "Imbuimiento",
    "Reward Wall": "Muro de Recompensas",
    "Bestiary": "Bestiario",
    "Bosstiary": "Bostiario",
    "Compendium": "Compendio",
    "Cyclopedia": "Ciclopedia",
    "Analytics Selector": "Selector de Análisis",
    "Store Inbox": "Buzón de Tienda",
    "Loot": "Botín",
    "Loot List": "Lista de Botín",
    "Quick Loot": "Saqueo Rápido",
    "Stop": "Detener",
    "Logout": "Cerrar Sesión",
    "Change Outfit": "Cambiar Atuendo",
    "Mount": "Montura",
    "Set Outfit": "Configurar Atuendo",
    "Addon 1": "Complemento 1",
    "Addon 2": "Complemento 2",
    "Head": "Cabeza",
    "Body": "Cuerpo",
    "Legs": "Piernas",
    "Feet": "Pies",
    "Primary": "Primario",
    "Secondary": "Secundario",
    "Detail": "Detalle",
    "Preview": "Vista Previa",
    "Rotate": "Rotar",
    "Follow": "Seguir",
    "Attack": "Atacar",
    "Chase Opponent": "Perseguir Oponente",
    "Stand Still": "Quedarse Quieto",
    "Full Attack": "Ataque Total",
    "Full Defense": "Defensa Total",
    "Balanced": "Equilibrado",
    "Offensive": "Ofensivo",
    "Defensive": "Defensivo",
    "Secure Mode": "Modo Seguro",
    "PvP Mode": "Modo PvP",
    "Dove": "Paloma",
    "White Hand": "Mano Blanca",
    "Yellow Hand": "Mano Amarilla",
    "Red Fist": "Puño Rojo",
    "Walk": "Caminar",
    "Turn North": "Girar al Norte",
    "Turn South": "Girar al Sur",
    "Turn East": "Girar al Este",
    "Turn West": "Girar al Oeste",
    "Move Up": "Mover Arriba",
    "Move Down": "Mover Abajo",
    "Auto Walk": "Caminar Automático",
    "North": "Norte",
    "South": "Sur",
    "East": "Este",
    "West": "Oeste",
    "North East": "Noreste",
    "North West": "Noroeste",
    "South East": "Sureste",
    "South West": "Suroeste",
    "Look": "Mirar",
    "Look At": "Mirar",
    "Inspect": "Inspeccionar",
    "Browse Field": "Examinar Campo",
    "Set Mark": "Poner Marca",
    "Copy Name": "Copiar Nombre",
    "Add to VIP": "Agregar a VIP",
    "Remove from VIP": "Quitar de VIP",
    "Message to": "Mensaje a",
    "Private Message": "Mensaje Privado",
    "Invite to Party": "Invitar al Grupo",
    "Join Party": "Unirse al Grupo",
    "Leave Party": "Dejar el Grupo",
    "Enable Shared Experience": "Activar Experiencia Compartida",
    "Disable Shared Experience": "Desactivar Experiencia Compartida",
    "Pass Leadership": "Pasar Liderazgo",
    "Exclude from Party": "Excluir del Grupo",
    "Open Channel": "Abrir Canal",
    "Close Channel": "Cerrar Canal",
    "New Channel": "Nuevo Canal",
    "Default": "Predeterminado",
    "Channel List": "Lista de Canales",
    "Server Log": "Registro del Servidor",
    "Game Chat": "Chat del Juego",
    "Help Channel": "Canal de Ayuda",
    "Rule Violation": "Violación de Reglas",
    "Trade Channel": "Canal de Comercio",
    "World Chat": "Chat Mundial",
    "English Chat": "Chat en Inglés",
    "Advertising": "Publicidad",
    "Loot Channel": "Canal de Botín",
    "Save Messages": "Guardar Mensajes",
    "Clear Messages": "Limpiar Mensajes",
    "Font Size": "Tamaño de Fuente",
    "Show Timestamps": "Mostrar Marcas de Tiempo",
    "Show Level": "Mostrar Nivel",
    "Ignore": "Ignorar",
    "Ignore List": "Lista de Ignorados",
    "Multiline": "Multilínea",
    "Enter Game": "Entrar al Juego",
    "Access Account": "Acceder a la Cuenta",
    "Create Account": "Crear Cuenta",
    "Change Password": "Cambiar Contraseña",
    "Change Email": "Cambiar Email",
    "Lost Account": "Cuenta Perdida",
    "Game World": "Mundo del Juego",
    "Select Character": "Seleccionar Personaje",
    "New Character": "Nuevo Personaje",
    "Delete Character": "Eliminar Personaje",
    "Recovery Key": "Clave de Recuperación",
    "Two-Factor Authentication": "Autenticación de Dos Factores",
    "Remember Account": "Recordar Cuenta",
    "Remember Password": "Recordar Contraseña",
    "Stay Logged In": "Mantener Sesión",
    "Reconnecting...": "Reconectando...",
    "Please wait...": "Por favor espera...",
    "Connection Lost": "Conexión Perdida",
    "Could not connect": "No se pudo conectar",
    "Version mismatch": "Versión incompatible",
    "Invalid account": "Cuenta inválida",
    "Invalid password": "Contraseña inválida",
    "Account banned": "Cuenta baneada",
    "Character locked": "Personaje bloqueado",
    "Maintenance": "Mantenimiento",
    "You are dead": "Has muerto",
    "You gained": "Has ganado",
    "You lost": "Has perdido",
    "You advanced to": "Has avanzado a",
    "level": "nivel",
    "You advance in": "Has avanzado en",
    "You learned": "Has aprendido",
    "magic level": "nivel mágico",
    "You have been killed": "Has sido asesinado",
    "You are poisoned": "Estás envenenado",
    "You are burning": "Estás ardiendo",
    "You are electrified": "Estás electrificado",
    "You are cursed": "Estás maldito",
    "You are paralyzed": "Estás paralizado",
    "You are drowning": "Te estás ahogando",
    "You are freezing": "Te estás congelando",
    "You are bleeding": "Estás sangrando",
    "You are dazzled": "Estás deslumbrado",
    "Graphics": "Gráficos",
    "Sound": "Sonido",
    "Interface": "Interfaz",
    "Controls": "Controles",
    "General": "General",
    "Advanced": "Avanzado",
    "Performance": "Rendimiento",
    "Framerate": "Tasa de cuadros",
    "Resolution": "Resolución",
    "Fullscreen": "Pantalla Completa",
    "Windowed": "Ventana",
    "VSync": "VSync",
    "Anti-Aliasing": "Anti-Aliasing",
    "Ambient Light": "Luz Ambiental",
    "Brightness": "Brillo",
    "Contrast": "Contraste",
    "Volume": "Volumen",
    "Sound Effects": "Efectos de Sonido",
    "Music": "Música",
    "Notifications": "Notificaciones",
    "Show Names": "Mostrar Nombres",
    "Show Health Bars": "Mostrar Barras de Salud",
    "Show Text Effects": "Mostrar Efectos de Texto",
    "Show Spells": "Mostrar Hechizos",
    "Classic Control": "Control Clásico",
    "Action Bars": "Barras de Acción",
    "Hotkey": "Tecla Rápida",
    "Binding": "Asignación",
    "Input": "Entrada",
    "Output": "Salida",
    "Language": "Idioma",
    "Outfit": "Atuendo",
    "Outfits": "Atuendos",
    "Familiar": "Familiar",
    "Wings": "Alas",
    "Aura": "Aura",
    "Effects": "Efectos",
    "Shader": "Shader",
    "Title": "Título",
    "Show": "Mostrar",
    "Hide": "Ocultar",
    "Enable": "Activar",
    "Disable": "Desactivar",
    "On": "Activado",
    "Off": "Desactivado",
    "True": "Verdadero",
    "False": "Falso",
    "None": "Ninguno",
    "All": "Todos",
    "Custom": "Personalizado",
    "Default": "Predeterminado",
    "Auto": "Automático",
    "Manual": "Manual",
    "Enabled": "Activado",
    "Disabled": "Desactivado",
    "Active": "Activo",
    "Inactive": "Inactivo",
    "Locked": "Bloqueado",
    "Unlocked": "Desbloqueado",
    "Visible": "Visible",
    "Hidden": "Oculto",
    "Public": "Público",
    "Private": "Privado",
    "Shared": "Compartido",
    "Personal": "Personal",
    "Global": "Global",
    "Local": "Local",
    "Recent": "Reciente",
    "Favorites": "Favoritos",
    "History": "Historial",
    "Log": "Registro",
    "Details": "Detalles",
    "Summary": "Resumen",
    "Overview": "Vista General",
    "Statistics": "Estadísticas",
    "Rankings": "Clasificaciones",
    "Highscores": "Puntuaciones Altas",
    "Leaderboard": "Tabla de Clasificación",
}

# Merge all translations
ALL_UI = {}
ALL_UI.update(UI_TRANSLATIONS)
ALL_UI.update(GAME_UI)


def translate_ui_file(filepath):
    """Translate a UI JSON file by matching known UI strings."""
    basename = os.path.basename(filepath)

    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    total = len(data)
    es_prefix_count = 0
    translated_count = 0
    kept_count = 0

    new_data = {}
    for key, value in data.items():
        if isinstance(value, str) and value.startswith("[ES] "):
            es_prefix_count += 1
            en_text = value[5:]

            # Try exact match
            if en_text in ALL_UI:
                new_data[key] = ALL_UI[en_text]
                translated_count += 1
            # Try case-insensitive match
            elif en_text.strip() in ALL_UI:
                new_data[key] = ALL_UI[en_text.strip()]
                translated_count += 1
            else:
                # Try partial translations for common patterns
                translated = try_pattern_translate(en_text)
                if translated:
                    new_data[key] = translated
                    translated_count += 1
                else:
                    # Remove [ES] prefix, keep original
                    new_data[key] = en_text
                    kept_count += 1
        else:
            new_data[key] = value

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)

    print(f"📊 {basename}:")
    print(f"   Wpisów z [ES]: {es_prefix_count}")
    print(f"   ✅ Przetłumaczonych: {translated_count}")
    print(f"   ⚠️ Zachowano oryginał: {kept_count}")
    print(f"   📝 Już przetłumaczone: {total - es_prefix_count}")


def try_pattern_translate(text):
    """Try to translate UI strings using common patterns."""
    t = text.strip()

    # "Show/hide X"
    m = re.match(r'^Show/hide\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Mostrar/ocultar {content}"

    # "Enable/Disable X"
    m = re.match(r'^Enable/Disable\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Activar/Desactivar {content}"

    # "Toggle X"
    m = re.match(r'^Toggle\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Activar/Desactivar {content}"

    # "Show X" / "Hide X"
    m = re.match(r'^Show\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Mostrar {content}"
    m = re.match(r'^Hide\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Ocultar {content}"

    # "Enable X" / "Disable X"
    m = re.match(r'^Enable\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Activar {content}"
    m = re.match(r'^Disable\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Desactivar {content}"

    # "Open X"
    m = re.match(r'^Open\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Abrir {content}"

    # "Close X"
    m = re.match(r'^Close\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Cerrar {content}"

    # "Set X" / "Reset X"
    m = re.match(r'^Set\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Configurar {content}"
    m = re.match(r'^Reset\s+(.+)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Restablecer {content}"

    # "X volume: %d"
    m = re.match(r'^(.+?)\s+volume:\s+%d$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"Volumen de {content}: %d"

    # "X is empty" / "X is full"
    m = re.match(r'^(.+?)\s+is\s+(empty|full)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        state = "vacío" if m.group(2).lower() == "empty" else "lleno"
        return f"{content} está {state}"

    # "No X found" / "No X available"
    m = re.match(r'^No\s+(.+?)\s+(found|available)$', t, re.IGNORECASE)
    if m:
        content = translate_word_by_word(m.group(1))
        return f"No se encontró {content}"

    # "Are you sure" patterns
    if t.lower().startswith("are you sure"):
        return t.replace("Are you sure", "¿Estás seguro").replace("?", "?") + ("" if t.endswith("?") else "")

    # "Do you want" patterns
    m = re.match(r'^Do you (really )?want to\s+(.+)\??$', t, re.IGNORECASE)
    if m:
        action = translate_word_by_word(m.group(2).rstrip("?"))
        really = "realmente " if m.group(1) else ""
        return f"¿{really.capitalize()}Quieres {action}?"

    # Try full word-by-word if the string is short enough
    if len(t.split()) <= 5 and not any(c in t for c in "{}[]<>$%()"):
        result = translate_word_by_word(t)
        if result.lower() != t.lower():
            return result

    return None


WORD_TRANS = {
    "the": "el", "a": "un", "an": "un",
    "and": "y", "or": "o", "of": "de", "for": "para",
    "in": "en", "on": "sobre", "at": "en", "to": "a",
    "with": "con", "from": "de", "by": "por",
    "is": "es", "are": "son", "was": "fue", "were": "fueron",
    "has": "tiene", "have": "tienen", "had": "tenía",
    "not": "no", "no": "no", "none": "ninguno",
    "your": "tu", "you": "tú", "my": "mi", "our": "nuestro",
    "this": "este", "that": "ese", "these": "estos", "those": "esos",
    "new": "nuevo", "old": "viejo", "current": "actual",
    "last": "último", "first": "primer", "next": "siguiente",
    "server": "servidor", "client": "cliente", "game": "juego",
    "character": "personaje", "player": "jugador", "monster": "monstruo",
    "item": "objeto", "spell": "hechizo", "skill": "habilidad",
    "quest": "misión", "achievement": "logro", "reward": "recompensa",
    "daily": "diario", "weekly": "semanal", "monthly": "mensual",
    "experience": "experiencia", "level": "nivel", "health": "salud",
    "mana": "maná", "soul": "alma", "stamina": "estamina",
    "attack": "ataque", "defense": "defensa", "speed": "velocidad",
    "magic": "magia", "distance": "distancia", "melee": "cuerpo a cuerpo",
    "party": "grupo", "guild": "gremio", "friend": "amigo",
    "outfit": "atuendo", "mount": "montura", "addon": "complemento",
    "chat": "chat", "channel": "canal", "message": "mensaje",
    "trade": "comercio", "buy": "comprar", "sell": "vender",
    "inventory": "inventario", "depot": "depósito", "bank": "banco",
    "market": "mercado", "store": "tienda", "shop": "tienda",
    "map": "mapa", "minimap": "minimapa", "world": "mundo",
    "sound": "sonido", "music": "música", "volume": "volumen",
    "combat": "combate", "battle": "batalla", "fight": "lucha",
    "prey": "presa", "bestiary": "bestiario", "loot": "botín",
    "outfit": "atuendo", "familiar": "familiar", "wings": "alas",
    "effects": "efectos", "shader": "shader", "aura": "aura",
    "hotkey": "tecla rápida", "hotkeys": "teclas rápidas",
    "settings": "configuración", "options": "opciones",
    "graphics": "gráficos", "performance": "rendimiento",
    "interface": "interfaz", "controls": "controles",
    "general": "general", "advanced": "avanzado",
    "fullscreen": "pantalla completa", "windowed": "ventana",
    "online": "en línea", "offline": "desconectado",
    "list": "lista", "window": "ventana", "panel": "panel",
    "bar": "barra", "button": "botón", "tab": "pestaña",
    "menu": "menú", "dialog": "diálogo", "popup": "emergente",
    "notification": "notificación", "alert": "alerta",
    "timer": "temporizador", "countdown": "cuenta regresiva",
    "progress": "progreso", "loading": "cargando",
    "connecting": "conectando", "disconnected": "desconectado",
    "error": "error", "warning": "advertencia", "info": "info",
    "success": "éxito", "failed": "fallido",
    "vocation": "vocación", "knight": "caballero",
    "paladin": "paladín", "sorcerer": "hechicero",
    "druid": "druida", "rookgaard": "Rookgaard",
    "creature": "criatura", "boss": "jefe",
    "active": "activo", "inactive": "inactivo",
    "unlocked": "desbloqueado", "locked": "bloqueado",
    "enabled": "activado", "disabled": "desactivado",
    "premium": "premium", "free": "gratis",
    "points": "puntos", "coins": "monedas", "tokens": "fichas",
    "today": "hoy", "yesterday": "ayer", "tomorrow": "mañana",
    "minutes": "minutos", "hours": "horas", "days": "días",
    "seconds": "segundos", "weeks": "semanas", "months": "meses",
    "minute": "minuto", "hour": "hora", "day": "día",
    "second": "segundo", "week": "semana", "month": "mes",
}


def translate_word_by_word(text):
    """Simple word-by-word translation for short UI strings."""
    words = text.split()
    result = []
    any_translated = False
    for w in words:
        # Check with original case
        lower = w.lower()
        if lower in WORD_TRANS:
            tr = WORD_TRANS[lower]
            # Preserve capitalization
            if w[0].isupper() and tr:
                tr = tr[0].upper() + tr[1:]
            result.append(tr)
            any_translated = True
        elif lower in ALL_UI:
            result.append(ALL_UI[lower] if not w[0].isupper() else ALL_UI[lower])
            any_translated = True
        else:
            result.append(w)

    if any_translated:
        return " ".join(result)
    return text


def main():
    base_path = "/home/ptaku/serweryt/Tibia/silnik/canary_test/i18n/es"

    # Translate otclient_modules.json
    modules_path = os.path.join(base_path, "otclient_modules.json")
    if os.path.exists(modules_path):
        # Backup
        with open(modules_path, 'r') as f:
            data = json.load(f)
        with open(modules_path + ".bak", 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        translate_ui_file(modules_path)

    # Translate html.json
    html_path = os.path.join(base_path, "html.json")
    if os.path.exists(html_path):
        # Backup
        with open(html_path, 'r') as f:
            data = json.load(f)
        with open(html_path + ".bak", 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        translate_ui_file(html_path)


if __name__ == "__main__":
    main()
