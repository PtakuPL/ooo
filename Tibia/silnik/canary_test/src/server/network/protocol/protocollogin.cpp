/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#include "server/network/protocol/protocollogin.hpp"

#include "config/configmanager.hpp"
#include "server/network/message/outputmessage.hpp"
#include "game/scheduling/dispatcher.hpp"
#include "account/account.hpp"
#include "io/iologindata.hpp"
#include "creatures/players/management/ban.hpp"
#include "game/game.hpp"
#include "core.hpp"
#include "enums/account_errors.hpp"
#include "utils/i18n/translator.hpp"

void ProtocolLogin::disconnectClient(const std::string &message) const {
	const auto output = OutputMessagePool::getOutputMessage();

	output->addByte(0x0B);
	output->addString(message);
	send(output);

	disconnect();
}

void ProtocolLogin::getCharacterList(const std::string &accountDescriptor, const std::string &password) const {
	Account account(accountDescriptor);
	account.setProtocolCompat(oldProtocol);
	auto &tr = i18n::g_translator();
	const std::string ver = fmt::format("{}.{}", CLIENT_VERSION_UPPER, CLIENT_VERSION_LOWER);

	if (oldProtocol && !g_configManager().getBoolean(OLD_PROTOCOL)) {
		disconnectClient(tr.format("cpp.protocol.only_clients", "en", {ver}));
		return;
	} else if (!oldProtocol) {
		disconnectClient(tr.format("cpp.protocol.only_clients_or_old", "en", {ver}));
		return;
	}

	if (account.load() != AccountErrors_t::Ok || !account.authenticate(password)) {
		disconnectClient(tr.get(oldProtocol ? "cpp.protocol.wrong_username_password" : "cpp.protocol.wrong_email_password", "en"));
		return;
	}

	auto output = OutputMessagePool::getOutputMessage();
	const std::string &motd = g_configManager().getString(SERVER_MOTD);
	if (!motd.empty()) {
		// Add MOTD
		output->addByte(0x14);

		std::ostringstream ss;
		ss << g_game().getMotdNum() << "\n"
		   << motd;
		output->addString(ss.str());
	}

	// Add session key
	output->addByte(0x28);
	output->addString(accountDescriptor + "\n" + password);

	// Add char list
	auto [players, result] = account.getAccountPlayers();
	if (AccountErrors_t::Ok != result) {
		g_logger().warn("Account[{}] failed to load players!", account.getID());
	}

	output->addByte(0x64);

	output->addByte(1); // number of worlds

	output->addByte(0); // world id
	output->addString(g_configManager().getString(SERVER_NAME));
	output->addString(g_configManager().getString(IP));

	output->add<uint16_t>(g_configManager().getNumber(GAME_PORT));

	output->addByte(0);

	uint8_t size = std::min<size_t>(std::numeric_limits<uint8_t>::max(), players.size());
	output->addByte(size);
	for (const auto &[name, deletion] : players) {
		output->addByte(0);
		output->addString(name);
	}

	// Get premium days, check is premium and get lastday
	output->addByte(account.getPremiumRemainingDays());
	output->addByte(account.getPremiumLastDay() > getTimeNow());
	output->add<uint32_t>(account.getPremiumLastDay());

	send(output);

	disconnect();
}

void ProtocolLogin::onRecvFirstMessage(NetworkMessage &msg) {
	if (g_game().getGameState() == GAME_STATE_SHUTDOWN) {
		disconnect();
		return;
	}

	msg.skipBytes(2); // client OS

	auto version = msg.get<uint16_t>();

	// Old protocol support
	oldProtocol = version == 1100;

	msg.skipBytes(17);
	/*
	 - Skipped bytes:
	 - 4 bytes: client version (971+)
	 - 12 bytes: dat, spr, pic signatures (4 bytes each)
	 - 1 byte: preview world(971+)
	 */

	if (!Protocol::RSA_decrypt(msg)) {
		g_logger().warn("[ProtocolLogin::onRecvFirstMessage] - RSA Decrypt Failed");
		disconnect();
		return;
	}

	std::array<uint32_t, 4> key = { msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>(), msg.get<uint32_t>() };
	enableXTEAEncryption();
	setXTEAKey(key.data());

	setChecksumMethod(CHECKSUM_METHOD_ADLER32);

	if (g_game().getGameState() == GAME_STATE_STARTUP) {
		disconnectClient(i18n::g_translator().get("cpp.protocol.gameworld_starting", "en"));
		return;
	}

	if (g_game().getGameState() == GAME_STATE_MAINTAIN) {
		disconnectClient(i18n::g_translator().get("cpp.protocol.gameworld_maintenance", "en"));
		return;
	}

	BanInfo banInfo;
	auto curConnection = getConnection();
	if (!curConnection) {
		return;
	}

	if (IOBan::isIpBanned(curConnection->getIP(), banInfo)) {
		if (banInfo.reason.empty()) {
			banInfo.reason = "(none)";
		}

		disconnectClient(i18n::g_translator().format("cpp.protocol.ip_banned_until", "en", {formatDateShort(banInfo.expiresAt), banInfo.bannedBy, banInfo.reason}));
		return;
	}

	std::string accountDescriptor = msg.getString();
	if (accountDescriptor.empty()) {
		disconnectClient(i18n::g_translator().get(oldProtocol ? "cpp.protocol.enter_username" : "cpp.protocol.enter_email", "en"));
		return;
	}

	std::string password = msg.getString();
	if (password.empty()) {
		disconnectClient(i18n::g_translator().get("cpp.protocol.invalid_password", "en"));
		return;
	}

	g_dispatcher().addEvent(
		[self = std::static_pointer_cast<ProtocolLogin>(shared_from_this()), accountDescriptor, password] {
			self->getCharacterList(accountDescriptor, password);
		},
		__FUNCTION__
	);
}
