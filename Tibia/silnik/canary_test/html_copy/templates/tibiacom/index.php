<?php
defined('MYAAC') or die('Direct access not allowed!');

$requestPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
if (is_string($requestPath) && in_array($requestPath, ['/account', '/index.php/account/manage', '/index.php/account/login', '/index.php/account/logout'], true)) {
	header('Location: ' . BASE_URL . '?subtopic=accountmanagement', true, 302);
	exit;
}
if (is_string($requestPath) && in_array($requestPath, ['/index.php/account/create', '/account/create'], true)) {
	header('Location: ' . BASE_URL . 'reddaxe/account-create.php?source=tibiawww', true, 302);
	exit;
}

if(isset($config['boxes']))
	$config['boxes'] = explode(",", $config['boxes']);
?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head data-i18n-title="site.title">
	<?php echo template_place_holder('head_start'); ?>
	<link rel="shortcut icon" href="<?php echo $template_path; ?>/images/favicon.ico" type="image/x-icon" />
	<link rel="icon" href="<?php echo $template_path; ?>/images/favicon.ico" type="image/x-icon" />
	<link href="<?php echo $template_path; ?>/basic.css?v=<?php echo time(); ?>" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="tools/basic.js"></script>
	<script src="/resources/i18n/i18n.js?v=<?php echo @filemtime(BASE . 'resources/i18n/i18n.js'); ?>" defer></script>
	<script type="text/javascript" src="<?php echo $template_path; ?>/ticker.js"></script>

	<?php if(!empty($config['network_twitter'])): ?>
	<script id="twitter-wjs" src="<?php echo $template_path; ?>/js/twitter.js"></script>
	<?php endif; ?>

	<?php if(!empty($config['network_facebook'])): ?>
	<script id="facebook-jssdk" async src="https://connect.facebook.net/en_US/all.js"></script>
	<link href="<?php echo $template_path; ?>/css/facebook.css" rel="stylesheet" type="text/css">
	<?php endif; ?>

	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />

	<?php $imgVer = '?v=' . filemtime(__DIR__ . '/basic.css'); ?>

	<script type="text/javascript">
		var menus = '';
		var IMGVER = '<?php echo $imgVer; ?>';
		var loginStatus="<?php echo ($logged ? 'true' : 'false'); ?>";
		<?php
			if(PAGE !== 'news') {
				if(isset($_REQUEST['subtopic'])) {
					$tmp = escapeHtml($_REQUEST['subtopic']);
					if($tmp === 'accountmanagement') {
						$tmp = 'accountmanage';
					}
				}
				else {
					$tmp = str_replace('/', '_', PAGE);
					$exp = explode('/', PAGE);
					if(PAGE !== 'account/create' && PAGE !== 'account/lost' && isset($exp[1])) {
						if ($exp[0] === 'account') {
							$tmp = 'account_manage';
						} else if ($exp[0] === 'news' && $exp[1] === 'archive') {
							$tmp = 'news_archive';
						}
						else if (in_array($exp[0], ['characters', 'highscores', 'guilds', 'forum'])) {
							$tmp = $exp[0];
						}
					}
				}
			}
			else {
				$tmp = 'news';
			}
		?>
		var activeSubmenuItem="<?php echo $tmp; ?>";
		var IMAGES="<?php echo $template_path; ?>/images";
		var LINK_ACCOUNT="<?php echo BASE_URL; ?>";

		function rowOverEffect(object) {
			if (object.className == 'moduleRow') object.className = 'moduleRowOver';
		}

		function rowOutEffect(object) {
			if (object.className == 'moduleRowOver') object.className = 'moduleRow';
		}

		function InitializePage() {
		  BustImageCache();
		  LoadMenu();
		}

		// Force reload of all template images with cache-busting
		function BustImageCache() {
		  var ver = IMGVER;
		  // Bust background-image cache for all divs with inline styles
		  document.querySelectorAll('[style*=\"background-image\"]').forEach(function(el) {
		    var bg = el.style.backgroundImage;
		    if (bg && bg.indexOf('url(') !== -1 && bg.indexOf(ver) === -1) {
		      el.style.backgroundImage = bg.replace(/\.gif\b/g, '.gif' + ver).replace(/\.png\b/g, '.png' + ver);
		    }
		  });
		  // Bust img src cache
		  document.querySelectorAll('img[src*=\"/images/\"]').forEach(function(el) {
		    if (el.src.indexOf(ver) === -1) {
		      el.src = el.src + ver;
		    }
		  });
		}

		// legacy loginbox handlers no longer used (new sidebar is static HTML/CSS)
		function LoadLoginBox() {}

		var menu = [];
		menu[0] = {};
		var unloadhelper = false;

		<?php
			$menuInitStr = '';
			foreach ($config['menu_categories'] as $item) {
				if ($item['id'] !== 'shops' || setting('core.gifts_system')) {
					$menuInitStr .= $item['id'] . '=0&';
				}
			}
		?>

		// load the menu and set the active submenu item by using the variable 'activeSubmenuItem'
		function LoadMenu()
		{
		  var activeSubmenuNode = document.getElementById("submenu_" + activeSubmenuItem);
		  if (activeSubmenuNode) {
			activeSubmenuNode.style.color = "white";
		  }
		  var activeSubmenuIcon = document.getElementById("ActiveSubmenuItemIcon_" + activeSubmenuItem);
		  if (activeSubmenuIcon) {
			activeSubmenuIcon.style.visibility = "visible";
		  }
		  // Always start collapsed after each page refresh (requested UX behavior).
		  menus = "<?= $menuInitStr ?>";
		  FillMenuArray();
		  InitializeMenu();
		}

		function SaveMenu()
		{
		  if(unloadhelper == false) {
			unloadhelper = true;
		  }
		}

		// store the values of the variable 'self.name' in the array menu
		function FillMenuArray()
		{
			while(menus.length > 0 ){
				var mark1 = menus.indexOf("=");
				var mark2 = menus.indexOf("&");
				var menuItemName = menus.substr(0, mark1);
				menu[0][menuItemName] = menus.substring(mark1 + 1, mark2);
				menus = menus.substr(mark2 + 1, menus.length);
			}
		}

		// hide or show the corresponding submenus
		function InitializeMenu()
		{
		  for(menuItemName in menu[0]) {
			  if (!document.getElementById(menuItemName+"_Submenu")) {
				  continue;
			  }

			if(menu[0][menuItemName] == "0") {
			  document.getElementById(menuItemName+"_Submenu").style.visibility = "hidden";
			  document.getElementById(menuItemName+"_Submenu").style.display = "none";
			  document.getElementById(menuItemName+"_Lights").style.visibility = "visible";
			  document.getElementById(menuItemName+"_Extend").style.backgroundImage = "url(" + IMAGES + "/general/plus.gif)";
			}
			else {
			  document.getElementById(menuItemName+"_Submenu").style.visibility = "visible";
			  document.getElementById(menuItemName+"_Submenu").style.display = "block";
			  document.getElementById(menuItemName+"_Lights").style.visibility = "hidden";
			  document.getElementById(menuItemName+"_Extend").style.backgroundImage = "url(" + IMAGES + "/general/minus.gif)";
			}
		  }
		}

		function SaveMenuArray()
		{
			// disabled on purpose: submenu state should not persist between refreshes
			return;
		}

		// onClick open or close submenus
		function MenuItemAction(sourceId)
		{
		  if(menu[0][sourceId] == 1) {
			CloseMenuItem(sourceId);
		  }
		  else {
			OpenMenuItem(sourceId);
		  }
		}
		function OpenMenuItem(sourceId)
		{
		  menu[0][sourceId] = 1;
		  document.getElementById(sourceId+"_Submenu").style.visibility = "visible";
		  document.getElementById(sourceId+"_Submenu").style.display = "block";
		  document.getElementById(sourceId+"_Lights").style.visibility = "hidden";
		  document.getElementById(sourceId+"_Extend").style.backgroundImage = "url(" + IMAGES + "/general/minus.gif)";
		}
		function CloseMenuItem(sourceId)
		{
		  menu[0][sourceId] = 0;
		  document.getElementById(sourceId+"_Submenu").style.visibility = "hidden";
		  document.getElementById(sourceId+"_Submenu").style.display = "none";
		  document.getElementById(sourceId+"_Lights").style.visibility = "visible";
		  document.getElementById(sourceId+"_Extend").style.backgroundImage = "url(" + IMAGES + "/general/plus.gif)";
		}

		// mouse-over effects of menubuttons and submenuitems
		function MouseOverMenuItem(source)
		{
		  source.firstChild.style.visibility = "visible";
		}
		function MouseOutMenuItem(source)
		{
		  source.firstChild.style.visibility = "hidden";
		}
		function MouseOverSubmenuItem(source)
		{
		  source.style.backgroundColor = "#14433F";
		}
		function MouseOutSubmenuItem(source)
		{
		  source.style.backgroundColor = "#0D2E2B";
		}
	</script>
	<?php echo template_place_holder('head_end'); ?>
