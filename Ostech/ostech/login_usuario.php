<?php
session_start();
include 'conexion_be.php';

$mail = $_POST['mail'];
$contraseña = $_POST['contraseña'];

// Realizamos la consulta para verificar el usuario y contraseña
$consulta = "SELECT * FROM usuarios WHERE mail='$mail' AND contraseña='$contraseña'";
$resultado = mysqli_query($conexion, $consulta);

// Verificamos si encontramos alguna fila que coincida
$filas = mysqli_fetch_array($resultado);

if ($filas) {
    // Guardamos la sesión del usuario
    $_SESSION['mail'] = $mail;
    
    // Verificamos el rol del usuario
    if ($filas['id_rol'] == 1) { // Si el rol es ADMIN
        header("location: admin/home_admin.php");
        exit;
    } elseif ($filas['id_rol'] == 2) { // Si el rol es CLIENTE
        header("location: usuarios/home_usuarios.php");
        exit;
    } else {
        // Si el rol no es reconocido
        echo '
        <script>
        alert("Rol de usuario no reconocido.");
        window.location = "Login.html";
        </script>
        ';
        exit;
    }
} else {
    // Si las credenciales no son correctas
    echo '
    <script>
    alert("Usuario o contraseña incorrectos. Verifique los datos.");
    window.location = "Login.html";
    </script>
    ';
    exit;
}

// Liberamos los recursos y cerramos la conexión
mysqli_free_result($resultado);
mysqli_close($conexion);
?>
