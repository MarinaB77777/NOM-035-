# Integración Health Model + NOM-035

## Alcance implementado

- Catálogo fuente conservado: 195 preguntas únicas en el repositorio Health Model.
- Protocolo conectado en esta aplicación: `RESOURCE_ASSESSMENT`, versión 1, con 70 preguntas registradas.
- Idioma predeterminado: español de México (`es-MX`). Segundo idioma: inglés de Estados Unidos (`en-US`).
- El cálculo oficial de NOM-035 permanece separado e intacto.
- Health Model calcula seis bloques de recursos y contrasta cada conclusión con marcadores del mismo ámbito.
- Los datos de HRV y frecuencia cardiaca requieren una línea base de la misma persona; sin línea base no se declara concordancia ni discrepancia del sensor.
- `Unknown` se almacena como estado independiente y nunca como cero.
- Los marcadores críticos activan recursos de apoyo para la persona, pero sus respuestas no aparecen en resultados públicos ni agregados para el empleador.
- La IA recibe únicamente resultados derivados. No recibe respuestas originales ni marcadores críticos.

## Orden seguro de activación

1. Ejecutar `supabase/health_resources_module_v1.sql` en Supabase.
2. Ejecutar `supabase/measurement_observatory_v1.sql` en Supabase. Esta migración añade el historial de mediciones, las sesiones de consentimiento para sensores, las geocercas, los agregados protegidos, los enlaces de observación y las dos aleatorizaciones independientes. Si el módulo Health Model ya está instalado, no es necesario volver a ejecutar el paso 1.
3. Marcar la cuenta autorizada para editar consentimientos, configurar geocercas y ejecutar los protocolos:

   ```sql
   update public.profiles
   set can_manage_research = true
   where id = '<UUID de la cuenta Supabase autorizada>';
   ```

4. Abrir `admin.html`, configurar una geocerca laboral privada por departamento y revisar las versiones activas de consentimiento en `consent_editor.html`.
5. Registrar el estrato de muestreo de las personas elegibles desde `dashboard.html`; después crear por separado la muestra oficial NOM-035 y la ventana aleatoria de sensores desde `admin.html`.
6. Configurar en Vercel la variable protegida `GEMINI_API_KEY`.
7. Opcionalmente configurar `GEMINI_MODEL`; si no se define, el endpoint utiliza `gemini-3.1-flash-lite`.
8. Publicar el código y verificar una sesión completa en preview antes de promoverla a producción.

## Contratos de privacidad

- Cada sesión crea un nuevo consentimiento con título, texto, versión, marca temporal y hash SHA-256.
- Editar el consentimiento crea una versión nueva; nunca modifica sesiones ya aceptadas.
- No existen políticas de eliminación para sesiones, respuestas o resultados.
- Una persona puede reanudar sus respuestas solamente mientras la sesión está en curso. Después de completar la sesión, puede ver el resultado seguro, no sus respuestas originales.
- Las cuentas administrativas no reciben acceso a respuestas críticas individuales.
- Los agregados de investigación aplican supresión de celdas pequeñas con un mínimo configurable que nunca puede ser menor que cinco.
- El observador del taller recibe únicamente un enlace temporal con el estado agregado del departamento; no necesita una cuenta y no puede consultar personas.
- La geolocalización se solicita una sola vez por verificación laboral. El servidor conserva sólo un comprobante de pertenencia a la zona y descarta latitud, longitud y rutas de la persona.
- Los agregados se actualizan al ingresar una medición válida, no por presencia en línea. Cada persona aporta sólo su medición válida más reciente por indicador dentro de la ventana de 30 días.
- La severidad exacta queda en la historia interna; la vista protegida usa precisión de cuatro decimales para que el color responda a cada contribución sin mostrar mediciones individuales.

## Comparación por bloques

| Bloque Health Model | Recursos | Marcadores del mismo ámbito | Sensores/contexto | Dominios NOM-035 relacionados |
|---|---|---|---|---|
| Físico | T1–T4 | K3, K6, K7 | K1, K2, K4, K5, RE1–RE2, V2–V4 | Sin contraparte directa; relación con carga se estudia en la muestra |
| Psicológico | M1–M4 | K8–K13 | V1, V2, PEP1 | Carga, control, jornada, trabajo-familia, violencia |
| Metas | G1–G3, G12 | K14–K15 | MG1–MG7 | Control, reconocimiento, pertenencia/inestabilidad |
| Social | C1–C3 | K16–K18 | SR1–SR4 | Liderazgo, relaciones, violencia |
| Financiero | F1–F4 | K19–K20 | — | Sin contraparte directa |
| Valores e integridad | P1–P3 | K21–K22 | — | Reconocimiento y pertenencia como relaciones indirectas |

La regla `same_construct_level_bands_v1` compara conclusiones por bandas dentro del mismo ámbito. No compara preguntas, formulaciones ni escalas de forma directa. Una distancia de dos o más bandas se registra como señal de discrepancia para revisión humana y validación posterior; no determina causalidad ni diagnóstico.