</head>
<body onBeforeUnLoad="SaveMenu();" onUnload="SaveMenu();">
	<?php echo template_place_holder('body_start'); ?>
	<?php if(!empty($config['network_facebook'])) {?>
	<script type="text/javascript">
        window.fbAsyncInit = function() {
            FB.init({
                appId      : 497232093667125, // App ID
                status     : true,              // check login status
                cookie     : true,              // enable cookies to allow the server to access the session
                xfbml      : true               // parse XFBML
            });
            FB.Event.subscribe('auth.login', function() {
                var URLHelper = "?";
                if (window.location.search.replace("?", "").length > 0) {
                    URLHelper = "&";
                }
                if (FB_TryLogin == 1) {
                    window.location = window.location + URLHelper + "step=facebooktrylogin&wasreloaded=1";
                } else if (FB_TryLogin == 2) {
                    window.location = window.location + URLHelper + "page=facebooktrylogin&wasreloaded=1";
                } else {
                    window.location = window.location + URLHelper + "wasreloaded=1";
                }
            });
            FB.Event.subscribe('auth.logout', function(a_Response) {
                if (a_Response.status !== 'connected') {
                    window.location.href=window.location.href;
                } else {
                    /* nothing to do here*/
                }
            });
            FB.Event.subscribe('auth.statusChange', function(response) {
                if (FB_ForceReload == 1 && response.status == "connected") {
                    var URLHelper = "?";
                    if (window.location.search.replace("?", "").length > 0) {
                        URLHelper = "&";
                    }
                    window.location = window.location + URLHelper + "step=facebooktrylogin&wasreloaded=1";
                }
            });
        };
        (function(d){
            var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
            if (d.getElementById(id)) {return;}
            js = d.createElement('script'); js.id = id; js.async = true;
            js.src = "//connect.facebook.net/en_US/all.js";
            ref.parentNode.insertBefore(js, ref);
        }(document));
	</script>
	<?php } ?>
  <div id="top"></div>
  <div id="RedDAXEBar">
    <a href="/reddaxe/" id="RedDAXEBarLink" title="RedDAXE.pl — Portal">
      <span class="RedDAXEBarLogo">RedDAXE<span class="RedDAXEBarDot">.pl</span></span>
    </a>
  </div>
  <div id="ArtworkHelper" style="background-image:url(<?php echo $template_path; ?>/images/header/<?php echo $config['background_image']; ?>);" >
    <div id="Bodycontainer">
      <div id="ContentRow">
				<div id="MenuColumn">
					<div id="LeftArtwork">
						<img id="Statue_1" src="<?php echo $template_path; ?>/images/header/animated-statue.gif" alt="logoartwork" data-i18n-attr="alt" data-i18n="image.alt.logoartwork" />
						<img id="TibiaLogoArtworkTop" src="<?php echo $template_path; ?>/images/header/<?php echo $config['logo_image']; ?>" onClick="window.location = '<?php echo getLink('news')?>';" alt="logoartwork" data-i18n-attr="alt" data-i18n="image.alt.logoartwork" />
						<img id="TibiaLogoArtworkBottom" src="<?php echo $template_path; ?>/images/header/tibia-logo-artwork-bottom.gif" alt="logoartwork" data-i18n-attr="alt" data-i18n="image.alt.logoartwork" />
						<img id="Statue_2" src="<?php echo $template_path; ?>/images/header/animated-statue.gif" alt="logoartwork" data-i18n-attr="alt" data-i18n="image.alt.logoartwork" />
						<img id="LogoLink" src="<?php echo $template_path; ?>/images/header/tibia-logo-artwork-string.gif" onClick="window.location = 'mailto:<?php echo setting('core.mail_address'); ?>';" alt="logoartwork" data-i18n-attr="alt" data-i18n="image.alt.logoartwork" />
					</div>
					<?php
					$sidebarProfileMode = $_SESSION['global_profile_mode'] ?? 'all';
					if (!in_array($sidebarProfileMode, ['all', 'classic74', 'modern'], true)) {
						$sidebarProfileMode = 'all';
					}
					$sidebarModeLabels = [
						'all' => __('server_mode_all'),
						'classic74' => __('server_mode_classic74'),
						'modern' => __('server_mode_modern'),
					];
					$sidebarCurrentUri = $_SERVER['REQUEST_URI'] ?? '/';
					$sidebarSwitchBase = getLink('account/profile-switch');
					$sidebarManageUrl = BASE_URL . '?subtopic=accountmanagement';
					$sidebarCreateUrl = BASE_URL . 'reddaxe/account-create.php?source=tibiawww';
					$sidebarLogoutUrl = getLink('account/logout');
					?>
					<div id="Loginbox" class="GlobalLoginSidebar">
						<div class="GlobalLoginHead" data-i18n="sidebar.account_title"><?php echo __('sidebar_account_title'); ?></div>
						<div class="GlobalLoginBody">
							<?php if (!$logged): ?>
								<a class="GlobalLoginBtn" href="<?php echo $sidebarManageUrl; ?>" data-i18n="sidebar.login"><?php echo __('login'); ?></a>
								<a class="GlobalLoginBtn secondary" href="<?php echo $sidebarCreateUrl; ?>" data-i18n="sidebar.create_account"><?php echo __('create_account'); ?></a>
								<div class="GlobalLoginHint" data-i18n="sidebar.global_account_hint"><?php echo __('sidebar_global_account_hint'); ?></div>
							<?php else: ?>
								<div class="GlobalLoginHint">
									<span data-i18n="sidebar.logged_in_as"><?php echo __('sidebar_logged_in_as'); ?></span>
									<b><?php echo escapeHtml($account_logged->getName()); ?></b>
								</div>
								<a class="GlobalLoginBtn" href="<?php echo $sidebarManageUrl; ?>" data-i18n="sidebar.manage_account"><?php echo __('sidebar_manage_account'); ?></a>
								<a class="GlobalLoginBtn secondary" href="<?php echo $sidebarLogoutUrl; ?>" data-i18n="sidebar.logout"><?php echo __('sidebar_logout'); ?></a>
								<div class="GlobalProfileArea">
									<div class="GlobalProfileLabel" data-i18n="sidebar.global_profile"><?php echo __('sidebar_global_profile'); ?></div>
									<div class="GlobalProfileButtons">
										<?php foreach ($sidebarModeLabels as $sidebarModeKey => $sidebarModeLabel): ?>
											<?php
											$profileSwitchUrl = $sidebarSwitchBase . '?mode=' . urlencode($sidebarModeKey) . '&redirect=' . rawurlencode($sidebarCurrentUri);
											$profileClass = 'GlobalProfileBtn' . ($sidebarProfileMode === $sidebarModeKey ? ' isActive' : '');
											?>
											<a class="<?php echo $profileClass; ?>" href="<?php echo escapeHtml($profileSwitchUrl); ?>"><?php echo escapeHtml($sidebarModeLabel); ?></a>
										<?php endforeach; ?>
									</div>
								</div>
							<?php endif; ?>
						</div>
					</div>

