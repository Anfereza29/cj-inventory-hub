# Constitución — Sistema de Control de Inventario de Obra
## Constructora C&J S.A.S.

<!--
Documento fundacional del proyecto (Spec-Driven Development).
Define los principios no negociables que gobiernan toda decisión de diseño,
implementación y entrega. Cualquier spec, plan o tarea debe poder justificarse
contra estos artículos. Ante un conflicto, prevalece esta constitución.
-->

**Versión:** 1.0.0
**Fecha de ratificación:** 2026-11-01
**Última enmienda:** 2026-11-01
**Estado:** Activa

---

## Preámbulo

Constructora C&J S.A.S. es una microempresa de construcción y obras civiles
ubicada en Medellín (CIIU 4390 y 4330). Su proceso de control de materiales en
obra se lleva hoy de forma manual, con anotaciones y hojas de Excel no
integradas, lo que impide conocer existencias en tiempo real, rastrear a quién y
para qué actividad se entrega el material, y detectar a tiempo las desviaciones
de consumo frente a lo planificado.

El diagnóstico de madurez digital ubicó a la empresa en nivel **Principiante**
(46/120), con una **cultura digital** como principal fortaleza (24/40) y una
**intensidad digital** baja (22/80). El árbol de decisión de tecnologías
priorizó **Estandarización + Mejora Continua** y **BPA/BPMS**, y descartó
tecnologías avanzadas (IA, ESB) por falta de volumen y madurez.

Este proyecto construye una **solución propia a la medida** —una aplicación
móvil para obra y un tablero web para gerencia— que digitaliza el registro de
movimientos de materiales (entradas, vales digitales de salida, consulta de
stock, conciliación y reportes). SIIGO continúa siendo el sistema contable y de
facturación, sin cambios.

Esta constitución fija las reglas que todo el equipo debe respetar para que la
solución sea útil, confiable y adoptada por el personal de obra.

---

## Artículo I — Primero el proceso, luego el software

1. La solución se diseña alrededor del flujo real de almacén de C&J: solicitud
   del residente, compra, recepción contra orden de compra, despacho por vale,
   comparación de consumo y conciliación quincenal. No se impone un flujo ajeno
   a la empresa.
2. Antes de automatizar un paso, debe existir el proceso **estandarizado**:
   catálogo único de materiales (código, descripción, unidad), clasificación
   ABC y numeración de vales. No se automatiza el caos.
3. El alcance está delimitado. **Dentro:** entradas contra orden de compra,
   vales digitales de salida, consulta de existencias en tiempo real,
   conciliación y reportes de costos/desviaciones por obra. **Fuera:**
   cotización y selección de proveedores, contabilidad y facturación (SIIGO),
   diseño técnico, presupuesto y licencias. Ampliar el alcance requiere una
   enmienda o una decisión explícita registrada en la spec.

## Artículo II — Simplicidad y bajo costo (anti-sobreingeniería)

1. Se prefiere siempre la solución más simple que satisfaga el criterio de
   aceptación. La empresa es una microempresa: no se introduce complejidad,
   infraestructura ni dependencias que no estén justificadas por una necesidad
   presente y concreta.
2. Se rechazan explícitamente las tecnologías descartadas en el análisis
   (Inteligencia Artificial, ESB, integraciones empresariales pesadas) mientras
   no exista el volumen transaccional y la madurez que las justifiquen.
3. Las abstracciones, capas y configuraciones adicionales deben ganarse su
   lugar: solo se añaden cuando resuelven un problema real ya observado, no uno
   hipotético.
4. La solución debe poder construirse en semanas y mantenerse por un equipo
   pequeño. "Hecho y en uso" vale más que "perfecto y sin adoptar".

## Artículo III — La trazabilidad del inventario es sagrada

1. El saldo de cada material debe cumplir **siempre** la identidad del Kardex:
   `Saldo = Saldo Inicial + Entradas − Salidas`. Ninguna función puede dejar el
   inventario en un estado que viole esta ecuación.
2. Todo movimiento de material (entrada o salida) queda registrado con su
   trazabilidad mínima:
   - **Entradas:** número de orden de compra, proveedor, material, cantidad
     real recibida, evidencia de la remisión y observaciones de novedad.
   - **Salidas:** material, cantidad, frente de obra o actividad, operario que
     recibe y firma digital de conformidad.
3. Los movimientos son un registro histórico. No se editan ni se borran en
   silencio: las correcciones se hacen con un movimiento de ajuste trazable que
   conserva el historial.
4. Las alertas de stock son parte del contrato funcional: por debajo del Punto
   de Pedido (PP) se muestra alerta **amarilla**; por debajo del Stock de
   Seguridad (SS), alerta **roja**. Los umbrales son configurables por material.

## Artículo IV — Diseñado para la obra (usabilidad y campo)

1. La interfaz de obra debe ser **sencilla y rápida** para personal no técnico:
   mínimo de campos, selección por listas, captura de firma en pantalla y carga
   de foto de la remisión. Si una pantalla requiere entrenamiento extenso, está
   mal diseñada.
