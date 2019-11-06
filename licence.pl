#!/usr/bin/perl -w

use lib '/home/www/cgi-bin';
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use strict;
use Data::Dumper;
use DBI;
use Licence;
use JSON;


print "Content-type: text/html\n\n";



my $dbh=undef;

my %act=(
	"print_menu"=>\&Print_menu,
	"add_form"=>\&Add_form,	
	"add"=>\&Add,
	"block_form"=>\&Block_form,
	"block"=>\&Block,	
	"unblock_form"=>\&Unblock_form,
	"unblock"=>\&Unblock,
	"edit_form"=>\&Edit_form,
	"update_form"=>\&Update_form,
	"update"=>\&Update,
	"del_form"=>\&Del_form,
	"delete"=>\&Delete,	
	"view"=>\&View	
	);


my $q = CGI->new;
my $keywords = $q->param('POSTDATA');
#print Dumper($keywords);

#my $input=decode_json $q->param('POSTDATA');

#my $action=$input->{'request_type'};

my $action=param('action');

if (!defined($action)) {$action='print_menu';}


if ((!defined($action))||(!exists($act{$action})))
{
	print "Неверный код команды!";
	exit 0;
}
else
{
	$dbh=&Licence::Connect;
	$dbh->do("use $config{'dbname'}");
	&{$act{$action}}($dbh);
	$dbh->disconnect;
}



sub Print_menu
{
	
print <<END
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<TITLE>Управление лицензиями</TITLE>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="#C0c0c0" TEXT="#000000" LINK="#0000ff" VLINK="#800080" ALINK="#ff0000">
<H2>Управление лицензиями</H2>

<a href="licence.pl?action=add_form">Создать лицензию</a>
<br><a href="licence.pl?action=block_form">Блокировать лицензию</a>
<br><a href="licence.pl?action=unblock_form">Разблокировать лицензию</a>
<br><a href="licence.pl?action=edit_form">Изменить лицензию</a>
<br><a href="licence.pl?action=del_form">Удалить лицензию</a>
<br><a href="licence.pl?action=view">Просмотр лицензий</a>
<br>

</BODY>
</HTML>
END
;
}





sub Add_form
{
	my ($dbh)=@_;
		
	
	&Print_html_header("Добавление лицензии");	
	print <<END
<Form Action="licence.pl" Method=Post name=myform>
<table border=0>
<tr><td valign="middle">
<table border=0>
<tr><td>Название компании:</td>
<td><INPUT TYPE="text" NAME="CompanyName" SIZE="35" MAXLENGTH="60"></td></tr>
<tr><td>Текст приветствия:</td>
<td><INPUT TYPE="text" NAME="WelcomingText" SIZE="35" MAXLENGTH="255"></td></tr>
<tr><td>Лимит устройств:</td>
<td><INPUT TYPE="number" NAME="DeviceLimit" SIZE="5" MAXLENGTH="5" value="3"></td></tr>
<tr><td>Окончание лицензии:</td>
<td><input name="end_lic" type="text" onfocus="this.select();lcs(this)" value="{$input['beg_date']}"
	onclick="event.cancelBubble=true;this.select();lcs(this)"></td></tr>
<tr><td>Генерация пароля:</td>
<td><INPUT TYPE="checkbox" NAME="psw_gen" checked value=1></td></tr>
<tr><td>Комментарий:</td>
<td><INPUT TYPE="text" NAME="Comment" SIZE="35" MAXLENGTH="255"></td></tr>
</table>
</td><td>&nbsp;&nbsp;</td><td valign="middle">
</table>

&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="submit" VALUE="Добавить!">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="button"  VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
<input type=hidden name="action" value="add" >
</FORM>
</BODY>
</HTML>
END
;
}


