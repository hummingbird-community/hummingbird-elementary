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

    /// Response headers
    ///
    /// It can be used to add additional headers to a predefined set of fields.
    ///
    /// - Note: If a new set of headers is assigned, all predefined headers are removed.
    ///
    /// ```swift
    /// var response = HTMLResponse { ... }
    /// response.headers[.init("foo")!] = "bar"
    /// return response
    /// ```
    public var headers: HTTPFields = [.contentType: "text/html; charset=utf-8"]

    /// Creates a new HTMLResponse
    ///
    /// - Parameters:
    ///   - chunkSize: The number of bytes to write to the response body at a time.
    ///   - additionalHeaders: Additional headers to be merged with predefined headers.
    ///   - content: The `HTML` content to render in the response.
    public init(chunkSize: Int = 1024, additionalHeaders: HTTPFields = [:], @HTMLBuilder content: () -> Content) {
        self.chunkSize = chunkSize
        if additionalHeaders.contains(.contentType) {
            self.headers = additionalHeaders
        } else {
            self.headers = [.contentType: "text/html; charset=utf-8"] + additionalHeaders
        }
        self.content = content()
    }
}

extension HTMLResponse: ResponseGenerator {
    public consuming func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: .ok,
            headers: self.headers,
            body: .init { [self] writer in
                try await writer.writeHTML(self.content, chunkSize: self.chunkSize)
                try await writer.finish(nil)
            }
        )
    }
}
