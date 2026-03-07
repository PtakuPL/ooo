<?php
/**
 * Downloads page
 *
 * @package   MyAAC
 */
defined('MYAAC') or die('Direct access not allowed!');
$title = __('menu_downloads');
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
							<h2><?php echo __('menu_downloads'); ?></h2>
							<p><?php echo __('downloads_description'); ?></p>
							<table class="Table2" width="100%">
								<tr class="LabelH">
									<td>Klient</td>
									<td>Wersja</td>
									<td>Link</td>
								</tr>
								<tr>
									<td class="LabelV">Classic 7.4</td>
									<td class="LabelV">1.1.0</td>
									<td class="LabelV"><a href="/client_pack/1.1.0/">Pobierz</a></td>
								</tr>
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
