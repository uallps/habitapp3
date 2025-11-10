# 📂 Documentación de la funcionalidad Categorías

## 🎯 Propósito
La funcionalidad **Categorías** permite a los usuarios organizar y clasificar hábitos dentro de la aplicación. Este documento proporciona una visión técnica, consideraciones de diseño e información de implementación relevante.

## 📝 Tabla de Contenidos
1️⃣. [Tipos de categorías](#tipos-de-categorías)

## 1️⃣.Tipos de categorías

### 1️⃣.1️⃣.Hábitos Definidos Por el Usuario
### 1️⃣.1️⃣.1️⃣.🏷 Nombre

Es intuitivo pensar que un hábito se categoriza por un nombre.

Por ejemplo, supongamos que hay un conjunto de hábitos como siguen:
- Limpiar tapicería coche
- Limpiar cristales
- Comprobar pastillas freno
- Lubricar puertas
- Aparcar con las ruedas rectas
- Aparcar con marcha engranada después de freno de mano

Todos estos hábitos están relacionados con la **Mecánica**.  

Sin embargo, algunos hábitos, aun estando relacionados con la mecánica, son **sub-categorías** de la mecánica.

Por ejemplo:
- Tanto limpiar la tapicería del coche como limpiar los cristales son **Limpieza**.
  - Categoría: `Mecánica -> Limpieza`
- El resto está relacionado con el **Mantenimiento** del vehículo o son acciones **preventivas de desgaste**:
  - `Mecánica -> Mantenimiento` (Comprobar pastillas freno)
  - `Mecánica -> Acciones Preventivas` (Aparcar con las ruedas rectas, Aparcar con marcha engranada)

⚡ Se puede ir tan profundo como quiera el usuario.

