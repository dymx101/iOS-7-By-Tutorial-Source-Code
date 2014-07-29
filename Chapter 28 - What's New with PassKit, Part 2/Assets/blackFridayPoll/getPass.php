<?php
// http://www.yourdomain.com/getPass.php?answer=Great&source=rideExit
// http://www.yourdomain.com/getPass.php?answer=SoSo&source=rideExit
//get the input params
$pollAnswer = $_GET['answer'];
$source     = $_GET['source'];
$answerTime = date('Y-m-d H:i:s');

if ($pollAnswer!="Great" && $pollAnswer!="SoSo") exit();

//add the answer to the results
$file = fopen("results.csv","a+");
fwrite($file, $_GET['source'].",".$_GET['answer'].",".$answerTime."\r\n");
fclose($file);

//serve the pass to the user
//here you could server also different passes
//based on the answer to the poll
$fileName = "cottoncandy2for1_".$pollAnswer.".pkpass";
header("Content-Type: application/vnd.apple.pkpass");
header("Content-Disposition: attachment; ".
       "filename=".$fileName);
header("Content-Transfer-Encoding: binary");
header("Content-Length: ". filesize($fileName));
readfile($fileName);