<div id='Menu'>
<div id='MenuTop' style='background-image:url(<?php echo $template_path; ?>/images/general/box-top.gif);'></div>

<?php
$menus = get_template_menus();

$countElements = 0;
foreach($config['menu_categories'] as $id => $cat) {
	if (!isset($menus[$id]) || ($id == MENU_CATEGORY_SHOP && !setting('core.gifts_system'))) {
		continue;
	}

	$countElements++;
}

$i = 0;
foreach($config['menu_categories'] as $id => $cat) {
	if(!isset($menus[$id]) || ($id == MENU_CATEGORY_SHOP && !setting('core.gifts_system'))) {
		continue;
	}

	$i++;
	?>
<div id='<?php echo $cat['id']; ?>' class='menuitem'>
	<span onClick="MenuItemAction('<?php echo $cat['id']; ?>')">
		<div class='MenuButton' style='background-image:url(<?php echo $template_path; ?>/images/menu/button-background.gif);'>
			<div onMouseOver='MouseOverMenuItem(this);' onMouseOut='MouseOutMenuItem(this);'><div class='Button' style='background-image:url(<?php echo $template_path; ?>/images/menu/button-background-over.gif);'></div>
				<span id='<?php echo $cat['id']; ?>_Lights' class='Lights'>
					<div class='light_lu' style='background-image:url(<?php echo $template_path; ?>/images/menu/green-light.gif);'></div>
					<div class='light_ld' style='background-image:url(<?php echo $template_path; ?>/images/menu/green-light.gif);'></div>
					<div class='light_ru' style='background-image:url(<?php echo $template_path; ?>/images/menu/green-light.gif);'></div>
				</span>
				<div id='<?php echo $cat['id']; ?>_Icon' class='Icon' style='background-image:url(<?php echo $template_path; ?>/images/menu/icon-<?php echo $cat['id']; ?>.gif);'></div>
				<div id='<?php echo $cat['id']; ?>_Label' class='Label' style='background-image:url(<?php echo $template_path; ?>/images/menu/label-<?php echo $cat['id']; ?>.gif);'></div>
				<div id='<?php echo $cat['id']; ?>_Extend' class='Extend' style='background-image:url(<?php echo $template_path; ?>/images/general/plus.gif);'></div>
			</div>
		</div>
	</span>
	<div id='<?php echo $cat['id']; ?>_Submenu' class='Submenu'>
		<?php
			foreach($menus[$id] as $category => $menu) {
				$menuLinkFull = $menu['link_full'];
				if (($menu['link'] ?? '') === 'rules') {
					$menuLinkFull = BASE_URL . '?subtopic=rules';
				}
				?>
				<a href='<?php echo $menuLinkFull; ?>'<?= $menu['target_blank']?>>
					<div id='submenu_<?php echo str_replace('/', '_', $menu['link']); ?>' class='Submenuitem' onMouseOver='MouseOverSubmenuItem(this)' onMouseOut='MouseOutSubmenuItem(this)' >
					<div class='LeftChain' style='background-image:url(<?php echo $template_path; ?>/images/general/chain.gif);'></div>
					<div id='ActiveSubmenuItemIcon_<?php echo str_replace('/', '_', $menu['link']); ?>' class='ActiveSubmenuItemIcon' style='background-image:url(<?php echo $template_path; ?>/images/menu/icon-activesubmenu.gif);'></div>
					<div class='SubmenuitemLabel' <?php echo $menu['style_color']; ?>><?php echo $menu['name']; ?></div>
					<div class='RightChain' style='background-image:url(<?php echo $template_path; ?>/images/general/chain.gif);'></div>
				</div>
			</a>
			<?php
		}
	?>
	</div>
	<?php
	if ($i == $countElements) {
	?>
		<div id='MenuBottom' style='background-image:url(<?php echo $template_path; ?>/images/general/box-bottom.gif);'></div>
	<?php
	}
	?>
</div>
	<?php
	}
	?>
		</div>
		<script type="text/javascript">
			InitializePage();
        </script>
        </div>
        <div id="ContentColumn">
          <div class="Content">
            <div id="ContentHelper">
			<?php
				$twitchUrl = 'https://www.twitch.tv/directory/game/Tibia';
				$youtubeUrl = 'https://www.youtube.com/results?search_query=tibia';
				$fankitUrl = 'https://www.tibia.com/community/?subtopic=fansites';
			?>
			<div id="SocialNavBar" class="SocialNavBar">
				<a href="<?php echo $twitchUrl; ?>" target="_blank" rel="noopener">Twitch</a>
				<span class="dot"></span>
				<a href="<?php echo $youtubeUrl; ?>" target="_blank" rel="noopener">YouTube</a>
				<span class="dot"></span>
				<a href="<?php echo $fankitUrl; ?>" target="_blank" rel="noopener">Fankit</a>
			</div>
			<?php echo tickers(); ?>


  <div id="News" class="Box">
    <div class="Corner-tl" style="background-image:url(<?php echo $template_path; ?>/images/content/corner-tl.gif);"></div>
    <div class="Corner-tr" style="background-image:url(<?php echo $template_path; ?>/images/content/corner-tr.gif);"></div>
    <div class="Border_1" style="background-image:url(<?php echo $template_path; ?>/images/content/border-1.gif);"></div>
    <div class="BorderTitleText" style="background-image:url(<?php echo $template_path; ?>/images/content/title-background-green.gif);"></div>
	<?php
	$headline = $template_path.'/images/header/headline-' . PAGE . '.gif';
	$useDynamicHeadline = getBoolean(config('tibiacom_force_headline_php'));
	if($useDynamicHeadline || !file_exists(BASE . $headline))
		$headline = $template_path . '/headline.php?t=' . rawurlencode((string)$title);
