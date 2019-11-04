package Licence;

use strict;
use vars qw(%config @month);
use CGI qw(:standard);
use DBI;
use Exporter;
@Licence::ISA = qw(Exporter);
@Licence::EXPORT = qw(%config @month);


$config{'plpath'}='/cgi-bin/local/address';
$config{'htmlpath'}='/local/address';
$config{'rootpath'}='http://www.tcen.ru';
$config{'syspath'}='/home/wwwadm/www';

#переменные дл€ работы с MySQL

$config{'dbname'}='PULTUS'; #им€ базы данных
$config{'driver'}='mysql';  #драйвер дл€ Ѕƒ
$config{'user'}='web';		# им€ пользовател€ при соединении с MySQL
$config{'pass'}='la34trdfg'; #пароль пользовател€ при соединении с MySQL

#ќбщие переменные
	
@month=('€нвар€','феврал€','марта','апрел€','ма€','июн€',
    'июл€','августа','сент€бр€','окт€бр€','но€бр€','декабр€');


sub Connect
{
	my $dsn = "DBI:$config{'driver'}:database=$config{'dbname'};";
	my $dbh = DBI->connect($dsn, $config{'user'}, $config{'pass'},
		{
      		PrintError => 0,   ### Do not report errors via warn(  )
      		RaiseError => 1,    ### Do report errors via die(  )
      		AutoCommit => 1   #поддержка транзакций нам не нужна
  	});
	return $dbh;
}

sub Convert_date_to_MySQL
{
	my ($date)=@_;
	if ($date!~/\d\d\W\d\d\W\d\d\d\d/)
	{ print "ќшибка: неверно введена дата"; exit 0; }
	
	my ($day,$mon,$year)=($date=~/(..).(..).(....)/);
	
	$date=$year.'-'.$mon.'-'.$day;
	return $date;
}

sub Convert_date_to_HTML
{
	my ($date)=@_;
	
	my ($year,$mon,$day)=($date=~/(....).(..).(..)/);
	
	$date=$day.'.'.$mon.'.'.$year;
	return $date;
}



1;