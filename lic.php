<?PHP

 $act=[
	"print_menu"=>"Print_menu",
	"add_form"=>"Add_form",	
	"add"=>"Add",	
	"delete"=>"Delete",	
	"view"=>"View"
	];


$action=$_GET['action'];



if (!isset($action)) {$action='print_menu';}

print $action;

if ((!isset($action))||(!array_key_exists($action,$act)))
{
	print "�������� ��� �������!";
	exit(0);
}
else
{

$host='localhost';
$config{'dbname'}='PULTUS'; #��� ���� ������
$config{'user'}='web';		# ��� ������������ ��� ���������� � MySQL
$config{'pass'}='la34trdfg'; #������ ������������ ��� ���������� � MySQL

$link = mysqli_connect($host, $config{'user'}, $config{'pass'}, $config{'dbname'}) 
    or die("error " . mysqli_error($link));
	
	if ($action  =='add_form'){ Add_form(); }
		if ($action  =='add'){ Add(); }
	
	mysqli_close($link);
}



function Add_form()
{

	print <<<END
<HTML>
<HEAD>
<TITLE>���������� ����������</TITLE>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="#C0c0c0" TEXT="#000000" LINK="#0000ff" VLINK="#800080" ALINK="#ff0000">
<Form Action="lic.php" Method=Post name=myform>
<table border=0>
<tr><td valign="middle">
<table border=0>
<tr><td>�������� ��������:</td>
<td><INPUT TYPE="text" NAME="CompanyName" SIZE="35" MAXLENGTH="60"></td></tr>
<tr><td>������������� �����:</td>
<td><INPUT TYPE="text" NAME="WelcomingText" SIZE="35" MAXLENGTH="255"></td></tr>
<tr><td>����� ���������:</td>
<td><INPUT TYPE="text" NAME="DeviceLimit" SIZE="5" MAXLENGTH="5"></td></tr>
<tr><td>�����������:</td>
<td><INPUT TYPE="text" NAME="Comment" SIZE="35" MAXLENGTH="255"></td></tr>
</table>
</td><td>&nbsp;&nbsp;</td><td valign="middle">
</table>

&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="submit" VALUE="��������!">
&nbsp;&nbsp;&nbsp;&nbsp;
<INPUT TYPE="button"  VALUE="���������� ����������" onClick="JavaScript:document.myform.action.value='print_menu';submit()">
<input type=hidden name="action" value="add" >
</FORM>
</BODY>
</HTML>
END
;
}

