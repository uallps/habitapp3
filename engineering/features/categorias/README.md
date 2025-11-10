# 📂 Documentación de la funcionalidad Categorías

## 🎯 Propósito
La funcionalidad **Categorías** permite a los usuarios organizar y clasificar hábitos dentro de la aplicación. Este documento proporciona una visión técnica, consideraciones de diseño e información de implementación relevante.

## 📝 Tabla de Contenidos
1️⃣ [Tipos de categorías](#tipos-de-categorías)

## Tipos de categorías

### 1️⃣ Hábitos Definidos por el Usuario
Se espera que el propio usuario pueda crear sus categorías. Esto tiene poca relevancia si la aplicación se mantiene como un seguimiento offline, pero puede complicarse si las categorías se comparten entre usuarios (por ejemplo, en un sistema de competición o compartición de hábitos).

#### 📜 Nombre
Cada hábito se categoriza por un nombre, que puede tener subcategorías.  

Ejemplo de hábitos relacionados con **Mecánica**:  
- 🧽 Limpiar tapicería del coche  
- 🧹 Limpiar cristales  
- 🔧 Comprobar pastillas de freno  
- 🛠 Lubricar puertas  
- 🚗 Aparcar con las ruedas rectas  
- 🅿️ Aparcar con marcha engranada después de freno de mano  

Subcategorías dentro de "Mecánica":  
- **Limpieza** 🧽✨  
  - `Mecánica -> Limpieza` (limpieza de tapicería y cristales)  
- **Mantenimiento** 🔧  
  - `Mecánica -> Mantenimiento` (comprobar pastillas de freno)  
- **Acciones preventivas** ⚠️  
  - `Mecánica -> Acciones Preventivas` (aparcar con ruedas rectas, marcha engranada)  

⚡ El usuario puede crear jerarquías tan profundas como quiera, generando categorías muy específicas 🔍📊.

#### 🪧 Icono
Los iconos complementan el nombre y la jerarquía de la categoría.  
- Pueden representar visualmente la categoría sin necesidad de texto.  
- Se recomienda usar secuencias de 2 o 3 iconos para diferenciar categorías complejas.  
- Aunque ilimitados, demasiados iconos pueden dificultar la comprensión.

#### 🚦 Prioridad
Los hábitos pueden tener distintas prioridades:  
- 🔴 Alta prioridad  
- 🟠 Media prioridad  
- 🟢 Baja prioridad  

Ejemplos:  
- 🟠 Lavarse y lubricar la barba  
- 🟠 Lavarse el pelo  
- 🔴 Ducharse con jabón  
- 🔴 Lavarse los dientes  
- 🟢 Peinarse la barba  

#### 🗓️ Frecuencia
Definición de periodicidad del hábito:  
- 🔁🌞 **Diario:** Todos los días  
- 🌞📅🌙 **Semanal:** Uno o varios días por semana  
- 📅 **Mensual:** Uno o varios días por mes  
- 🌱🌳 **Anual:** Uno o varios días por año o años  

Ejemplos:  
- 🔁🌞 Lavarse los dientes  
- 🌞📅🌙 Lavarse la barba (miércoles y domingos)  
- 🌞📅🌙 Lavarse el pelo (miércoles y domingos)  
- 📅 Comprobar presión de las ruedas (una vez al mes)  
- 🌱🌳 ITV (una vez cada agosto)  
- 🌱🌳 Visitar Alicante (cada 2 años)

#### 📈 Progreso
Estado del hábito:  
- ✅ Completado  
- 🔄 En progreso  
- ❌ No realizado  

Ejemplos relacionados con frecuencia:  
- 🔄 🌱🌳 Renovar DNI (cada 5 años): aún no completado, pero en curso  
- ❌ 🌞📅🌙 Lavarse el pelo: olvidado por el usuario

### 2️⃣ Hábitos No Definidos por el Usuario
La aplicación ofrece categorías limitadas predefinidas.  
- Facilita la función online de competición de hábitos.  
- Limitado en opciones, puede resultar restrictivo para el usuario.

