import Foundation

/// Protocol para plugins que gestionan datos y necesitan ser notificados de eventos
protocol DataPlugin: FeaturePlugin {
    /// Se llama cuando se va a eliminar un Task
    /// - Parameter task: La tarea que será eliminada
    //func willDeleteTask(_ task: Task) async
    
    /// Se llama después de eliminar un Task
    /// - Parameter taskId: ID de la tarea eliminada
    //func didDeleteTask(taskId: UUID) async
}
