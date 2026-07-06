-- Permisos: Certificado de Posesión y Fotocheck (módulo COMUNEROS)
-- Ejecutar una vez en BD existente: app_minera_yungua

INSERT INTO `sis_accion` (`id_accion`, `id_modulo`, `codigo_accion`, `descripcion`, `tipo_operacion`)
SELECT * FROM (
  SELECT 20 AS id_accion, 3 AS id_modulo, 'ver_certificado_posesion' AS codigo_accion, 'Ver certificados de posesión' AS descripcion, 'READ' AS tipo_operacion
  UNION ALL SELECT 21, 3, 'crear_certificado_posesion', 'Registrar certificado de posesión', 'CREATE'
  UNION ALL SELECT 22, 3, 'editar_certificado_posesion', 'Editar certificado de posesión', 'UPDATE'
  UNION ALL SELECT 23, 3, 'eliminar_certificado_posesion', 'Eliminar certificado de posesión', 'DELETE'
  UNION ALL SELECT 24, 3, 'exportar_certificado_posesion', 'Generar PDF de certificado de posesión', 'SPECIAL'
  UNION ALL SELECT 25, 3, 'ver_fotocheck', 'Ver módulo de generación de fotocheck', 'READ'
  UNION ALL SELECT 26, 3, 'generar_fotocheck', 'Generar PDF de fotocheck', 'SPECIAL'
) AS nuevas
WHERE NOT EXISTS (
  SELECT 1 FROM `sis_accion` a WHERE a.id_modulo = nuevas.id_modulo AND a.codigo_accion = nuevas.codigo_accion
);

INSERT IGNORE INTO `sis_permiso` (`id_rol`, `id_accion`)
SELECT 1, id_accion FROM `sis_accion` WHERE codigo_accion IN (
  'ver_certificado_posesion', 'crear_certificado_posesion', 'editar_certificado_posesion',
  'eliminar_certificado_posesion', 'exportar_certificado_posesion', 'ver_fotocheck', 'generar_fotocheck'
);

INSERT IGNORE INTO `sis_permiso` (`id_rol`, `id_accion`)
SELECT p.id_rol, na.id_accion
FROM `sis_permiso` p
INNER JOIN `sis_accion` o ON p.id_accion = o.id_accion AND o.codigo_accion = 'ver_comunero'
INNER JOIN `sis_accion` na ON na.codigo_accion IN (
  'ver_certificado_posesion', 'ver_fotocheck', 'exportar_certificado_posesion', 'generar_fotocheck'
);

INSERT IGNORE INTO `sis_permiso` (`id_rol`, `id_accion`)
SELECT p.id_rol, na.id_accion
FROM `sis_permiso` p
INNER JOIN `sis_accion` o ON p.id_accion = o.id_accion AND o.codigo_accion = 'crear_comunero'
INNER JOIN `sis_accion` na ON na.codigo_accion = 'crear_certificado_posesion';

INSERT IGNORE INTO `sis_permiso` (`id_rol`, `id_accion`)
SELECT p.id_rol, na.id_accion
FROM `sis_permiso` p
INNER JOIN `sis_accion` o ON p.id_accion = o.id_accion AND o.codigo_accion = 'editar_comunero'
INNER JOIN `sis_accion` na ON na.codigo_accion = 'editar_certificado_posesion';

INSERT IGNORE INTO `sis_permiso` (`id_rol`, `id_accion`)
SELECT p.id_rol, na.id_accion
FROM `sis_permiso` p
INNER JOIN `sis_accion` o ON p.id_accion = o.id_accion AND o.codigo_accion = 'eliminar_comunero'
INNER JOIN `sis_accion` na ON na.codigo_accion = 'eliminar_certificado_posesion';