sub Add
{
	my ($dbh)=@_;
	
	my $end_lic=undef;
	my $input;
	foreach (param())
	{
		$input->{$_}=param($_);
	}
	
	
	my $psw1=sprintf('%.6d', int(rand(999999)));
	my $psw2=sprintf('%.6d', int(rand(999999)));
	my $psw3=sprintf('%.6d', int(rand(999999)));
	
	
	my $uuid=sprintf('%.4d', int(rand(9999)));
	
	for(my $i=0;$i<3;$i++)
	{
		my $r=sprintf('%.4d', int(rand(9999)));
		$uuid="$uuid-$r";		
	}
	
	unless ((defined($input->{psw_gen}))and ($input->{psw_gen} == 1))
	{
		$psw1='000000';
		$psw2=$psw1;
		$psw3=$psw1;
	}
	
	if ((defined($input->{end_lic}))&&($input->{end_lic}!=''))
	{
		$end_lic=Convert_date_to_MySQL($input->{end_lic});
	}
	else { $input->{end_lic}=''; }
	
	my $sth = $dbh->prepare( qq|INSERT INTO License (CompanyName ,Comment,WelcomingText,DeviceLimit, psw1,psw2,psw3, uuid,end_lic ) values (?,?,?,?,"$psw1","$psw2","$psw3",?,?)|);
 	
 	
 	
 	if (!$sth->execute($input->{'CompanyName'},$input->{'Comment'},$input->{'WelcomingText'},$input->{'DeviceLimit'},$uuid, $end_lic))
 		{ die("Can not add Licence!");	}		
 	
 	my $id=$sth->{mysql_insertid};
	
	my $licnum=$id+7643;
	
	
	my $query=qq|UPDATE License SET LicNUM=? WHERE id=?|;
	$sth=$dbh->prepare($query);

		if (!$sth->execute($licnum, $id))
		{
			die ("Can not SET licNUM in database");
		}
	
	
	&Print_html_header("Добавление лицензии");
	
		
 			print <<END
<b>Добавлена информация:</b>
<table border=0>
<tr><td>Название компании:</td>
<td>$input->{CompanyName}</td></tr>
<tr><td>Номер лицензии:</td>
<td>$licnum</td></tr>
<tr><td>uuid:</td>
<td>$uuid</td></tr>
<tr><td>Пояснительный текст:</td>
<td>$input->{WelcomingText}</td></tr>
<tr><td>Окончание лицензии:</td>
<td>$input->{end_lic}</td></tr>
<tr><td>Число устройств:</td>
<td>$input->{'DeviceLimit'}</td></tr>
<tr><td>Комментарий:</td>
<td>$input->{Comment}</td></tr>
<tr><td>Пароли:</td>
<td>$psw1&nbsp;<br>
$psw2&nbsp;</br>
$psw3&nbsp;</td>
<td></td></tr>
</table>
<br>
<img src="http://qrcoder.ru/code/?$uuid&4&0" alt="QR_error">
<br>
<A HREF="licence.pl?action=add_form">Добавить еще</A>&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>
</body>
</html>
END
; 	 			
	
}






sub View
{
	my ($dbh)=@_;
	
		
	&Print_html_header('');
	
	print <<END
<center>
<h2>Лицензии</h2>
<table border=0 align="center">
<tr><td align="center">
END
;
	
	
	
print<<END
<table cellspacing=0 cellpadding=3 border=1>
<tr valign="top" ><td width=100>Компания</td><td width=100>Номер лицензии</td><td width=100>uuid</td><td width=100>Приветствие</td><td width=100>Комментарий</td><td width=70>Статус лицензии</td><td width=70>Пароль 1</td><td width=70>Пароль 2</td> <td width=70>Пароль 3</td><td width=50> Число устройств</td><td width=150>DeviceInfo</td>
</tr>
END
;
	my $sth = $dbh->prepare(  qq{SELECT CompanyName,LicNUM,uuid, WelcomingText,Comment,LicStatus,psw1,psw2,psw3,DeviceInfo,DeviceLimit FROM License order by CompanyName,id ASC} );
	$sth->execute;	
	
	while (my $ref = $sth->fetchrow_hashref) 
	{
	#	foreach (qw(post name cityphone localphone email remark room directnum))
	#	{
	#		if (!defined($ref->{$_}))
	#			{ $ref->{$_}='' }
	#	}
		
		my $licstatus=&Licence_Status($ref->{LicStatus});	
		
		print <<END
<tr>
<td>$ref->{CompanyName}&nbsp;</td>
<td>$ref->{LicNUM}&nbsp;</td>
<td>$ref->{uuid}&nbsp;</td>
<td>$ref->{WelcomingText}&nbsp;</td>
<td>$ref->{Comment}&nbsp;</td>
<td>$licstatus &nbsp;</td>
<td>$ref->{psw1}&nbsp;</td>
<td>$ref->{psw2}&nbsp;</td>
<td>$ref->{psw3}&nbsp;</td>
<td>$ref->{DeviceLimit}&nbsp;</td>
<td>$ref->{DeviceInfo}&nbsp;</td>
</tr>
END
;
	}		
	print "</table>";

	
	print <<END
	<br>
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>
</td></tr></table>
</center>
</body>
</html>
END
;	



}




