-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-04-2025 a las 19:24:26
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ostech`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `HistorialCompra` (IN `p_id_cliente` INT)   begin 
select v.id as ventaId, v.fecha, v.hora, p.nombre as producto, v.precio_producto
from ventas v
join productos p on v.id_producto=p.id
where v.id_cliente=p_id_cliente
order by v.fecha desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObtenerProductosRecientes` (IN `limite` INT)   BEGIN
    SELECT id, nombre, precio, fecha_alta
    FROM productos
    ORDER BY fecha_alta DESC
    LIMIT limite;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerTodosAsesoramientos` ()   BEGIN
 SELECT * FROM asesoramiento;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerTodosProductos` ()   BEGIN
 SELECT * FROM productos;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerTodosTicket` ()   BEGIN
 SELECT * FROM ticketreparacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerTodosUsuarios` ()   BEGIN
 SELECT * FROM usuarios;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerTodosVentas` ()   BEGIN
 SELECT * FROM ventas;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asesoramiento`
--

CREATE TABLE `asesoramiento` (
  `id` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `hora` time DEFAULT NULL,
  `precio` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventa`
--

CREATE TABLE `detalleventa` (
  `id` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `imagen` text DEFAULT NULL,
  `precio` float DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_alta` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ticketreparacion`
--

CREATE TABLE `ticketreparacion` (
  `id` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `hora` time DEFAULT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `solucion` varchar(500) DEFAULT NULL,
  `precio` float DEFAULT NULL,
  `componentes` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(20) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `mail` varchar(20) DEFAULT NULL,
  `contraseña` varchar(20) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `rol` varchar(20) DEFAULT NULL,
  `fecha` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `NoBorrarSiHayVentas` BEFORE DELETE ON `usuarios` FOR EACH ROW BEGIN
 if exists(SELECT 1 from ventas where id_cliente=old.id) THEN
 SIGNAL SQLSTATE '45000'
 set MESSAGE_TEXT= 'no se puede eliminar este usuario, tiene compras registradas';
 end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `NoRepetirMail` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN
    IF (SELECT COUNT(*) FROM usuarios WHERE mail = NEW.mail) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email ya está registrado.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `hora` time DEFAULT NULL,
  `id_producto` int(11) NOT NULL,
  `precio_producto` decimal(10,2) DEFAULT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `ventas`
--
DELIMITER $$
CREATE TRIGGER `ActualizarStockDespuesDeVenta` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
    IF (SELECT stock FROM productos WHERE id = NEW.id_producto) >= NEW.cantidad THEN
        UPDATE productos 
        SET stock = stock - NEW.cantidad
        WHERE id = NEW.id_producto;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para la venta';
    END IF;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asesoramiento`
--
ALTER TABLE `asesoramiento`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- Indices de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ticketreparacion`
--
ALTER TABLE `ticketreparacion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asesoramiento`
--
ALTER TABLE `asesoramiento`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ticketreparacion`
--
ALTER TABLE `ticketreparacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asesoramiento`
--
ALTER TABLE `asesoramiento`
  ADD CONSTRAINT `asesoramiento_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `detalleventa_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `detalleventa_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
