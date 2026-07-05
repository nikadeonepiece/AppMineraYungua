# Preguntas para la próxima reunión — Módulo Comuneros

Checklist de todo lo que quedó pendiente al analizar `comuneros.xlsx`, los CSV de
RENIEC (`bd/adjuntos/`) y `CERTIFICADO DE POSESION.pdf`. Nada de esto bloquea lo
que ya está cargado en `BD_APP_MINERA_YUNGUA_COMPLETA.sql`; son datos que faltan
para completarlo.

---

## 1. Estructura: Comunidad Campesina

- [ ] Confirmé que **Chuyugual, Corral Grande, Cushuro, La Unión y Pampa Verde**
      pertenecen todos a la misma **Comunidad Campesina Chuyugual**. ¿Es correcto?
- [ ] ¿A qué Comunidad Campesina pertenecen los otros 6 caseríos del padrón:
      **Peña Colorada, San Miguel, Los Loros, Las Totoras, La Pampa (sector de
      Peña Colorada) y El Quinual**? ¿O todavía no están incorporados
      formalmente a ninguna comunidad?
- [ ] Si pertenecen a una comunidad ya constituida, pedir sus datos de registro:
      nombre completo, distrito/provincia/departamento, N° de partida registral,
      oficina registral (como en el certificado de Chuyugual: Partida 03002622,
      Registros Públicos de Huamachuco).
- [ ] ¿El nombre "Yungua" (del proyecto/app) corresponde a alguna Comunidad
      Campesina específica, o es solo el nombre del proyecto minero?

## 2. DNIs sin validar por RENIEC (15 casos)

El DNI está en la posición correcta del padrón pero RENIEC no devolvió nombre
(posible DNI antiguo de 7 dígitos, cancelado, o persona fallecida). Se guardó el
nombre del Excel original, marcado como no validado.

| Caserío | DNI | Nombre (Excel original) |
|---|---|---|
| CAS. LA UNIÓN | 7472227 | GIL AGUILAR ANA LILI |
| CAS. PEÑA COLORADA | 19773418 | BOBADILLA LAVADO ISIDRO CARLOS |
| CAS. PAMPA VERDE | 9026184 | DAVILA VELA SANTOS |
| CAS. PAMPA VERDE | 7866276 | PAREDES SANCHO FERNANDO |
| CAS. CUSHURO | 6435325 | GARCIA ROMAN MAURA CATALINA |
| CAS. CUSHURO | 63399546 | VERA OLOYA GOSMAR ROGER |
| CAS. CUSHURO | 7328491 | VILLANUEVA CARRION FORTUNATA |
| CAS. CORRAL GRANDE | 8373414 | ARANDA KAZORLA FRANCISCO |
| CAS. CORRAL GRANDE | 63045008 | VILLANUEVA ARANDA BATNER |
| CAS. CORRAL GRANDE | 8842580 | ZAVALETA ARAUJO ISABEL MARISOL |
| CAS. CHUYUGUAL | 19550794 | CASTILLO PAREDES TEODORO |
| CAS. CHUYUGUAL | 80714970 | INFANTES SANCHO SANTOS BENITA |
| CAS. CHUYUGUAL | 19583000 | MEDRANO AVILA ISAC SACARIAS |
| CAS. CHUYUGUAL | 61231844 | PEREZ POLO YOVER |
| CAS. LAS TOTORAS | 19724273 | MUNCIBAY VILLANUEVA OLINDA TEOFILA |

- [ ] Revisar cada DNI con la persona/dirigencia: ¿está bien escrito? ¿le falta
      un 0 adelante (DNI antiguo de 7 dígitos)? ¿sigue vigente?

## 3. Persona sin DNI real en el origen (1 caso)

- [ ] **VILLANUEVA CORNELIO RAUL** — CAS. PEÑA COLORADA, N° de padrón 139.
      En el Excel original su DNI era el carácter `.` (nunca se cargó un DNI
      real). Está en la base con `dni = NULL`. **¿Cuál es su DNI?**

## 4. El "registro de asistencia" (columna FIRMA)

- [ ] ¿A qué asamblea/reunión corresponde este registro de asistencia?
      ¿Qué fecha y qué motivo tuvo (o tendrá)? Hoy quedó cargada una asamblea
      por caserío sin fecha ni motivo (`asamblea.fecha` y `asamblea.titulo`
      en NULL) — falta ese dato para completarla.
- [ ] ¿Es una asamblea puntual (una sola vez) o van a repetirse periódicamente
      (para diseñar si necesitamos más de una asamblea por caserío en el tiempo)?

## 5. Certificado de Posesión (parcelas)

El PDF `CERTIFICADO DE POSESION.pdf` (plantilla de Chuyugual) muestra que el
sistema podría necesitar más adelante:
- Parcela: nombre/denominación, hectáreas, caserío, sector, colindantes
  (este/oeste/norte/sur)
- Certificado emitido: comunero, parcela, fecha

- [ ] ¿Van a digitalizar/emitir certificados de posesión desde este sistema?
      Si sí, ¿tienen ya un listado de parcelas por comunero, o se carga desde cero?
- [ ] ¿Aplica el mismo formato de certificado (colindantes en 4 puntos
      cardinales) para todos los caseríos, o cada Comunidad Campesina tiene su
      propio formato?

## 6. Ya resuelto (solo para informar, no preguntar)

- El DNI `71866164` (CAS. CORRAL GRANDE) tenía dos nombres distintos en el
  Excel original ("CAIPO CRESPIN MILSER" y "PAREDES CORNELIO ADELMIRA").
  RENIEC confirmó que es **CAIPO CRESPIN MILSER**; el otro nombre se descartó.
- "LA PAMPA" quedó modelada como sector subordinado a "CAS. PEÑA COLORADA"
  (el propio título de esa hoja lo confirma), no como caserío independiente.

---

### Resumen de lo ya cargado en la base (no requiere confirmación)

- 11 caseríos (`caserio`), con La Pampa subordinada a Peña Colorada
- 2,661 comuneros únicos por DNI (`comunero`)
- 2,740 pertenencias comunero-caserío (`comunero_caserio`)
- 11 asambleas (`asamblea`) y 2,740 registros de asistencia (`asistencia_asamblea`)