sub Block_form
{
	my ($dbh)=@_;
	
	&Print_html_header("Блокировка лицензии");	
		
	print <<END

<Form Action="licence.pl" Method=Post name=myform>

<table cellspacing=0 border=0 bgcolor=#CCCCCC>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Статус</td><td >Комментарий</td></tr>
END
;	
	my $sth = $dbh->prepare( qq|SELECT id, CompanyName, LicNUM, LicStatus, Comment  FROM License order by CompanyName ASC |);
	$sth->execute();

	
#проходим сквозь БД, печатаем заголовки пунктов
while (my $ref = $sth->fetchrow_arrayref) 
{	
	my $licstatus=&Licence_Status($ref->[3]);	
			
	print qq|<tr><td bgcolor=#DDDDDD><font color="purple">$ref->[1]&nbsp;&nbsp;</font></td><TD bgcolor=#DDDDDD>$ref->[2] &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$licstatus &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$ref->[4] &nbsp;&nbsp;</td><td valign=left width=10><INPUT TYPE="checkbox" NAME="id" VALUE="$ref->[0]"></td></tr>|;
}

	
print <<END
<tr><td colspan=4 >
<br>
<input type=hidden name="action" value="block">
<INPUT TYPE="submit" VALUE="Заблокировать">&nbsp;&nbsp;&nbsp;&nbsp;

<INPUT TYPE="button" VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="reset" VALUE="Очистить">
</td></tr>
</table>

</FORM>
</body>
</html>
END
;
}


sub Block
{

	my ($dbh)=@_;
	
	my @id=param('id');

	unless (@id) { &Print_menu; return;}
	
	@id=map {$_=$dbh->quote($_)} @id;
		
	my $idlist = join(',',@id);

	&Print_html_header('Данные лицензии были заблокированы');
		
	
	my $sth = $dbh->prepare(  qq{SELECT id, CompanyName, LicNUM, Comment  FROM License where id IN($idlist)} );
	$sth->execute;
			
	print <<END
<table cellspacing=0 cellpadding=5 border=1 bgcolor=#C0C0C0>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Комментарий</td></tr></tr>
END
;		
	while (my $ref = $sth->fetchrow_arrayref) 
	{
		print qq|<tr><td>$ref->[1]&nbsp;&nbsp;</td><TD>$ref->[2] &nbsp;&nbsp;</td><TD >$ref->[3] &nbsp;&nbsp;</td></tr>|;
	}		
	
	print "</table>";

			
	$sth = $dbh->prepare(  qq{UPDATE License SET LicStatus=-1 WHERE id IN($idlist)});
	
	my @id=param('id');
	$sth->execute;
			
	
	print <<END
<br>

<A HREF="licence.pl?action=block_form">Заблокировать еще</A>&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>

</body>
</html>
END
;
}



