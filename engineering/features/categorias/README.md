# 📂 Documentación de la funcionalidad Categorías

## 🎯 Propósito
La funcionalidad **Categorías** permite a los usuarios organizar y clasificar hábitos dentro de la aplicación. Este documento proporciona una visión técnica, consideraciones de diseño e información de implementación relevante.

## 📝 Tabla de Contenidos
1️⃣. [Tipos de categorías](#1️⃣-tipos-de-categorías)

## 1️⃣. Tipos de categorías

### 1️⃣.1️⃣. Hábitos Definidos Por el Usuario

Se podría pretender que sea el mismo usuario quien cree las categorías. No tiene relevancia a corto plazo y si la aplicación se queda como un seguimiento de hábitos offline. Sin embargo, podría dificultarse si en algún momento se decide que las categorías pueden ser compartidas entre distintos usuarios. Este es el caso de un sistema de competición o compartición de hábitos.

#### 1️⃣.1️⃣.1️⃣. 📜 Nombre
Es intuitivo pensar que un hábito se categoriza por un nombre.

Por ejemplo, supongamos que hay un conjunto de hábitos como siguen:  
- 🧽 Limpiar tapicería coche  
- 🧹 Limpiar cristales  
- 🔧 Comprobar pastillas freno  
- 🛠 Lubricar puertas  
- 🚗 Aparcar con las ruedas rectas  
- 🅿️ Aparcar con marcha engranada después de freno de mano  

Todos estos hábitos están relacionados con la **Mecánica**.  

Sin embargo, algunos hábitos, aun estando relacionados con la mecánica, son **sub-categorías** de la mecánica.  

Por ejemplo:  
- Tanto limpiar la tapicería del coche como limpiar los cristales son **Limpieza** 🧽✨  
  - Categoría: `Mecánica -> Limpieza`  
- El resto está relacionado con el **Mantenimiento** 🔧 del vehículo o son acciones **preventivas de desgaste** ⚠️:  
  - `Mecánica -> Mantenimiento` (Comprobar pastillas freno)  
  - `Mecánica -> Acciones Preventivas` (Aparcar con las ruedas rectas 🚗, Aparcar con marcha engranada 🅿️)  

⚡ Se puede ir tan profundo como quiera el usuario, creando jerarquías muy específicas 🔍📊.


### 1️⃣.2️⃣. Hábitos No Definidos Por el Usuario

La aplicación tiene una limitada opción de posibles categorías a elegir. A diferencia de [1️⃣.1️⃣](#1️⃣.1️⃣.-hábitos-definidos-por-el-usuario) se facilita una característica online de competición de hábitos. Sin embargo es muy limitado y puede ser molesto para el usuario.
