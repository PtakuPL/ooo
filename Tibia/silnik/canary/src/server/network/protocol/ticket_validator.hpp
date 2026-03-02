/**
 * @file ticket_validator.hpp
 * @brief C1: Walidacja ticketów HMAC dla systemu ticket-gate.
 *
 * Flow: klient → login.php → ticket.php → HMAC ticket → Canary validateTicket()
 *
 * Ticket format (JSON zakodowany w base64 + HMAC-SHA256):
 *   base64({sessionKey, characterName, gameMode, nonce, expiresAt}) + "." + hmac_hex
 *
 * Canary sprawdza:
 *   1. HMAC podpis (shared secret z config.lua)
 *   2. Expiration (expiresAt > now)
 *   3. Nonce (jednorazowy — zapobiega replay)
 *   4. characterName match
 */

#pragma once

#include <cstdint>
#include <string>
#include <unordered_map>
#include <mutex>

class TicketValidator {
public:
	static TicketValidator &getInstance();

	/**
	 * @brief Waliduj ticket HMAC.
	 * @param ticket Cały ticket string (base64_payload.hmac_hex)
	 * @param expectedCharacterName Nazwa postaci z pakietu login
	 * @param outGameMode [out] Tryb gry z ticketu (np. "classic74", "modern")
	 * @param outAccountId [out] ID konta z ticketu
	 * @param outErrorMsg [out] Komunikat błędu jeśli walidacja nie powiodła się
	 * @return true jeśli ticket jest ważny
	 */
	bool validateTicket(const std::string &ticket,
	                    const std::string &expectedCharacterName,
	                    std::string &outGameMode,
	                    uint32_t &outAccountId,
	                    std::string &outErrorMsg);

	/**
	 * @brief Sprawdź czy ticket-gate jest włączony w config.lua.
	 */
	bool isEnabled() const;

	/**
	 * @brief Wyczyść stare nonce'y (starsze niż maxAge sekund).
	 * Wywoływane periodycznie.
	 */
	void cleanupExpiredNonces(uint64_t maxAgeSec = 300);

private:
	TicketValidator() = default;

	// HMAC-SHA256
	std::string computeHmac(const std::string &data, const std::string &key) const;

	// Base64 decode
	std::string base64Decode(const std::string &encoded) const;

	// Nonce store (in-memory, jednorazowe) — FIX23: z timestampem
	// Klucz: nonce string, Wartość: unix timestamp wstawienia
	std::unordered_map<std::string, int64_t> usedNonces_;
	std::mutex nonceMutex_;
	uint64_t validateCallCount_ = 0; // FIX23: licznik wywołań do auto-cleanup
};

