// ═══════════════════════════════════════════════════════════════════════════════
// I18N LOADER - Nagłówek C++ dla systemu tłumaczeń
// ═══════════════════════════════════════════════════════════════════════════════
// Status: SZKIC - NIE ZAIMPLEMENTOWANY
// Wersja: 1.0-draft
// ═══════════════════════════════════════════════════════════════════════════════

#pragma once

#include <string>
#include <unordered_map>
#include <memory>
#include <mutex>
#include <optional>
#include <vector>
#include <filesystem>

namespace i18n {

// Forward declarations
class I18nLoader;
class TranslationCache;

// ═══════════════════════════════════════════════════════════════════════════════
// TYPY I STAŁE
// ═══════════════════════════════════════════════════════════════════════════════

using TranslationMap = std::unordered_map<std::string, std::string>;
using LanguageMap = std::unordered_map<std::string, TranslationMap>;

constexpr const char* DEFAULT_LANGUAGE = "en";
constexpr const char* FALLBACK_LANGUAGE = "en";
constexpr const char* I18N_DIRECTORY = "i18n/";

// Lista wspieranych języków
const std::vector<std::string> SUPPORTED_LANGUAGES = {
    "en", "pl", "de", "es", "pt", "fr", "it", "nl", "ru", "uk",
    "cs", "sk", "hu", "ro", "bg", "hr", "sl", "sr", "bs", "mk",
    "sq", "el", "tr", "ar", "he", "fa", "hi", "bn", "ta", "te",
    "ml", "th", "vi", "id", "ms", "tl", "zh", "zh_TW", "ja", "ko",
    "sv", "no", "da", "fi", "et", "lv", "lt", "ka", "hy", "az",
    "kk", "uz", "sw"
};

// ═══════════════════════════════════════════════════════════════════════════════
// KLASA CACHE
// ═══════════════════════════════════════════════════════════════════════════════

class TranslationCache {
public:
    TranslationCache() = default;
    ~TranslationCache() = default;

    // Pobierz tłumaczenie z cache
    std::optional<std::string> get(const std::string& lang, const std::string& key) const;
    
    // Zapisz tłumaczenie do cache
    void set(const std::string& lang, const std::string& key, const std::string& value);
    
    // Wyczyść cache
    void clear();
    
    // Statystyki
    size_t size() const;
    size_t hits() const { return m_hits; }
    size_t misses() const { return m_misses; }

private:
    mutable std::mutex m_mutex;
    LanguageMap m_cache;
    mutable size_t m_hits = 0;
    mutable size_t m_misses = 0;
};

// ═══════════════════════════════════════════════════════════════════════════════
// GŁÓWNA KLASA LOADER
// ═══════════════════════════════════════════════════════════════════════════════

class I18nLoader {
public:
    // Singleton
    static I18nLoader& getInstance();
    
    // Usunięcie kopiowania
    I18nLoader(const I18nLoader&) = delete;
    I18nLoader& operator=(const I18nLoader&) = delete;

    // ═══════════════════════════════════════════════════════════════════════════
    // INICJALIZACJA
    // ═══════════════════════════════════════════════════════════════════════════

    /// Inicjalizuje system i18n
    /// @param directory Katalog z tłumaczeniami
    /// @param defaultLang Domyślny język
    /// @return true jeśli sukces
    bool init(const std::string& directory = I18N_DIRECTORY, 
              const std::string& defaultLang = DEFAULT_LANGUAGE);
    
    /// Przeładowuje wszystkie tłumaczenia
    void reload();

    // ═══════════════════════════════════════════════════════════════════════════
    // TŁUMACZENIA
    // ═══════════════════════════════════════════════════════════════════════════

    /// Pobiera tłumaczenie dla klucza
    /// @param key Klucz tłumaczenia (np. "npc.john.greeting")
    /// @param lang Kod języka
    /// @return Przetłumaczony tekst lub klucz jeśli brak tłumaczenia
    std::string translate(const std::string& key, 
                          const std::string& lang = DEFAULT_LANGUAGE) const;
    