sub Unblock_form
{
	my ($dbh)=@_;
	
	&Print_html_header("Разблокировка лицензии");	
		
	print <<END

<Form Action="licence.pl" Method=Post name=myform>

<table cellspacing=0 border=0 bgcolor=#CCCCCC>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Статус</td><td >Комментарий</td></tr>
END
;	
	my $sth = $dbh->prepare( qq|SELECT id, CompanyName, LicNUM, LicStatus, Comment  FROM License order by CompanyName ASC |);
	$sth->execute();

	
#проходим сквозь БД, печатаем заголовки пунктов
while (my $ref = $sth->fetchrow_arrayref) 
{	
	my $licstatus=&Licence_Status($ref->[3]);	
			
	print qq|<tr><td bgcolor=#DDDDDD><font color="purple">$ref->[1]&nbsp;&nbsp;</font></td><TD bgcolor=#DDDDDD>$ref->[2] &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$licstatus &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$ref->[4] &nbsp;&nbsp;</td><td valign=left width=10><INPUT TYPE="checkbox" NAME="id" VALUE="$ref->[0]"></td></tr>|;
}

	
print <<END
<tr><td colspan=4 >
<br>
<input type=hidden name="action" value="unblock">
<INPUT TYPE="submit" VALUE="Разблокировать">&nbsp;&nbsp;&nbsp;&nbsp;

<INPUT TYPE="button" VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="reset" VALUE="Очистить">
</td></tr>
</table>

</FORM>
</body>
</html>
END
;
}


sub Unblock
{

	my ($dbh)=@_;
	
	my @id=param('id');

	unless (@id) { &Print_menu; return;}
	
	@id=map {$_=$dbh->quote($_)} @id;
		
	my $idlist = join(',',@id);

	&Print_html_header('Данные лицензии были разблокированы');
		
	
	my $sth = $dbh->prepare(  qq{SELECT id, CompanyName, LicNUM, Comment  FROM License where id IN($idlist)} );
	$sth->execute;
			
	print <<END
<table cellspacing=0 cellpadding=5 border=1 bgcolor=#C0C0C0>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Комментарий</td></tr></tr>
END
;		
	while (my $ref = $sth->fetchrow_arrayref) 
	{
		print qq|<tr><td>$ref->[1]&nbsp;&nbsp;</td><TD>$ref->[2] &nbsp;&nbsp;</td><TD >$ref->[3] &nbsp;&nbsp;</td></tr>|;
	}		
	
	print "</table>";

			
	$sth = $dbh->prepare(  qq{UPDATE License SET LicStatus=0 WHERE id IN($idlist)});
	
	my @id=param('id');
	$sth->execute;
			
	
	print <<END
<br>

<A HREF="licence.pl?action=unblock_form">Разблокировать еще</A>&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>

</body>
</html>
END
;
}


sub Edit_form
{
	my ($dbh)=@_;
	
	&Print_html_header("Изменение лицензий");	
		
	print <<END

<Form Action="licence.pl" Method=Post name=myform>

<table cellspacing=0 border=0 bgcolor=#CCCCCC>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Комментарий</td><td>&nbsp;</td></tr>
END
;	
	my $sth = $dbh->prepare( qq|SELECT id, CompanyName, LicNUM, Comment  FROM License order by CompanyName ASC |);
	$sth->execute();

	
#проходим сквозь БД, печатаем заголовки пунктов
while (my $ref = $sth->fetchrow_arrayref) 
{	
			
	print qq|<tr><td bgcolor=#DDDDDD><font color="purple">$ref->[1]&nbsp;&nbsp;</font></td><TD bgcolor=#DDDDDD>$ref->[2] &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$ref->[3] &nbsp;&nbsp;</td><td valign=left width=10><INPUT TYPE="checkbox" NAME="id" VALUE="$ref->[0]"></td></tr>|;
}

	
print <<END
<tr><td colspan=4 >
<br>
<input type=hidden name="action" value="update_form">
<INPUT TYPE="submit" VALUE="Изменить">&nbsp;&nbsp;&nbsp;&nbsp;

<INPUT TYPE="button" VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="reset" VALUE="Очистить">
</td></tr>
</table>

</FORM>
</body>
</html>
END
;
}



