<?php
/**
 * Commands page - lists available in-game commands
 *
 * @package   MyAAC
 */
defined('MYAAC') or die('Direct access not allowed!');
$title = __('menu_commands');

$commands = [
	['!online', 'Pokazuje liczbę graczy online.'],
	['!serverinfo', 'Informacje o serwerze.'],
	['!uptime', 'Czas działania serwera.'],
	['!frags', 'Pokazuje liczbę fragów.'],
	['!blessings', 'Sprawdza posiadane błogosławieństwa.'],
	['!aol', 'Kupuje Amulet of Loss.'],
	['!bless', 'Kupuje wszystkie błogosławieństwa.'],
	['!autoloot', 'Zarządzanie automatycznym zbieraniem łupów.'],
];
?>
<table width="100%" cellspacing="0" cellpadding="0">
<tr>
	<td>
		<div class="TableContainer">
			<table class="Table1" cellpadding="0" cellspacing="0">
			<tr>
				<td class="InnerTableContainer">
					<table style="width:100%;">
					<tr>
						<td class="LabelV" style="padding:5px 10px;">
							<h2><?php echo __('menu_commands'); ?></h2>
							<table class="Table2" width="100%">
								<tr class="LabelH">
									<td>Komenda</td>
									<td>Opis</td>
								</tr>
								<?php foreach ($commands as $cmd): ?>
								<tr>
									<td class="LabelV"><code><?php echo htmlspecialchars($cmd[0]); ?></code></td>
									<td class="LabelV"><?php echo htmlspecialchars($cmd[1]); ?></td>
								</tr>
								<?php endforeach; ?>
							</table>
						</td>
					</tr>
					</table>
				</td>
			</tr>
			</table>
		</div>
	</td>
</tr>
</table>
