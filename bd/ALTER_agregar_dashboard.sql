-- Ejecutar esto en tu base ya creada para habilitar el permiso del Dashboard
-- (ya quedó incluido en BD_APP_MINERA_YUNGUA_COMPLETA.sql para instalaciones nuevas)

INSERT INTO `sis_modulo` (`id_modulo`, `nombre`, `etiqueta`) VALUES
(5, 'DASHBOARD', 'Dashboard');

INSERT INTO `sis_accion` (`id_accion`, `id_modulo`, `codigo_accion`, `descripcion`, `tipo_operacion`) VALUES
(19, 5, 'ver_dashboard', 'Ver el dashboard con resumen de datos', 'READ');

INSERT INTO `sis_permiso` (`id_rol`, `id_accion`) VALUES
(1, 19);
