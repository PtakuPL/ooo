/**
 * @file ticket_validator.cpp
 * @brief C1: Implementacja walidacji ticketów HMAC.
 */

#include "ticket_validator.hpp"

#include "config/configmanager.hpp"
#include "lib/logging/logger.hpp"

#include <nlohmann/json.hpp>
#include <openssl/evp.h>
#include <openssl/hmac.h>

#include <chrono>
#include <sstream>
#include <iomanip>

using json = nlohmann::json;

TicketValidator &TicketValidator::getInstance() {
	static TicketValidator instance;
	return instance;
}

bool TicketValidator::isEnabled() const {
	return g_configManager().getBoolean(TICKET_GATE_ENABLED);
}

bool TicketValidator::validateTicket(const std::string &ticket,
                                     const std::string &expectedCharacterName,
                                     std::string &outGameMode,
                                     uint32_t &outAccountId,
                                     std::string &outErrorMsg) {
	if (!isEnabled()) {
		outErrorMsg = "Ticket gate is not enabled.";
		return false;
	}

	// Ticket format: base64_payload.hmac_hex
	// UWAGA (FIX5): HMAC jest obliczany na base64-encoded payload (payloadB64),
	// NIE na surowym JSON. Takie podejście (analogiczne do JWT) eliminuje
	// problemy z kanonizacją JSON (kolejność kluczy, białe znaki).
	// ticket.php MUSI generować HMAC w ten sam sposób:
	//   hmac = HMAC-SHA256(base64encode(json_payload), secret)
	//   ticket = base64encode(json_payload) + "." + hex(hmac)
	auto dotPos = ticket.find('.');
	if (dotPos == std::string::npos || dotPos == 0 || dotPos == ticket.size() - 1) {
		outErrorMsg = "Invalid ticket format.";
		return false;
	}

	std::string payloadB64 = ticket.substr(0, dotPos);
	std::string receivedHmac = ticket.substr(dotPos + 1);

	// 1. Weryfikacja HMAC
	std::string secret = g_configManager().getString(TICKET_SECRET);
	if (secret.empty()) {
		outErrorMsg = "Ticket secret not configured.";
		g_logger().error("[TicketValidator] TICKET_SECRET is empty in config.lua!");
		return false;
	}

	std::string expectedHmac = computeHmac(payloadB64, secret);
	if (receivedHmac.size() != expectedHmac.size()) {
		outErrorMsg = "Invalid ticket signature.";
		return false;
	}

	// Constant-time comparison
	unsigned char result = 0;
	for (size_t i = 0; i < expectedHmac.size(); ++i) {
		result |= static_cast<unsigned char>(receivedHmac[i]) ^ static_cast<unsigned char>(expectedHmac[i]);
	}
	if (result != 0) {
		outErrorMsg = "Invalid ticket signature.";
		return false;
	}

	// 2. Dekoduj payload
	std::string payloadJson = base64Decode(payloadB64);
	if (payloadJson.empty()) {
		outErrorMsg = "Cannot decode ticket payload.";
		return false;
	}

	json payload;
	try {
		payload = json::parse(payloadJson);
	} catch (const std::exception &e) {
		outErrorMsg = "Cannot parse ticket payload.";
		g_logger().warn("[TicketValidator] JSON parse error: {}", e.what());
		return false;
	}

	// 3. Sprawdź wymagane pola
	if (!payload.contains("characterName") || !payload.contains("gameMode") ||
	    !payload.contains("nonce") || !payload.contains("expiresAt")) {
		outErrorMsg = "Ticket missing required fields.";
		return false;
	}

	// 4. Sprawdź expiration
	auto now = std::chrono::duration_cast<std::chrono::seconds>(
	               std::chrono::system_clock::now().time_since_epoch())
	               .count();
	int64_t expiresAt = payload["expiresAt"].get<int64_t>();
	if (now > expiresAt) {
		outErrorMsg = "Ticket has expired.";
		return false;
	}

	// 5. Sprawdź characterName
	std::string ticketCharName = payload["characterName"].get<std::string>();
	if (ticketCharName != expectedCharacterName) {
		outErrorMsg = "Ticket character name mismatch.";
		g_logger().warn("[TicketValidator] Character mismatch: ticket='{}' vs expected='{}'",
		                ticketCharName, expectedCharacterName);
		return false;
	}

	// 6. Sprawdź nonce (jednorazowy)
	std::string nonce = payload["nonce"].get<std::string>();
	{
		std::lock_guard<std::mutex> lock(nonceMutex_);
		if (usedNonces_.count(nonce) > 0) {
			outErrorMsg = "Ticket has already been used (replay detected).";
			return false;
		}
		// FIX23: Zapisz nonce z timestampem wstawienia
		usedNonces_[nonce] = now;

		// FIX23: Auto-cleanup co 100 walidacji
		validateCallCount_++;
		if (validateCallCount_ % 100 == 0) {
			cleanupExpiredNonces(300); // wywołanie BEZ locka (mamy go już)
		}
	}

	// 7. Ustaw gameMode
	outGameMode = payload["gameMode"].get<std::string>();

	// 7b. FIX19: worldName — logujemy ale NIE odrzucamy.
	// Walidacja world↔gameMode odbywa się w ticket.php (FIX20) PRZED podpisaniem.
	// Tu ticket jest już podpisany HMAC — jeśli dotarł, to ticket.php go zwalidował.
	// Porównanie z SERVER_NAME nie ma sensu bo API wystawia inne nazwy niż config.lua.
	if (payload.contains("worldName")) {
		std::string ticketWorldName = payload["worldName"].get<std::string>();
		g_logger().debug("[TicketValidator] Ticket worldName='{}' (informational only)", ticketWorldName);
	}
	if (payload.contains("accountId")) {
		outAccountId = payload["accountId"].get<uint32_t>();
	} else {
		outErrorMsg = "Ticket missing accountId field.";
		return false;
	}

	g_logger().info("[TicketValidator] Ticket valid for character='{}' gameMode='{}' accountId={}",
	                expectedCharacterName, outGameMode, outAccountId);
	return true;
}

