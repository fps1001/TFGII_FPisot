## Referencias Importantes

### Artículos sobre la masificación turística

- **Artículo de El País:**
  [En el corazón del turismo masivo de Barcelona](https://elpais.com/espana/catalunya/2024-08-20/en-el-corazon-del-turismo-masivo-de-barcelona-que-el-park-guell-este-lleno-demuestra-que-hay-que-verlo.html)
  - *Fecha*: 20/08/2024
  - **Resumen**: Habla de la masificación turística y cómo los visitantes aplauden la idea de una app que les avise de la afluencia.

- **Noticia de la BBC:**
  [BBC sobre el mismo problema](https://www.bbc.com/news/articles/clyn5l20z72o)
  - *Fecha*: 02/09/2024

---

## Reunión 17/09

**Participante**: @clopezno, @fps1001


### 1. Documentación
- Revisión de memoria.
- Trabajar en la parte que se explique.
- Se podía crear un hito que sea fin de la memoria (sin anexos).

### 2. Prototipos y LLM
- Se pueden terminar los prototipos de cuaderno jupyter y langflow con agentes. **(hito a final de mes)**
### 3. Desarrollo de la Aplicación
Una vez conectado los servicios y gestores de estado desde la petición LLM hasta la optimización (funcionamiento core de la aplicación), se pretende disponer la aplicación de la manera más profesional posible añadiendo las funcionalidades de UI que faltan como la pantalla de carga de petición a LLM.

- **Tareas**:
  - **TODO**: Adaptación a iOS no dispongo de medios para probarlo. **Buscar solución.**
  - **TODO**: Pantalla de carga de petición: bici/andando, n_poi, ciudad, distancia? tiempo?, gustos?
  - **TODO**: Añadir un theme común para el contexto.
  - **TODO**: Modificar InfoWindow por BottomSheet: en vez de ventana de información, se presentará como una ventana desde abajo del móvil.
  - **TODO**: Marcador básico de POI de marcador básico a imagen URL
  - *Sin crear todavía 🡻🡻*
  - **TODO**: Mejoras de diseño, UI, robustez, incluyen:
    - **TODO**: Resolver el caso de no tener internet para que la app no se quede buscando indefinidamente.
    - **TODO**: Añadir un diálogo para cuando el usuario escoge un lugar de la lista.
    - **TODO**: Decidir si usar `customPaint` para el inicio y final de ruta con duración y km de la ruta.
    <p>

### 4. Propuesta de próximo sprint:

Llegar a los hitos del próximo prototipo con la versión más profesional posible de la aplicación y generar release 1.0. <p>

Se puede justificar el uso de generative_ai de google, dado el marco de trabajo: servicios de google, uso compartido de api_key, servicios de mapas de google, se ha creado un ecosistema Google y si el LLM es suficientemente potente y genera buenas respuesta sería la mejor opción.