function onUpdateDatabase()
	logger.info("Updating database to version 53 (feat: player locale)")

	db.query([[
		ALTER TABLE `players`
		ADD COLUMN `locale` VARCHAR(5) NOT NULL DEFAULT 'en' AFTER `pronoun`
	]])
end
