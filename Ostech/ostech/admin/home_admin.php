<?php
session_start();

if(!isset($_SESSION['usuario'])){
echo'
<script>
alert("por favor debes iniciar sesion");
window.location = "login.html";
</script>';
//header("location: login.html");
session_destroy();
die();
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>holaaaaaaaaaaaaaaaa</h1>
</body>
</html>