sub Update_form
{
	my ($dbh)=@_;
	
	my @id=param('id');
	
	unless (@id) { &Print_menu; return;}
		
	&Print_html_header("Изменение лицензии");
		
	my $sth = $dbh->prepare( qq|SELECT * FROM License where id=? |);
	$sth->execute($id[0]);


	#Проходим сквозь БД
	if (my $ref = $sth->fetchrow_hashref) 
	{			
	
	print <<END
<Form Action="licence.pl" Method=Post name=myform>
END
;
	
	
	foreach (keys(%$ref))
	{
		if (!defined($ref->{$_})){ $ref->{$_}='' }
		$ref->{$_}=CGI->escapeHTML($ref->{$_});
	} 
	
	
	print <<END
<table border=0>
<tr><td valign="middle">

<table border=0>
<tr><td valign="middle">
<table border=0>
<tr><td>Название компании:</td>
<td><INPUT TYPE="text" NAME="CompanyName" SIZE="35" MAXLENGTH="60"  value="$ref->{CompanyName}"></td></tr>
<tr><td>Пояснительный текст:</td>
<td><INPUT TYPE="text" NAME="WelcomingText" SIZE="35" MAXLENGTH="255"  value="$ref->{WelcomingText}"></td></tr>
<tr><td>Число устройств:</td>
<td><INPUT TYPE="text" NAME="DeviceLimit" SIZE="5" MAXLENGTH="5" value="$ref->{DeviceLimit}"></td></tr>
<tr><td>Комментарий:</td>
<td><INPUT TYPE="text" NAME="Comment" SIZE="35" MAXLENGTH="255" value="$ref->{Comment}"   ></td></tr>
</table>
</td><td>&nbsp;&nbsp;</td><td valign="middle">
</table>
END
;
	
	
	
	print <<END
<br>
<input type=hidden name="action" value="update" >
<INPUT TYPE="hidden" NAME="id" VALUE="$ref->{'id'}">
&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="submit" VALUE="Изменить!">&nbsp;&nbsp;&nbsp;
<INPUT TYPE="Reset" VALUE="Восстановить">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="button" VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
</FORM>
END
;
	}
print <<END
</body>
</html>
END
;
}


sub Update
{

	my ($dbh)=@_;
	&Print_html_header('Изменение лицензии');

	my $input;
	foreach (param())
	{
		$input->{$_}=param($_);
	}

	my $error;
	
#	if (!$input->{name}) 
#		{$error.= "не указано ФИО<br>";} 
		
#	if (!$input->{email}) 
#		{$error.= "не указан email<br>";} 
	
#	if ($input->{email}&&$input->{email}!~/^[-\w.]+\@[-\w.]+$/) 
#	{
#		$error.="введенный e-mail не соответствует форме foo\@nowhere.com<br>";
#	}
				
	unless ($error)
	{ 				
	
#Изменяем 

		$dbh->{RaiseError} = 0;
		$dbh->{PrintError} = 1;

		my $query=qq|UPDATE License SET CompanyName=?, Comment=?, WelcomingText=?, DeviceLimit=? WHERE id=?|;
		my $sth=$dbh->prepare($query);

		if (!$sth->execute($input->{CompanyName},$input->{Comment},$input->{WelcomingText}, $input->{DeviceLimit}, $input->{id}))
		{
			$error="Не могу обновить значения полей<BR>";
		}
	
		
		else 
		{
			
 			print<<END
<h3>Новые значения:</h3>
<table border=0>
<tr><td>Название компании:</td>
<td>$input->{CompanyName}</td></tr>
<tr><td>Пояснительный текст:</td>
<td>$input->{WelcomingText}</td></tr>
<tr><td>Число устройств:</td>
<td>$input->{'DeviceLimit'}</td></tr>
<tr><td>Комментарий:</td>
<td>$input->{Comment}</td></tr>
</table>
<br>
END
;
		}
	
		$dbh->{RaiseError} = 1;
 		$dbh->{PrintError} = 0;
					
	}	
	
	if ($error)
	{	

=pod

		print <<ENDAREA
<table>
<tr valign="top"><td>Произошли ошибки:</td><td><b>$error</b></td></tr>
</table>
<Form Action="address.pl" Method=Post name=myform>
ENDAREA
;

		&Print_edit_values($dbh, $input->{name},$input->{email}, $input->{cityphone}, $input->{localphone}, $input->{post}, $input->{departid}, $input->{remark},$input->{directnum},$input->{room}); 

		print <<END
&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="submit" VALUE="Изменить!">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="button" VALUE="Адреса и телефоны" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
<INPUT TYPE="hidden" NAME="id" VALUE="$input->{'id'}">
<input type=hidden name="action" value="update" >
<INPUT TYPE="hidden" NAME="depart_old_id" VALUE="$input->{'depart_old_id'}">
</FORM></body>
</html>
END
;
=cut
 	}
	else 
	{
		print <<END
<A HREF="licence.pl?action=edit_form">Изменить еще</A>&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>
</body>
</html>
END
;
	}
}



