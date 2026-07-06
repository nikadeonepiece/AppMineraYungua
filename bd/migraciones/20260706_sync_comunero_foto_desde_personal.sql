-- Copia personal.foto -> comunero.foto cuando comparten el mismo DNI
UPDATE comunero c
INNER JOIN personal p ON p.dni = c.dni AND p.estado_registro = 'ACTIVO'
SET c.foto = p.foto
WHERE c.estado_registro = 'ACTIVO'
  AND p.foto IS NOT NULL
  AND TRIM(p.foto) <> '';
