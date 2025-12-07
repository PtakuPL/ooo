<?php
defined('MYAAC') or die('Direct access not allowed!');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" data-i18n-title="site.title">
	<head>
		<?php echo template_place_holder('head_start'); ?>
		<link rel="stylesheet" href="<?php echo $template_path; ?>/style.css" type="text/css" />
		<script src="/resources/i18n/i18n.js" defer></script>
		<script type="text/javascript">
			<?php
				$menus = get_template_menus();

				$twig->display('menu.js.html.twig', ['menus' => $menus]);
			?>
		</script>
		<script type="text/javascript" src="tools/basic.js"></script>
		<script type="text/javascript">
			<?php require 'javascript.php'; ?>
		</script>
		<?php echo template_place_holder('head_end'); ?>
	</head>

	<body onload="initMenu();">
		<?php echo template_place_holder('body_start'); ?>
		<div id="top"></div>
		<div id="page">
		<!-- Keep all on center of browser -->

			<!-- Header Section -->
			<div id="header"></div>
			<!-- End -->

			<!-- Custom Style for #tabs -->
			<?php
			$menusCount = count($menus);
			$tabsStyle = '';
			if ($menusCount > 6) {
				$tabsStyle .= 'padding-left: 4px;';
				$tabsStyle .= 'padding-right: 12px;';
			}
			elseif ($menusCount > 5) {
				$tabsStyle .= 'padding-left: 90px;';
			}
			?>

			<!-- Menu Section -->
			<div id="tabs" style="<?= $tabsStyle; ?>">
				<?php
				foreach($config['menu_categories'] as $id => $cat) {
					if (($id != MENU_CATEGORY_SHOP || $config['gifts_system']) && isset($menus[$id])) { ?>
				<span id="<?php echo $cat['id']; ?>" onclick="menuSwitch('<?php echo $cat['id']; ?>');" data-i18n="menu.<?php echo strtolower($cat['id']); ?>|<?php echo $cat['name']; ?>"><?php echo $cat['name']; ?></span>
				<?php
					}
				}
				?>
			</div>

			<div id="mainsubmenu">
				<?php
				foreach($menus as $category => $menu) {
					if(!isset($menus[$category])) {
						continue;
					}

					echo '<div id="' . $config['menu_categories'][$category]['id'] . '-submenu">';

					$size = count($menus[$category]);
					$i = 0;

					foreach($menus[$category] as $link) {
						echo '<a href="' . $link['link_full'] . '" ' . $link['target_blank'] . ' ' . $link['style_color'] . ' data-i18n="menu.' . strtolower($config['menu_categories'][$category]['id']) . '.' . strtolower(preg_replace('/\s+/', '_', $link['name'])) . '|'. htmlspecialchars($link['name'], ENT_QUOTES) . '">' . $link['name'] . '</a>';

						if(++$i != $size) {
							echo '<span class="separator"></span>';
						}
					}

					echo '</div>';
				}
				?>
			</div>
			<!-- End -->

			<!-- Content Section -->
			<div id="content">
				<div id="margins">
					<table cellpadding="0" cellspacing="0" border="0" width="100%">
						<tr>
							<td><a href="<?php echo getLink('news'); ?>" data-i18n="nav.home|<?php echo $config['lua']['serverName']; ?>"><?php echo $config['lua']['serverName']; ?></a> &raquo; <span data-i18n="page.title|<?php echo htmlspecialchars($title, ENT_QUOTES); ?>"><?php echo $title; ?></span></td>
							<td>
							<?php
							if($status['online'])
								echo '
								<span style="color: green"><b data-i18n="status.online">Server Online</b></span> &raquo;
								<span data-i18n="status.players">Players Online</span>: ' . $status['players'] . ' / ' . $status['playersMax'] . ' &raquo;
								<span data-i18n="status.monsters">Monsters</span>: ' . $status['monsters'] . ' &raquo; <span data-i18n="status.uptime">Uptime</span>: ' . (isset($status['uptimeReadable']) ? $status['uptimeReadable'] : 'Unknown') . '';
							else
								echo '<span style="color: red"><b data-i18n="status.offline">Server Offline</b></span>';
							?>
							</td>
						</tr>
					</table>
					<hr noshade="noshade" size="1" />
					<div class="Content"><div id="ContentHelper">
					<?php echo tickers() . template_place_holder('center_top') . $content; ?>
					</div></div>
				</div>
			</div>
			<div id="content-bot"></div>
			<div id="copyrights">
				<p><?php echo template_footer(); ?></p>
<?php
	if($config['template_allow_change'])
		 echo '<span style="color: white">Template:</span><br/>' . template_form();
 ?>
			</div>
			<!-- End -->

		<!-- End -->
		</div>
		<?php echo template_place_holder('body_end'); ?>
	</body>
</html>
