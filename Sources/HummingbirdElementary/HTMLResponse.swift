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
///
/// NOTE: For non-sendable HTML values, the resulting response body can only be written once.
/// Multiple writes will result in a runtime error.
/// ```
public struct HTMLResponse {
    private let value: _SendableAnyHTMLBox

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
    public init(chunkSize: Int = 1024, additionalHeaders: HTTPFields = [:], @HTMLBuilder content: () -> some HTML & Sendable) {
        self.init(chunkSize: chunkSize, additionalHeaders: additionalHeaders, value: .init(content()))
    }

    #if swift(>=6.0)
    @available(macOS 15, *)
    /// Creates a new HTMLResponse
    ///
    /// - Parameters:
    ///   - chunkSize: The number of bytes to write to the response body at a time.
    ///   - additionalHeaders: Additional headers to be merged with predefined headers.
    ///   - content: The `HTML` content to render in the response.
    public init(chunkSize: Int = 1024, additionalHeaders: HTTPFields = [:], @HTMLBuilder content: () -> sending some HTML) {
        self.init(chunkSize: chunkSize, additionalHeaders: additionalHeaders, value: .init(content()))
    }
    #endif

    init(chunkSize: Int, additionalHeaders: HTTPFields = [:], value: _SendableAnyHTMLBox) {
        self.chunkSize = chunkSize
        if additionalHeaders.contains(.contentType) {
            self.headers = additionalHeaders
        } else {
            self.headers.append(contentsOf: additionalHeaders)
        }
        self.value = value
    }
}

extension HTMLResponse: ResponseGenerator {
    public consuming func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: .ok,
            headers: self.headers,
            body: .init { [value, chunkSize] writer in
                guard let html = value.tryTake() else {
                    assertionFailure("Non-sendable HTML value consumed more than once")
                    context.logger.error("Non-sendable HTML value consumed more than once")
                    throw HTTPError(.internalServerError)
                }

                try await writer.writeHTML(html, chunkSize: chunkSize)
                try await writer.finish(nil)
            }
        )
    }
}
