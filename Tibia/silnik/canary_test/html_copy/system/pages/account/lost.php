<?php
/**
 * Lost account
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */
defined('MYAAC') or die('Direct access not allowed!');
$title = __('lost_account');

if(!setting('core.mail_enabled'))
{
	echo '<b>System nie jest skonfigurowany do wysyłania e-maili. Nie możesz skorzystać z odzyskiwania konta. Skontaktuj się z administratorem.</b>';
	return;
}

$action_type = isset($_REQUEST['action_type']) ? $_REQUEST['action_type'] : '';
if($action == '')
{
	$twig->display('account.lost.form.html.twig');
}
else if($action == 'step1' && $action_type == '') {
	$twig->display('account.lost.noaction.html.twig');
}
elseif($action == 'step1' && $action_type == 'email')
{
	$nick = stripslashes($_REQUEST['nick']);
	if(Validator::characterName($nick))
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($nick);
		if($player->isLoaded())
			$account = $player->getAccount();

		if($account->isLoaded())
		{
			if($account->getCustomField('email_next') < time())
				echo 'Podaj adres e-mail przypisany do konta z tą postacią.<BR>
				<form action="' . getLink('account/lost') . '?action=sendcode" method=post>
				<input type=hidden name="character">
				<table cellspacing=1 cellpadding=4 border=0 width=100%>
				<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Podaj e-mail przypisany do konta</B></TD></TR>
				<TR><TD BGCOLOR="'.$config['darkborder'].'">
				Postać: <INPUT TYPE=text NAME="nick" VALUE="'.$nick.'" SIZE="40" readonly="readonly"><BR>
				E-mail do konta:<INPUT TYPE=text NAME="email" VALUE="" SIZE="40"><BR>
				</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				' . $twig->render('buttons.submit.html.twig') . '</div>
				</TD></TR></FORM></TABLE></TABLE>';
			else
			{
				$insec = (int)$account->getCustomField('email_next') - time();
				$minutesleft = floor($insec / 60);
				$sekundleft = $insec - ($minutesleft * 60);
				$timeleft = $minutesleft.' minut '.$secondsleft.' seconds';
				echo 'Konto wybranej postaci (<b>'.$nick.'</b>) otrzymało e-mail w ciągu ostatnich '.ceil(setting('core.mail_lost_account_interval') / 60).' minut. Musisz poczekać '.$timeleft.' zanim będziesz mógł ponownie skorzystać z odzyskiwania konta.';
			}
		}
		else
			echo 'Gracz lub konto gracza <b>' . $nick . '</b> nie istnieje.';
	}
	else
		echo 'Nieprawidłowy format nazwy postaci. Jeśli masz inne postacie na koncie, spróbuj z inną nazwą.';
	echo '<BR /><TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<a href="' . getLink('account/lost') . '" border="0"><IMG SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" NAME="Back" ALT="Back" BORDER=0 WIDTH=120 HEIGHT=18></a></div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'sendcode')
{
	$email = $_REQUEST['email'];
	$nick = stripslashes($_REQUEST['nick']);
	if(Validator::characterName($nick))
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($nick);
		if($player->isLoaded())
			$account = $player->getAccount();

		if($account->isLoaded())
		{
			if($account->getCustomField('email_next') < time())
			{
				if($account->getEMail() == $email)
				{
					$newcode = generateRandomString(30, true, false, true);
					$mailBody = '
					Prosiłeś o zresetowanie hasła do serwera ' . $config['lua']['serverName'] . '.<br/>
					<p>Nazwa konta: '.$account->getName().'</p>
					<br />
					Aby to zrobić, kliknij ten link:
					<p><a href="' . getLink('account/lost') . '?action=checkcode&code='.$newcode.'&character='.urlencode($nick).'">' . getLink('account/lost') . '?action=checkcode&code='.$newcode.'&character='.urlencode($nick).'</a></p>
					<p>lub otwórz stronę: <i>' . getLink('account/lost') . '?action=checkcode</i> i w polu "kod" wpisz <b>'.$newcode.'</b></p>
					<br/>
						<p>Jeśli nie prosiłeś o zmianę hasła, możesz zignorować tę wiadomość — hasło pozostanie niezmienione.';

					$account_mail = $account->getCustomField('email');
					if(_mail($account_mail, $config['lua']['serverName'].' - Odzyskiwanie konta', $mailBody))
					{
						$account->setCustomField('email_code', $newcode);
						$account->setCustomField('email_next', (time() + setting('core.mail_lost_account_interval')));
						echo '<br />Szczegóły dotyczące odzyskania konta zostały wysłane na <b>' . $account_mail . '</b>. You should receive this email within 15 minutes. Please check your inbox/spam directory.';
					}
					else
					{
						$account->setCustomField('email_next', (time() + 60));
						echo '<br /><p class="error">Wystąpił błąd podczas wysyłania e-maila! Spróbuj ponownie później lub skontaktuj się z administratorem. Dla admina: więcej informacji w system/logs/mailer-error.log</p>';
					}
				}
				else
					echo 'Nieprawidłowy e-mail do konta postaci <b>'.$nick.'</b>. Spróbuj ponownie.';
			}
			else
			{
				$insec = (int)$account->getCustomField('email_next') - time();
				$minutesleft = floor($insec / 60);
				$secondsleft = $insec - ($minutesleft * 60);
				$timeleft = $minutesleft.' minutes '.$secondsleft.' seconds';
				echo 'Account of selected character (<b>'.$nick.'</b>) received e-mail in last '.ceil(setting('core.mail_lost_account_interval') / 60).' minutes. You must wait '.$timeleft.' before you can use Lost Account Interface again.';
			}
		}
		else
			echo 'Player or account of player <b>'.$nick.'</b> doesn\'t exist.';
	}
	else
		echo 'Invalid player name format. If you have other characters on account try with other name.';
	echo '<BR /><TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<a href="' . getLink('account/lost') . '?action=step1&action_type=email&nick='.urlencode($nick).'" border="0"><IMG SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" NAME="Back" ALT="Back" BORDER=0 WIDTH=120 HEIGHT=18></a></div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'step1' && $action_type == 'reckey')
{
	$nick = stripslashes($_REQUEST['nick']);
	if(Validator::characterName($nick))
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($nick);
		if($player->isLoaded())
			$account = $player->getAccount();
		if($account->isLoaded())
		{
			$account_key = $account->getCustomField('key');
			if(!empty($account_key))
			{
						echo 'Jeśli wpiszesz prawidłowy klucz odzyskiwania, wyświetli się formularz do ustawienia nowego e-maila i hasła. Na ten e-mail zostanie wysłana nazwa konta i nowe hasło.<BR>
						<FORM ACTION="' . getLink('account/lost') . '?action=step2" METHOD=post>
						<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
						<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Podaj swój klucz odzyskiwania</B></TD></TR>
						<TR><TD BGCOLOR="'.$config['darkborder'].'">
						Nazwa postaci:&nbsp;<INPUT TYPE=text NAME="nick" VALUE="'.$nick.'" SIZE="40" readonly="readonly"><BR />
						Klucz odzyskiwania:&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE=text NAME="key" VALUE="" SIZE="40"><BR>
						</TD></TR>
						</TABLE>
						<BR>
						<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
						' . $twig->render('buttons.submit.html.twig') . '</div>
						</TD></TR></FORM></TABLE></TABLE>';
			}
			else
				echo 'Konto tej postaci nie ma klucza odzyskiwania!';
		}
		else
			echo 'Player or account of player <b>'.$nick.'</b> doesn\'t exist.';
	}
	else
		echo 'Invalid player name format. If you have other characters on account try with other name.';
	echo '<BR /><TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<a href="' . getLink('account/lost') . '" border="0"><IMG SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" NAME="Back" ALT="Back" BORDER=0 WIDTH=120 HEIGHT=18></a></div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'step2')
{
	$rec_key = trim($_REQUEST['key']);
	$nick = stripslashes($_REQUEST['nick']);
	if(Validator::characterName($nick))
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($nick);
		if($player->isLoaded())
			$account = $player->getAccount();
		if($account->isLoaded())
		{
			$account_key = $account->getCustomField('key');
			if(!empty($account_key))
			{
				if($account_key == $rec_key)
				{
					echo '<script type="text/javascript">
					function validate_required(field,alerttxt)
					{
					with (field)
					{
					if (value==null||value==""||value==" ")
					  {alert(alerttxt);return false;}
					else {return true}
					}
					}
					function validate_email(field,alerttxt)
					{
					with (field)
					{
					apos=value.indexOf("@");
					dotpos=value.lastIndexOf(".");
					if (apos<1||dotpos-apos<2)
					  {alert(alerttxt);return false;}
					else {return true;}
					}
					}
					function validate_form(thisform)
					{
					with (thisform)
					{
					if (validate_required(email,"Podaj swój e-mail!")==false)
					  {email.focus();return false;}
					if (validate_email(email,"Nieprawidłowy format e-maila!")==false)
					  {email.focus();return false;}
					if (validate_required(passor,"Podaj hasło!")==false)
					  {passor.focus();return false;}
					if (validate_required(passor2,"Powtórz hasło!")==false)
					  {passor2.focus();return false;}
					if (passor2.value!=passor.value)
					  {alert(\'Powtórzone hasło nie jest identyczne z hasłem!\');return false;}
					}
					}
					</script>';
					echo 'Ustaw nowe hasło i e-mail do konta.<BR>
					<FORM ACTION="' . getLink('account/lost') . '?action=step3" onsubmit="return validate_form(this)" METHOD=post>
					<INPUT TYPE=hidden NAME="character" VALUE="">
					<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
					<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Podaj nowe hasło i e-mail</B></TD></TR>
					<TR><TD BGCOLOR="'.$config['darkborder'].'">
					Konto postaci:&nbsp;&nbsp;<INPUT TYPE=text NAME="nick" VALUE="'.$nick.'" SIZE="40" readonly="readonly"><BR />
					Nowe hasło:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT id="passor" TYPE=password NAME="passor" VALUE="" SIZE="40"><BR>
					Powtórz nowe hasło:&nbsp;&nbsp;<INPUT id="passor2" TYPE=password NAME="passor" VALUE="" SIZE="40"><BR>
					Nowy adres e-mail:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT id="email" TYPE=text NAME="email" VALUE="" SIZE="40"><BR>
					<INPUT TYPE=hidden NAME="key" VALUE="'.$rec_key.'">
					</TD></TR>
					</TABLE>
					<BR>
					<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
					' . $twig->render('buttons.submit.html.twig') . '</div>
					</TD></TR></FORM></TABLE></TABLE>';
				}
				else
					echo 'Błędny klucz odzyskiwania!';
			}
			else
				echo 'Account of this character has no recovery key!';
		}
		else
			echo 'Player or account of player <b>'.$nick.'</b> doesn\'t exist.';
	}
	else
		echo 'Invalid player name format. If you have other characters on account try with other name.';
	echo '<BR /><TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<a href="' . getLink('account/lost') . '?action=step1&action_type=reckey&nick='.urlencode($nick).'" border="0"><IMG SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" NAME="Back" ALT="Back" BORDER=0 WIDTH=120 HEIGHT=18></a></div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'step3')
{
	$rec_key = trim($_REQUEST['key']);
	$nick = stripslashes($_REQUEST['nick']);
	$new_pass = trim($_REQUEST['passor']);
	$new_email = trim($_REQUEST['email']);
	if(Validator::characterName($nick))
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($nick);
		if($player->isLoaded())
			$account = $player->getAccount();
		if($account->isLoaded())
		{
			$account_key = $account->getCustomField('key');
			if(!empty($account_key))
			{
				if($account_key == $rec_key)
				{
					if(Validator::password($new_pass))
					{
						if(Validator::email($new_email))
						{
							$account->setEMail($new_email);

							$tmp_new_pass = $new_pass;
							if(USE_ACCOUNT_SALT)
							{
								$salt = generateRandomString(10, false, true, true);
								$tmp_new_pass = $salt . $new_pass;
							}

							$account->setPassword(encrypt($tmp_new_pass));
							$account->save();
							$account->setCustomField('engine_password_sha1', sha1($new_pass));

							if(USE_ACCOUNT_SALT)
								$account->setCustomField('salt', $salt);

							echo 'Twoja nazwa konta, nowe hasło i nowy e-mail.<BR>
							<FORM ACTION="' . getLink('account/manage') . '" onsubmit="return validate_form(this)" METHOD=post>
							<INPUT TYPE=hidden NAME="character" VALUE="">
							<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
							<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Twoja nazwa konta, nowe hasło i nowy e-mail</B></TD></TR>
							<TR><TD BGCOLOR="'.$config['darkborder'].'">
							Account name:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>'.$account->getName().'</b><BR>
							Nowe hasło:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>'.$new_pass.'</b><BR>
							Nowy adres e-mail:&nbsp;<b>'.$new_email.'</b><BR>';
							if($account->getCustomField('email_next') < time())
							{
								$mailBody = '
								<h3>Your account name and new password!</h3>
								<p>Zmieniono hasło i e-mail do konta w panelu odzyskiwania konta na serwerze <a href="'.BASE_URL.'"><b>'.$config['lua']['serverName'].'</b></a></p>
								<p>Account name: <b>'.$account->getName().'</b></p>
								<p>New password: <b>'.$new_pass.'</b></p>
								<p>E-mail: <b>'.$new_email.'</b> (ten e-mail)</p>
								<br />
								<p><u>To jest automatyczny e-mail z systemu odzyskiwania konta. Nie odpowiadaj!</u></p>';

								if(_mail($account->getCustomField('email'), $config['lua']['serverName']." - Nowe hasło do konta", $mailBody))
								{
									echo '<br /><small>Wysłano e-mail z nazwą konta i hasłem na nowy adres e-mail. Powinieneś go otrzymać w ciągu 15 minut. Możesz się teraz zalogować nowym hasłem!</small>';
								}
								else
								{
									echo '<br /><p class="error">Wystąpił błąd podczas wysyłania e-maila! Nie otrzymasz e-maila z tymi informacjami. Dla admina: więcej informacji w system/logs/mailer-error.log</p>';
								}
							}
							else
							{
								echo '<br /><small>Nie otrzymasz e-maila z tymi informacjami.</small>';
							}
							echo '<INPUT TYPE=hidden NAME="account_login" VALUE="'.$account->getId().'">
							<INPUT TYPE=hidden NAME="password_login" VALUE="'.$new_pass.'">
							</TD></TR></TABLE><BR>
							<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
							<INPUT TYPE=image NAME="Login" ALT="Login" SRC="'.$template_path.'/images/global/buttons/sbutton_login.gif" BORDER=0 WIDTH=120 HEIGHT=18></div>
							</TD></TR></FORM></TABLE></TABLE>';
						}
						else
							echo Validator::getLastError();
					}
					else
						echo Validator::getLastError();
				}
				else
					echo 'Wrong recovery key!';
			}
			else
				echo 'Account of this character has no recovery key!';
		}
		else
			echo 'Player or account of player <b>'.$nick.'</b> doesn\'t exist.';
	}
	else
		echo 'Invalid player name format. If you have other characters on account try with other name.';
	echo '<BR /><TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<a href="' . getLink('account/lost') . '?action=step1&action_type=reckey&nick='.urlencode($nick).'" border="0"><IMG SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" NAME="Back" ALT="Back" BORDER=0 WIDTH=120 HEIGHT=18></a></div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'checkcode')
{
	$code = trim($_REQUEST['code']);
	$character = stripslashes(trim($_REQUEST['character']));
	if(empty($code) || empty($character))
		echo 'Podaj kod z e-maila i nazwę jednej postaci z konta. Następnie naciśnij Wyślij.<BR>
				<FORM ACTION="' . getLink('account/lost') . '?action=checkcode" METHOD=post>
				<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
				<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Kod i nazwa postaci</B></TD></TR>
				<TR><TD BGCOLOR="'.$config['darkborder'].'">
				Twój kod:&nbsp;<INPUT TYPE=text NAME="code" VALUE="" SIZE="40")><BR />
				Character:&nbsp;<INPUT TYPE=text NAME="character" VALUE="" SIZE="40")><BR />
				</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				' . $twig->render('buttons.submit.html.twig') . '</div>
				</TD></TR></FORM></TABLE></TABLE>';
	else
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($character);
		if($player->isLoaded())
			$account = $player->getAccount();
		if($account->isLoaded())
		{
			if($account->getCustomField('email_code') == $code)
			{
				echo '<script type="text/javascript">
				function validate_required(field,alerttxt)
				{
				with (field)
				{
				if (value==null||value==""||value==" ")
				  {alert(alerttxt);return false;}
				else {return true}
				}
				}

				function validate_form(thisform)
				{
				with (thisform)
				{
				if (validate_required(passor,"Please enter password!")==false)
				  {passor.focus();return false;}
				if (validate_required(passor2,"Please repeat password!")==false)
				  {passor2.focus();return false;}
				if (passor2.value!=passor.value)
				  {alert(\'Repeated password is not equal to password!\');return false;}
				}
				}
				</script>
				Podaj nowe hasło do konta i powtórz je, aby upewnić się, że je zapamiętasz.<BR>
				<FORM ACTION="' . getLink('account/lost') . '?action=setnewpassword" onsubmit="return validate_form(this)" METHOD=post>
				<INPUT TYPE=hidden NAME="character" VALUE="'.$character.'">
				<INPUT TYPE=hidden NAME="code" VALUE="'.$code.'">
				<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
				<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Kod i nazwa konta</B></TD></TR>
				<TR><TD BGCOLOR="'.$config['darkborder'].'">
				New password:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE=password ID="passor" NAME="passor" VALUE="" SIZE="40")><BR />
				Repeat new password:&nbsp;<INPUT TYPE=password ID="passor2" NAME="passor2" VALUE="" SIZE="40")><BR />
				</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				' . $twig->render('buttons.submit.html.twig') . '</div>
				</TD></TR></FORM></TABLE></TABLE>';
			}
			else
				$error= 'Błędny kod do zmiany hasła.';
		}
		else
			$error = 'Konto tej postaci lub ta postać nie istnieje.';
	}
	if(!empty($error))
				echo '<span style="color: red"><b>'.$error.'</b></span><br />Please enter code from e-mail and name of one character from account. Then press Submit.<BR>
				<FORM ACTION="' . getLink('account/lost') . '?action=checkcode" METHOD=post>
				<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
				<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Code & character name</B></TD></TR>
				<TR><TD BGCOLOR="'.$config['darkborder'].'">
				Your code:&nbsp;<INPUT TYPE=text NAME="code" VALUE="" SIZE="40")><BR />
				Character:&nbsp;<INPUT TYPE=text NAME="character" VALUE="" SIZE="40")><BR />
				</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				' . $twig->render('buttons.submit.html.twig') . '</div>
				</TD></TR></FORM></TABLE></TABLE>';
}
elseif($action == 'setnewpassword')
{
	$newpassword = $_REQUEST['passor'];
	$code = $_REQUEST['code'];
	$character = stripslashes($_REQUEST['character']);
	echo '';
	if(empty($code) || empty($character) || empty($newpassword))
		echo '<span style="color: red"><b>Błąd. Spróbuj ponownie.</b></span><br />Please enter code from e-mail and name of one character from account. Then press Submit.<BR>
				<BR><FORM ACTION="' . getLink('account/lost') . '?action=checkcode" METHOD=post>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<INPUT TYPE=image NAME="Back" ALT="Back" SRC="'.$template_path.'/images/global/buttons/sbutton_back.gif" BORDER=0 WIDTH=120 HEIGHT=18></div>
				</TD></TR></FORM></TABLE></TABLE>';
	else
	{
		$player = new OTS_Player();
		$account = new OTS_Account();
		$player->find($character);
		if($player->isLoaded())
			$account = $player->getAccount();
		if($account->isLoaded())
		{
			if($account->getCustomField('email_code') == $code)
			{
				if(Validator::password($newpassword))
				{
					$tmp_new_pass = $newpassword;
					if(USE_ACCOUNT_SALT)
					{
						$salt = generateRandomString(10, false, true, true);
						$tmp_new_pass  = $salt . $newpassword;
						$account->setCustomField('salt', $salt);
					}

					$account->setPassword(encrypt($tmp_new_pass ));
					$account->save();
					$account->setCustomField('engine_password_sha1', sha1($newpassword));
					$account->setCustomField('email_code', '');
					echo 'Nowe hasło do konta poniżej. Możesz się teraz zalogować.<BR>
					<INPUT TYPE=hidden NAME="character" VALUE="'.$character.'">
					<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
					<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Zmieniono hasło</B></TD></TR>
					<TR><TD BGCOLOR="'.$config['darkborder'].'">
					New password:&nbsp;<b>'.$newpassword.'</b><BR />
					Account name:&nbsp;&nbsp;&nbsp;<i>(Już na Twoim e-mailu)</i><BR />';

					$mailBody = '
					<h3>Your account name and password!</h3>
					<p>Zmieniono hasło do konta w panelu odzyskiwania konta na serwerze <a href="'.BASE_URL.'"><b>'.$config['lua']['serverName'].'</b></a></p>
					<p>Account name: <b>'.$account->getName().'</b></p>
					<p>New password: <b>'.$newpassword.'</b></p>
					<br />
					<p><u>It\'s automatic e-mail from OTS Lost Account System. Do not reply!</u></p>';

					if(_mail($account->getCustomField('email'), $config['lua']['serverName']." - Your new password", $mailBody))
					{
						echo '<br /><small>Nowe hasło działa! Wysłano e-mail z hasłem i nazwą konta. Powinieneś go otrzymać w ciągu 15 minut. Możesz się teraz zalogować nowym hasłem!';
					}
					else
					{
						echo '<br /><p class="error">Nowe hasło działa! Wystąpił błąd podczas wysyłania e-maila! Nie otrzymasz e-maila z nowym hasłem. Dla admina: więcej informacji w system/logs/mailer-error.log';
					}
				echo '</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				<FORM ACTION="' . getLink('account/manage') . '" METHOD=post>
				<INPUT TYPE=image NAME="Login" ALT="Login" SRC="'.$template_path.'/images/global/buttons/sbutton_login.gif" BORDER=0 WIDTH=120 HEIGHT=18></div>
				</TD></TR></FORM></TABLE></TABLE>';
				}
				else
					$error= Validator::getLastError();
			}
			else
				$error= 'Wrong code to change password.';
		}
		else
			$error = 'Account of this character or this character doesn\'t exist.';
	}
	if(!empty($error))
				echo '<span style="color: red"><b>'.$error.'</b></span><br />Please enter code from e-mail and name of one character from account. Then press Submit.<BR>
				<FORM ACTION="' . getLink('account/lost') . '?action=checkcode" METHOD=post>
				<TABLE CELLSPACING=1 CELLPADDING=4 BORDER=0 WIDTH=100%>
				<TR><TD BGCOLOR="'.$config['vdarkborder'].'" class="white"><B>Code & character name</B></TD></TR>
				<TR><TD BGCOLOR="'.$config['darkborder'].'">
				Your code:&nbsp;<INPUT TYPE=text NAME="code" VALUE="" SIZE="40")><BR />
				Character:&nbsp;<INPUT TYPE=text NAME="character" VALUE="" SIZE="40")><BR />
				</TD></TR>
				</TABLE>
				<BR>
				<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH=100%><TR><TD><div style="text-align:center">
				' . $twig->render('buttons.submit.html.twig') . '</div>
				</TD></TR></FORM></TABLE></TABLE>';
}