    /// Pobiera tłumaczenie z formatowaniem
    /// @param key Klucz tłumaczenia
    /// @param lang Kod języka
    /// @param args Argumenty do formatowania
    /// @return Sformatowany tekst
    template<typename... Args>
    std::string translateFormat(const std::string& key, 
                                const std::string& lang, 
                                Args&&... args) const;
    
    /// Sprawdza czy klucz istnieje
    /// @param key Klucz
    /// @param lang Język
    /// @return true jeśli istnieje
    bool hasKey(const std::string& key, const std::string& lang = DEFAULT_LANGUAGE) const;

    // ═══════════════════════════════════════════════════════════════════════════
    // ZARZĄDZANIE JĘZYKAMI
    // ═══════════════════════════════════════════════════════════════════════════

    /// Pobiera listę dostępnych języków
    std::vector<std::string> getAvailableLanguages() const;
    
    /// Sprawdza czy język jest wspierany
    bool isLanguageSupported(const std::string& lang) const;
    
    /// Ustawia domyślny język
    void setDefaultLanguage(const std::string& lang);
    
    /// Pobiera domyślny język
    std::string getDefaultLanguage() const { return m_defaultLanguage; }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATYSTYKI
    // ═══════════════════════════════════════════════════════════════════════════

    struct Stats {
        size_t loadedLanguages;
        size_t totalKeys;
        size_t cacheHits;
        size_t cacheMisses;
    };
    
    Stats getStats() const;

private:
    I18nLoader() = default;
    ~I18nLoader() = default;

    /// Ładuje tłumaczenia dla języka
    bool loadLanguage(const std::string& lang);
    
    /// Ładuje pojedynczy plik JSON
    bool loadJsonFile(const std::string& filePath, const std::string& lang);
    
    /// Parsuje klucz (wydziela kategorię)
    std::pair<std::string, std::string> parseKey(const std::string& key) const;

    std::string m_directory = I18N_DIRECTORY;
    std::string m_defaultLanguage = DEFAULT_LANGUAGE;
    std::unique_ptr<TranslationCache> m_cache;
    LanguageMap m_translations;
    mutable std::mutex m_mutex;
    bool m_initialized = false;
};

// ═══════════════════════════════════════════════════════════════════════════════
// FUNKCJE POMOCNICZE (GLOBALNE)
// ═══════════════════════════════════════════════════════════════════════════════

/// Skrót do translate
inline std::string _(const std::string& key, const std::string& lang = DEFAULT_LANGUAGE) {
    return I18nLoader::getInstance().translate(key, lang);
}

/// Skrót do translateFormat
template<typename... Args>
inline std::string _f(const std::string& key, const std::string& lang, Args&&... args) {
    return I18nLoader::getInstance().translateFormat(key, lang, std::forward<Args>(args)...);
}

// ═══════════════════════════════════════════════════════════════════════════════
// IMPLEMENTACJA TEMPLATE
// ═══════════════════════════════════════════════════════════════════════════════

template<typename... Args>
std::string I18nLoader::translateFormat(const std::string& key, 
                                         const std::string& lang, 
                                         Args&&... args) const {
    std::string text = translate(key, lang);
    
    // Użyj fmt::format jeśli dostępne
    #ifdef FMT_VERSION
        return fmt::format(fmt::runtime(text), std::forward<Args>(args)...);
    #else
        // Fallback - proste podstawienie
        // TODO: Implementacja własnego formatowania
        return text;
    #endif
}

} // namespace i18n

// ═══════════════════════════════════════════════════════════════════════════════
// PRZYKŁADY UŻYCIA (DO USUNIĘCIA W PRODUKCJI)
// ═══════════════════════════════════════════════════════════════════════════════

/*
// Inicjalizacja
i18n::I18nLoader::getInstance().init("i18n/", "en");

// Podstawowe tłumaczenie
std::string msg = i18n::_("npc.john.greeting", "pl");

// Z formatowaniem
std::string balance = i18n::_f("npc.banker.balance", "pl", playerGold);

// Dla gracza
std::string playerLang = player->getLanguage();
player->sendTextMessage(MESSAGE_INFO_DESCR, i18n::_("quest.completed", playerLang));

// Sprawdzenie
if (i18n::I18nLoader::getInstance().hasKey("items.sword.description")) {
    // ...
}
*/
