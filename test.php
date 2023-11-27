<?
header("Content-Type:text/html;charset=utf-8");
header("Access-Control-Allow-Origin: *");
require_once ("./Connect.php");
error_reporting(0); // This line will suppress any error messages
$username=$_REQUEST["username"]; //用户名
$ddzt=$_REQUEST["BillState"]; //用户名
if ($ddzt > 3) {
  // Print the value of $ddzt
  $sql_all= "SELECT * FROM `PURORDERBILL` WHERE `BuildManName`= '" .$username . "'";
  $results = $user->query($sql_all);
	$rows = mysqli_fetch_all($results, MYSQLI_ASSOC);
	$num = mysqli_num_rows($results);
	$jarr = array();
	if ($num > 0) {
		$jarr["succeed"] = "1";
		$jarr["data"] = $rows;
		echo json_encode($jarr);
	}
} else if ($ddzt <=3) {
  // Print the value of $ddzt
  $sql_all= "SELECT * FROM `PURORDERBILL` WHERE `BuildManName`= '" .$username . "' and `BillState`='".$ddzt."'";
  $results = $user->query($sql_all);
	$rows = mysqli_fetch_all($results, MYSQLI_ASSOC);
	$num = mysqli_num_rows($results);
	$jarr = array();
	if ($num > 0) {
		$jarr["succeed"] = "1";
		$jarr["data"] = $rows;
		echo json_encode($jarr);
	}
}
