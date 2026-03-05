/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#pragma once

class Logger;

class CanaryRSA {
public:
	explicit CanaryRSA(Logger &logger);
	~CanaryRSA();

	// Singleton - ensures we don't accidentally copy it
	CanaryRSA(CanaryRSA const &) = delete;
	void operator=(CanaryRSA const &) = delete;

	static CanaryRSA &getInstance();

	void start();

	void setKey(const char* pString, const char* qString, int base = 10);
	void decrypt(char* msg) const;

	std::string base64Decrypt(const std::string &input) const;
	uint16_t decodeLength(char*&pos) const;
	void readHexString(char*&pos, uint16_t length, std::string &output) const;
	bool loadPEM(const std::string &filename);

private:
	Logger &logger;
	mpz_t n {};
	mpz_t d {};
};

constexpr auto g_RSA = CanaryRSA::getInstance;
