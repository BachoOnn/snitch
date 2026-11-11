import Foundation
import Network

/// A tiny HTTP server on 127.0.0.1, for behavior the stub can't show, such as how
/// URLSession itself stores and sends cookies. Nothing leaves the device.
///
/// - `/set` replies with `Set-Cookie: probe=1`.
/// - `/echo` replies with the request's `Cookie` header, or `none`.
final class LocalHTTPServer {
    private let listener: NWListener
    private let queue = DispatchQueue(label: "dev.snitch.tests.server")
    private(set) var port: UInt16 = 0

    init() throws {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: "127.0.0.1", port: .any)
        listener = try NWListener(using: parameters)
    }

    /// Starts listening and waits until the port is known.
    func start() async throws {
        let ready = AsyncStream<Void> { continuation in
            listener.stateUpdateHandler = { state in
                if case .ready = state { continuation.yield(); continuation.finish() }
            }
        }
        listener.newConnectionHandler = { [queue] connection in
            connection.start(queue: queue)
            Self.serve(connection, received: Data())
        }
        listener.start(queue: queue)
        for await _ in ready { break }
        port = listener.port?.rawValue ?? 0
    }

    func stop() {
        listener.cancel()
    }

    func url(_ path: String) -> URL {
        URL(string: "http://127.0.0.1:\(port)\(path)")!
    }

    private static func serve(_ connection: NWConnection, received: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { data, _, done, error in
            let all = received + (data ?? Data())
            let text = String(decoding: all, as: UTF8.self)
            guard text.contains("\r\n\r\n") else {
                if done || error != nil { connection.cancel() } else { serve(connection, received: all) }
                return
            }
            connection.send(content: response(to: text), completion: .contentProcessed { _ in connection.cancel() })
        }
    }

    private static func response(to request: String) -> Data {
        let lines = request.components(separatedBy: "\r\n")
        let path = lines.first?.split(separator: " ").dropFirst().first.map(String.init) ?? "/"
        let cookie = lines.first { $0.lowercased().hasPrefix("cookie:") }
            .map { String($0.dropFirst("cookie:".count)).trimmingCharacters(in: .whitespaces) }
        var headers = "Connection: close\r\n"
        let body: String
        if path.hasPrefix("/set") {
            headers += "Set-Cookie: probe=1; Path=/\r\n"
            body = "set"
        } else {
            body = cookie ?? "none"
        }
        return Data("HTTP/1.1 200 OK\r\n\(headers)Content-Length: \(body.utf8.count)\r\n\r\n\(body)".utf8)
    }
}