2. La solución debe comportarse de forma predecible en condiciones de obra:
   conectividad intermitente, dispositivos modestos y uso a una mano. La
   pérdida de conexión no debe provocar pérdida de un registro ya capturado.
3. El idioma de la interfaz, los mensajes y los reportes es **español**, con la
   terminología que usa el personal de C&J (vale, remisión, frente de obra,
   almacenista, residente).
4. Toda historia de usuario se valida tempranamente con mockups y con el
   personal real (ingeniero/almacenista) antes de darla por terminada.

## Artículo V — Integridad de datos y respaldo

1. Los datos del inventario son el activo central del sistema. Se almacenan de
   forma centralizada (no en archivos sueltos por persona) para que exista una
   única fuente de verdad consultable en tiempo real.
2. Se aplica una **estrategia de respaldo híbrida**: la información crítica debe
   tener copia automatizada en la nube, superando la dependencia de respaldos
   físicos locales señalada en el diagnóstico.
3. Las validaciones de datos ocurren en el momento de la captura: cantidades no
   negativas, material perteneciente al catálogo, campos obligatorios de
   trazabilidad completos. No se persisten movimientos incompletos.
4. SIIGO permanece como sistema de contabilidad y facturación. La interacción
   con SIIGO se limita a la **exportación de consumos por obra y periodo a
   Excel**; el sistema no duplica ni reemplaza funciones contables.

## Artículo VI — Especificación antes que código (SDD)

1. Todo trabajo se deriva de una historia de usuario con **criterios de
   aceptación** verificables, escritos en formato Dado/Cuando/Entonces. Si no
   hay criterio de aceptación, no se implementa.
2. El flujo de trabajo es: **requisitos → diseño → tareas → implementación**.
   El código refleja la spec; cuando la realidad obliga a cambiar el diseño, se
   actualiza la spec primero.
3. Una historia se considera **terminada** solo cuando cumple todos sus
   criterios de aceptación, fue validada con el usuario y no rompe la
   trazabilidad del inventario (Artículo III).
4. El trabajo se organiza por sprints incrementales con un entregable usable al
   final de cada uno:
   - **Sprint 0 (estandarización):** catálogo de materiales, clasificación ABC,
     numeración de vales y stock mínimo de materiales A.
   - **Sprint 1 (núcleo operativo):** entradas por orden de compra, vales
     digitales de salida y consulta de stock con alertas.
   - **Sprint 2 (control y reportes):** conteo físico y conciliación, desviación
     de consumo, informe quincenal a gerencia y exportación a Excel.

## Artículo VII — Colaboración y gobierno del backlog

1. El equipo está conformado por Juan Pablo Marín Rondón, Isabel Parra Sierra,
   Andrés Felipe Rengifo Zapata y Alejandro Santa Jaramillo. Las decisiones de
   alcance y prioridad son colegiadas.
2. El backlog es la fuente única de verdad del trabajo pendiente y se gestiona
   en el tablero del proyecto (GitHub Projects). Cada ítem tiene ID, historia,
   criterios de aceptación y sprint asignado.
3. El código vive bajo control de versiones. Los cambios se integran por ramas y
   revisión; no se trabaja directamente sobre la rama principal sin revisión.
4. Las decisiones relevantes se validan con el cliente (ingeniero residente /
   gerencia) y la evidencia de esa validación se conserva.

---

## Alineación estratégica

Esta solución sirve directamente a dos objetivos estratégicos de la empresa, que
actúan como métricas de éxito del proyecto:

- **Optimizar el control de materiales, herramientas y costos:** reducir en un
  20 % las pérdidas, desperdicios y diferencias de inventario para 2028.
- **Fortalecer la innovación y la gestión tecnológica:** implementar
  herramientas tecnológicas en al menos el 50 % de los procesos prioritarios
  para 2029.

---

## Gobernanza

1. **Supremacía.** Esta constitución prevalece sobre cualquier otra práctica,
   preferencia o decisión puntual del proyecto. Un documento de diseño o una
   tarea que la contradiga es inválido hasta que se corrija o se enmiende la
   constitución.
2. **Enmiendas.** Cualquier integrante puede proponer una enmienda. Debe
   quedar documentada (qué cambia y por qué), ser aprobada por el equipo y
   reflejarse con un incremento de versión.
3. **Versionado semántico del documento:**
   - **MAYOR:** eliminación o redefinición incompatible de un principio.
   - **MENOR:** se añade un principio o una sección sustancial nueva.
   - **PARCHE:** aclaraciones y correcciones que no cambian el significado.
4. **Cumplimiento.** Antes de dar por terminado un sprint o una historia, el
   equipo verifica que lo entregado respeta cada artículo aplicable. Toda
   excepción debe justificarse explícitamente y registrarse.

---

*Ratificada por el equipo de proyecto de Constructora C&J S.A.S. — Universidad
EAFIT, Curso Sistemas de Información, 2026.*
