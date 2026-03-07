<?php
/**
 * Records
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\Models\ServerRecord;

defined('MYAAC') or die('Direct access not allowed!');

$title = __('players_online_records');

if(!$db->hasTable('server_record')) {
	echo __('record_history_not_supported');
	return;
}

echo '
<b><div style="text-align:center">'.__('records_on_server', ['SERVER' => $config['lua']['serverName']]).'</div></b>
<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=4 WIDTH=100%>
	<TR BGCOLOR="'.$config['vdarkborder'].'">
		<TD class="white"><b><div style="text-align:center">'.__('records_players').'</div></b></TD>
		<TD class="white"><b><div style="text-align:center">'.__('records_date').'</div></b></TD>
	</TR>';

	$i = 0;
	$records_query = ServerRecord::limit(50)->orderByDesc('record')->get();
	foreach($records_query as $data)
	{
		echo '<TR BGCOLOR=' . getStyle(++$i) . '>
			<TD><div style="text-align:center">' . $data['record'] . '</div></TD>
			<TD><div style="text-align:center">' . date("d/m/Y, G:i:s", $data['timestamp']) . '</div></TD>
		</TR>';
	}

echo '</TABLE>';
?>
