import Foundation

final class URLSessionDataLoader: DataLoader {
    private let session: URLSession
    private let ongoingTasks: TaskManager

    init(session: URLSession = .shared) {
        self.session = session
        self.ongoingTasks = TaskManager()
    }

    func loadResource(from url: URL) async throws -> Data {
        if let ongoingTask = await ongoingTasks.getTask(for: url) {
            return try await ongoingTask.value
        }

        // creates a task to be stored in task manager.
        let task = Task<Data, Error> {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            return data
        }

        await ongoingTasks.setTask(task, for: url)

        do {
            await ongoingTasks.removeTask(for: url)
            return try await task.value
        } catch {
            await ongoingTasks.removeTask(for: url)
            throw error
        }
    }
}

// MARK: - TaskManager

/// Manages ongoing tasks to avoid sending multiple requests for the same url.
private actor TaskManager {
    private var tasks: [URL: Task<Data, Error>] = [:]

    func getTask(for url: URL) -> Task<Data, Error>? {
        return tasks[url]
    }

    func setTask(_ task: Task<Data, Error>, for url: URL) {
        tasks[url] = task
    }

    func removeTask(for url: URL) {
        tasks[url] = nil
    }
}
