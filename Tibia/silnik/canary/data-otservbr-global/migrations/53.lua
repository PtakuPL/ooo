function onUpdateDatabase()
	logger.info("Updating database to version 53 (player locale support)")

	db.query([[
		ALTER TABLE `players`
		ADD COLUMN `locale` VARCHAR(5) NOT NULL DEFAULT 'en' AFTER `sex`
	]])

	db.query([[
		CREATE INDEX `idx_players_locale`
		ON `players` (`locale`)
	]])
end