?>
	<img class="Title" src="<?php echo $headline; ?>" alt="Contentbox headline" data-i18n-attr="alt" data-i18n="image.alt.contentbox_headline" />
    <div class="Border_2">
      <div class="Border_3">
		<?php $hooks->trigger(HOOK_TIBIACOM_BORDER_3); ?>
		<div class="BoxContent" style="background-image:url(<?php echo $template_path; ?>/images/content/scroll.gif);">
			<?php
			// K52/K154: Server mode + global account profile bar.
			$currentMode = $_SESSION['server_mode'] ?? 'all';
			if (isset($_GET['mode'])) {
				$currentMode = strtolower(trim((string)$_GET['mode']));
				if (!in_array($currentMode, ['all', 'classic74', 'modern'], true)) {
					$currentMode = 'all';
				}
				$_SESSION['server_mode'] = $currentMode;
				if ($logged) {
					$_SESSION['global_profile_mode'] = $currentMode;
				}
			}
			if (!in_array($currentMode, ['all', 'classic74', 'modern'], true)) {
				$currentMode = 'all';
				$_SESSION['server_mode'] = $currentMode;
			}

			$modeLabels = [
				'all' => __('server_mode_all'),
				'classic74' => __('server_mode_classic74'),
				'modern' => __('server_mode_modern')
			];

			$globalProfileMode = $_SESSION['global_profile_mode'] ?? 'all';
			if (!in_array($globalProfileMode, ['all', 'classic74', 'modern'], true)) {
				$globalProfileMode = 'all';
			}
			$globalProfileLabel = $modeLabels[$globalProfileMode] ?? 'All';

			$currentUri = $_SERVER['REQUEST_URI'] ?? '/';
			$uriPath = '/';
			$uriQueryParams = [];
			$parsedUri = @parse_url($currentUri);
			if (is_array($parsedUri)) {
				if (isset($parsedUri['path']) && is_string($parsedUri['path']) && $parsedUri['path'] !== '') {
					$uriPath = $parsedUri['path'];
				}
				if (isset($parsedUri['query']) && is_string($parsedUri['query']) && $parsedUri['query'] !== '') {
					parse_str($parsedUri['query'], $uriQueryParams);
				}
			}
			unset($uriQueryParams['mode']);
			?>
			<div id="serverModeBar" class="serverModeBar">
				<div class="serverModeBarInner">
					<span class="serverModeLabel"><?php echo __('server_mode_label'); ?>:</span>
					<?php foreach ($modeLabels as $mk => $ml): ?>
						<?php
							$modeQuery = $uriQueryParams;
							$modeQuery['mode'] = $mk;
							$modeHref = $uriPath . '?' . http_build_query($modeQuery);
						?>
						<?php if ($mk === $currentMode): ?>
							<span class="serverModePill isActive"><?php echo escapeHtml($ml); ?></span>
						<?php else: ?>
							<a class="serverModePill" href="<?php echo escapeHtml($modeHref); ?>"><?php echo escapeHtml($ml); ?></a>
						<?php endif; ?>
					<?php endforeach; ?>
				</div>
				<?php if ($logged): ?>
					<div class="globalAccountHint">
						<span><?php echo __('global_account_profile'); ?></span>
						<b><?php echo escapeHtml($globalProfileLabel); ?></b>
						<a href="<?php echo getLink('account/manage'); ?>"><?php echo __('manage_account'); ?></a>
					</div>
				<?php endif; ?>
			</div>
			<?php echo template_place_holder('center_top') . $content; ?>
		</div>
      </div>
    </div>
    <div class="Border_1" style="background-image:url(<?php echo $template_path; ?>/images/content/border-1.gif);"></div>

    <div class="CornerWrapper-b"><div class="Corner-bl" style="background-image:url(<?php echo $template_path; ?>/images/content/corner-bl.gif);"></div></div>
    <div class="CornerWrapper-b"><div class="Corner-br" style="background-image:url(<?php echo $template_path; ?>/images/content/corner-br.gif);"></div></div>
  </div>
           </div>
          </div>
			  <div id="Footer"><?php echo template_footer(); ?><br/><span data-i18n="footer.layout_credit"><?php echo __('footer_layout_credit'); ?></span></div>
        </div>
        <div id="ThemeboxesColumn">
          <div id="RightArtwork">
			<?php
			$onlineByWorld = ['classic74' => 0, 'modern' => 0];
			$globalOnlinePlayers = 0;
			$statusDataAvailable = false;
			try {
				if (isset($db) && $db->hasTable('players') && $db->hasColumn('players', 'online')) {
					if ($db->hasColumn('players', 'world')) {
						$stmtOnline = $db->query('SELECT `world`, COUNT(*) AS total FROM `players` WHERE `online` > 0 GROUP BY `world`');
						$rowsOnline = $stmtOnline ? $stmtOnline->fetchAll(PDO::FETCH_ASSOC) : [];
						foreach ((array)$rowsOnline as $rowOnline) {
							$worldId = (int)($rowOnline['world'] ?? -1);
							$totalOnline = (int)($rowOnline['total'] ?? 0);
							if ($worldId === 1) {
								$onlineByWorld['modern'] += $totalOnline;
							} else {
								$onlineByWorld['classic74'] += $totalOnline;
							}
							$globalOnlinePlayers += $totalOnline;
						}
					} else {
						$stmtOnline = $db->query('SELECT COUNT(*) AS total FROM `players` WHERE `online` > 0');
						$globalOnlinePlayers = (int)($stmtOnline ? $stmtOnline->fetchColumn() : 0);
						$onlineByWorld['classic74'] = $globalOnlinePlayers;
					}
					$statusDataAvailable = true;
				}
			}
			catch (Throwable $e) {
				$statusDataAvailable = false;
			}

			if (!$statusDataAvailable) {
				$globalOnlinePlayers = (int)($status['players'] ?? 0);
				if ($globalOnlinePlayers < 0) {
					$globalOnlinePlayers = 0;
				}
				$onlineByWorld['classic74'] = $globalOnlinePlayers;
			}

			$apiOnline = true;
			$gameStatusFromPing = (bool)($status['online'] ?? false);
			$worldStatusRows = [
				[
					'key' => 'classic74',
					'label' => __('server_mode_classic74'),
					'players' => (int)$onlineByWorld['classic74'],
					'online' => $statusDataAvailable ? true : $gameStatusFromPing,
				],
				[
					'key' => 'modern',
					'label' => __('server_mode_modern'),
					'players' => (int)$onlineByWorld['modern'],
					'online' => $statusDataAvailable ? true : $gameStatusFromPing,
				],
			];
			?>
			<img id="Monster" src="images/monsters/<?php echo logo_monster() ?>.gif" onClick="window.location = '?subtopic=creatures&creature=<?php echo $config['logo_monster'] ?>';" alt="Monster of the Week" data-i18n-attr="alt" data-i18n="image.alt.monster_the_week" />
			<img id="PedestalAndOnline" src="<?php echo $template_path; ?>/images/header/pedestal-and-online.gif" alt="Monster Pedestal and Players Online Box" data-i18n-attr="alt" data-i18n="image.alt.monster_pedestal_and"/>
          <div id="PlayersOnline">
			<div class="ServerStatusSummary">
				<div class="statusMainCount"><?php echo (int)$globalOnlinePlayers; ?></div>
				<div class="statusMainLabel" data-i18n="status.players"><?php echo __('status_players_online'); ?></div>
			</div>
			<details class="ServerStatusDetails">
				<summary>
					<span class="statusToggleText" data-i18n="status.server_details_toggle"><?php echo __('status_server_details_toggle'); ?></span>
				</summary>
				<div class="ServerStatusRow">
					<span class="statusServerName" data-i18n="status.api_status"><?php echo __('status_api_status'); ?></span>
					<span class="statusServerState <?php echo $apiOnline ? 'isOnline' : 'isOffline'; ?>" data-i18n="<?php echo $apiOnline ? 'status.online_short' : 'status.offline_short'; ?>"><?php echo $apiOnline ? __('status_online_short') : __('status_offline_short'); ?></span>
				</div>
				<?php foreach ($worldStatusRows as $worldStatusRow): ?>
					<div class="ServerStatusRow">
						<span class="statusServerName"><?php echo escapeHtml($worldStatusRow['label']); ?></span>
						<span class="statusServerState <?php echo $worldStatusRow['online'] ? 'isOnline' : 'isOffline'; ?>" data-i18n="<?php echo $worldStatusRow['online'] ? 'status.online_short' : 'status.offline_short'; ?>"><?php echo $worldStatusRow['online'] ? __('status_online_short') : __('status_offline_short'); ?></span>
						<span class="statusServerPlayers"><?php echo (int)$worldStatusRow['players']; ?></span>
					</div>
				<?php endforeach; ?>
				<a class="ServerStatusLink" href="<?php echo getLink('online'); ?>" data-i18n="status.view_online_list"><?php echo __('status_view_online_list'); ?></a>
			</details>
		  </div>
        </div>

        <div id="Themeboxes">
			<?php
			$twig_loader->prependPath(__DIR__ . '/boxes/templates');

			foreach($config['boxes'] as $box) {
				/** @var string $template_name */
				$file = __DIR__ . '/boxes/' . $box . '.php';
				if(file_exists($file)) {
					include($file); ?>
				<?php
				}
			}

		if($config['template_allow_change'])
			 echo '<span style="color: white" data-i18n="label.template_selector">' . __('label_template_selector') . '</span><br/>' . template_form();
	 ?>
        </div>
      </div>
     </div>
    </div>
  </div>
	<?php echo template_place_holder('body_end'); ?>
</body>
</html>
<?php
function logo_monster()
{
	global $config;
	return str_replace(" ", "", trim(strtolower($config['logo_monster'])));
}