sub Del_form
{
	my ($dbh)=@_;
	
	&Print_html_header("Удаление лицензий");	
		
	print <<END

<Form Action="licence.pl" Method=Post name=myform>

<table cellspacing=0 border=0 bgcolor=#CCCCCC>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Комментарий</td><td>&nbsp;</td></tr>
END
;	
	my $sth = $dbh->prepare( qq|SELECT id, CompanyName, LicNUM, Comment  FROM License order by CompanyName ASC |);
	$sth->execute();

	
#проходим сквозь БД, печатаем заголовки пунктов
while (my $ref = $sth->fetchrow_arrayref) 
{	
			
	print qq|<tr><td bgcolor=#DDDDDD><font color="purple">$ref->[1]&nbsp;&nbsp;</font></td><TD bgcolor=#DDDDDD>$ref->[2] &nbsp;&nbsp;</td><TD bgcolor=#DDDDDD>$ref->[3] &nbsp;&nbsp;</td><td valign=left width=10><INPUT TYPE="checkbox" NAME="id" VALUE="$ref->[0]"></td></tr>|;
}

	
print <<END
<tr><td colspan=4 >
<br>
<input type=hidden name="action" value="delete">
<INPUT TYPE="submit" VALUE="Удалить">&nbsp;&nbsp;&nbsp;&nbsp;

<INPUT TYPE="button" VALUE="Управление лицензиями" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="reset" VALUE="Очистить">
</td></tr>
</table>

</FORM>
</body>
</html>
END
;
}






sub Delete
{
	my ($dbh)=@_;
		
	my @id=param('id');
	
		
	unless (@id) { &Print_menu; return;}
	
	@id=map {$_=$dbh->quote($_)} @id;
		
	my $idlist = join(',',@id);

	&Print_html_header('Данная информация была удалена');
	
		
	
	my $sth = $dbh->prepare(  qq{SELECT id, CompanyName, LicNUM, Comment  FROM License where id IN($idlist)} );
	$sth->execute;
			
	print <<END
<table cellspacing=0 cellpadding=5 border=1 bgcolor=#C0C0C0>
<tr align=center><td>Компания</td><td>Номер лицензии</td><td >Комментарий</td></tr></tr>
END
;		
	while (my $ref = $sth->fetchrow_arrayref) 
	{
		print qq|<tr><td>$ref->[1]&nbsp;&nbsp;</td><TD>$ref->[2] &nbsp;&nbsp;</td><TD >$ref->[3] &nbsp;&nbsp;</td></tr>|;
	}		
	
	print "</table>";

			
	$sth = $dbh->prepare(  qq{DELETE FROM License where id IN($idlist)});
	$sth->execute;
			
	
	print <<END
<br>

<A HREF="licence.pl?action=del_form">Удалить еще</A>&nbsp;&nbsp;&nbsp;&nbsp;
<A HREF="licence.pl?action=print_menu">Управление лицензиями</A>

</body>
</html>
END
;
}



sub Licence_Status
{
	my ($status)=@_;
	
	if ($status==-1) {return "заблокирована";}
	elsif ($status==0){ return "не активирована" }
	elsif ($status==1) {return "активирована"}
}

#Печатает заголовок HTML странички
sub Print_html_header
{
my ($header)=@_;
print <<END
<HTML>
<HEAD>
<TITLE>Управление лицензиями</TITLE>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
<script src='calendar.js' type='text/javascript'></script>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="#C0c0c0" TEXT="#000000" LINK="#0000ff" VLINK="#800080" ALINK="#ff0000">
<H2>$header</H2>
END
;	
}