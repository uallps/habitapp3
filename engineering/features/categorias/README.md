# Documentación de la funcionalidad Categorías

## Resumen
La funcionalidad **Categorías** permite a los usuarios organizar y clasificar hábitos dentro de la aplicación. Este documento proporciona una visión técnica, consideraciones de diseño e información de implementación relevante.

## Tabla de Contenidos
1. [Propósito](#propósito)
2. [Requisitos](#requisitos)
3. [Modelo de Datos](#modelo-de-datos)
4. [Componentes de UI](#componentes-de-ui)
5. [Navegación](#navegación)
6. [Persistencia](#persistencia)
7. [Lógica de Negocio](#lógica-de-negocio)
8. [Ejemplos de Código](#ejemplos-de-código)
9. [Pruebas](#pruebas)
10. [Mejoras Futuras](#mejoras-futuras)

## Propósito
Explica por qué existe esta funcionalidad y cómo mejora la experiencia del usuario:
- Organizar elementos por categorías.
- Permitir filtrado y agrupamiento.
- Mejorar la navegación y la descubribilidad.

## Requisitos
- Objetivo iOS/macOS: `iOS 16+/macOS 13+`
- SwiftUI 4+
- Swift 5.8+
- Core Data o capa de persistencia alternativa
- Opcional: Combine para actualizaciones reactivas

## Modelo de Datos