void TicketValidator::cleanupExpiredNonces(uint64_t maxAgeSec) {
	// FIX23: Usuwamy nonce'y starsze niż maxAgeSec sekund.
	// UWAGA: ta metoda jest wywoływana z validateTicket() WEWNĄTRZ locka nonceMutex_,
	// więc NIE blokujemy ponownie.
	auto now = static_cast<uint64_t>(std::time(nullptr));
	size_t before = usedNonces_.size();
	for (auto it = usedNonces_.begin(); it != usedNonces_.end(); ) {
		if (now - it->second > maxAgeSec) {
			it = usedNonces_.erase(it);
		} else {
			++it;
		}
	}
	size_t removed = before - usedNonces_.size();
	if (removed > 0) {
		g_logger().info("[TicketValidator] Nonce cleanup: removed {} expired (>{} s), {} remain", removed, maxAgeSec, usedNonces_.size());
	}
}

std::string TicketValidator::computeHmac(const std::string &data, const std::string &key) const {
	unsigned char digest[EVP_MAX_MD_SIZE];
	unsigned int digestLen = 0;

	HMAC(EVP_sha256(),
	     key.data(), static_cast<int>(key.size()),
	     reinterpret_cast<const unsigned char *>(data.data()), data.size(),
	     digest, &digestLen);

	// Konwersja na hex string
	std::ostringstream ss;
	for (unsigned int i = 0; i < digestLen; ++i) {
		ss << std::hex << std::setfill('0') << std::setw(2)
		   << static_cast<int>(digest[i]);
	}
	return ss.str();
}

std::string TicketValidator::base64Decode(const std::string &encoded) const {
	// OpenSSL base64 decode
	int decodedLen = static_cast<int>(encoded.size() * 3 / 4 + 3);
	std::string decoded(decodedLen, '\0');

	EVP_ENCODE_CTX *ctx = EVP_ENCODE_CTX_new();
	if (!ctx) {
		return "";
	}

	EVP_DecodeInit(ctx);

	int outLen = 0;
	int tmpLen = 0;

	if (EVP_DecodeUpdate(ctx,
	                     reinterpret_cast<unsigned char *>(decoded.data()),
	                     &outLen,
	                     reinterpret_cast<const unsigned char *>(encoded.data()),
	                     static_cast<int>(encoded.size())) < 0) {
		EVP_ENCODE_CTX_free(ctx);
		return "";
	}

	if (EVP_DecodeFinal(ctx,
	                    reinterpret_cast<unsigned char *>(decoded.data()) + outLen,
	                    &tmpLen) < 0) {
		EVP_ENCODE_CTX_free(ctx);
		return "";
	}

	outLen += tmpLen;
	EVP_ENCODE_CTX_free(ctx);

	decoded.resize(outLen);
	return decoded;
}

