# 📂 Documentación de la funcionalidad Categorías

## 🎯 Propósito
La funcionalidad **Categorías** permite a los usuarios organizar y clasificar hábitos dentro de la aplicación. Este documento proporciona una visión técnica, consideraciones de diseño e información de implementación relevante.

## 📝 Tabla de Contenidos
1️⃣ [Tipos de categorías](#tipos-de-categorías)

## Tipos de categorías

### 1️⃣ Hábitos Definidos por el Usuario
Se espera que el propio usuario pueda crear sus categorías. Esto tiene poca relevancia si la aplicación se mantiene como un seguimiento offline, pero puede complicarse si las categorías se comparten entre usuarios (por ejemplo, en un sistema de competición o compartición de hábitos).

Todas las formas para categorizar se definen a continuación. Se pueden utilizar varias maneras de categorizar simultáneamente.

#### 📜 ¿Qué es una categoría?
Cada hábito se categoriza por un nombre, que puede pertenecer a categorías distintas.  

Ejemplo de hábitos relacionados con la categoría **Mecánica**:  
- 🧽 Limpiar tapicería del coche  
- 🧹 Limpiar cristales  
- 🔧 Comprobar pastillas de freno  
- 🛠 Lubricar puertas  
- 🚗 Aparcar con las ruedas rectas  
- 🅿️ Aparcar con marcha engranada después de freno de mano  

Una categoría puede tener a su vez, subcategorías. Por ejemplo, dentro de "Mecánica":  
- **Limpieza** 🧽✨  
  - `Mecánica -> Limpieza` (limpieza de tapicería y cristales)  
- **Mantenimiento** 🔧  
  - `Mecánica -> Mantenimiento` (comprobar pastillas de freno)  
- **Acciones preventivas** ⚠️  
  - `Mecánica -> Acciones Preventivas` (aparcar con ruedas rectas, marcha engranada)  

⚡ El usuario puede crear jerarquías tan profundas como quiera, generando categorías muy específicas 🔍📊.

Una categoría tiene, simultáneamente: Nombre, icono, prioridad y frecuencia.

#### 🪧 Icono
Los iconos complementan el nombre y la jerarquía de la categoría. Permiten al usuario definir visualmente sus categorías.

Existen dos tipos de icono distintos:

- Secuencia de emojis: El usuario puede elegir entre 1 y 3 emojis que en conjunto representan gráficamente a la categoría.
- Imágenes del dispositivo: Como su nombre indica, el usuario carga una imagen de su dispositivo para representar la categoría.

#### 🚦 Prioridad
Las categorías pueden tener distintas prioridades:  
- 🔴 Alta prioridad  
- 🟠 Media prioridad  
- 🟢 Baja prioridad  

¿Qué significa que una categoría tenga prioridad?

Una categoría tiene prioridad 🔴, 🟠 o 🟢, pero puede contener hábitos de distintas prioridades.

La prioridad de una categoría permite al usuario anteponer conjuntos de hábitos frente a otros.

Ejemplos:  
- 🟠 Lavarse y lubricar la barba (Dentro de la categoría Higiene (🔴) )
- 🟠 Lavarse el pelo (Dentro de la categoría Higiene (🔴) )
- 🔴 Ducharse con jabón  (Dentro de la categoría Higiene (🔴) )
- 🔴 Lavarse los dientes  (Dentro de la categoría Higiene (🔴) )
- 🟢 Peinarse la barba  (Dentro de la categoría Higiene (🔴) )

Dentro de la Higiene, hay hábitos menos prioritarios que otros.

Pero el usuario puede considerar que la Higiene (🔴) sea más importante que Coche (🟠)

### 3️⃣ Decisión de Diseño

Los hábitos serán categorizados mediante [Hábitos Definidos por el Usuario](#1️⃣-hábitos-definidos-por-el-usuario). En caso de que la aplicación defina en algún punto un sistema de competición o compartición de hábitos, será necesario una manera de normalizar y agrupar automáticamente categorías para evitar redundancia de categorías.
