import Elementary
import Hummingbird

/// Represents a response that contains HTML content.
///
/// The generated `Response` will have the content type header set to `text/html; charset=utf-8` and a status of `.ok`.
/// The content is renederd in chunks of HTML and streamed in the response body.
///
/// ```swift
/// router.get { request, context in
///   HTMLResponse {
///     div {
///       p { "Hello!" }
///     }
///   }
/// }
/// ```
public struct HTMLResponse<Content: HTML & Sendable>: Sendable {
    // NOTE: The Sendable requirement on Content can probably be removed in Swift 6 using a sending parameter, and some fancy ~Copyable @unchecked Sendable box type.
    // We only need to pass the HTML value to the response generator body closure
    private let content: Content

    /// The number of bytes to write to the response body at a time.
    ///
    /// The default is 1024 bytes.
    public var chunkSize: Int

    /// Creates a new HTMLResponse
    ///
    /// - Parameters:
    ///   - chunkSize: The number of bytes to write to the response body at a time.
    ///   - content: The `HTML` content to render in the response.
    public init(chunkSize: Int = 1024, @HTMLBuilder content: () -> Content) {
        self.chunkSize = chunkSize
        self.content = content()
    }
}

extension HTMLResponse: ResponseGenerator {
    struct StreamWriter: HTMLStreamWriter {
        let allocator: ByteBufferAllocator
        var writer: any ResponseBodyWriter

        mutating func write(_ bytes: ArraySlice<UInt8>) async throws {
            try await self.writer.write(self.allocator.buffer(bytes: bytes))
        }
    }

    public consuming func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init { [self] writer in
                try await self.content.render(into: StreamWriter(allocator: ByteBufferAllocator(), writer: writer), chunkSize: self.chunkSize)
                try await writer.finish(nil)
            }
        )
    }
}
