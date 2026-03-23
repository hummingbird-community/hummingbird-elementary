import Elementary
import Hummingbird
import HummingbirdElementary
import HummingbirdTesting
import Testing

struct HTMLResponseTests {
    @Test
    func setsHeadersAndStatus() async throws {
        let router = Router().get { _, _ in HTMLResponse { EmptyHTML() } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)
            #expect(response.status == .ok)
            #expect(response.headers[.contentType] == "text/html; charset=utf-8")
            #expect(response.body.readableBytes == 0)
        }
    }

    @Test
    func respondsWithAPage() async throws {
        let router = Router().get { _, _ in HTMLResponse { TestPage() } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(
                String(buffer: response.body)
                    == #"<!DOCTYPE html><html><head><title>Test Page</title><link rel="stylesheet" href="/styles.css"></head><body><h1 id="foo">bar</h1></body></html>"#
            )
        }
    }

    @Test
    func respondsWithAFragment() async throws {
        let router = Router().get { _, _ in HTMLResponse { p {} } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(String(buffer: response.body) == #"<p></p>"#)
        }
    }

    @Test
    func respondsWithALargeDocument() async throws {
        let count = 1000
        let router = Router().get { _, _ in
            HTMLResponse {
                for _ in 0..<count {
                    p {}
                }
            }
        }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(String(buffer: response.body) == Array(repeating: "<p></p>", count: count).joined())
        }
    }

    @Test
    func respondsWithCustomStatus() async throws {
        let router = Router().get { _, _ in HTMLResponse(status: .created) { EmptyHTML() } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)
            #expect(response.status == .created)
            #expect(response.headers[.contentType] == "text/html; charset=utf-8")
        }
    }

    @Test
    func respondsWithCustomHeaders() async throws {
        let router = Router().get { _, _ in
            var response = HTMLResponse(additionalHeaders: [.init("foo")!: "bar"]) { EmptyHTML() }
            response.headers[.init("hx-refresh")!] = "true"
            return response
        }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(response.headers[.init("foo")!] == "bar")
            #expect(response.headers[.init("hx-refresh")!] == "true")
            #expect(response.headers[.contentType] == "text/html; charset=utf-8")
        }
    }

    @Test
    func respondsWithOverwrittenContentType() async throws {
        let router = Router().get { _, _ in
            HTMLResponse(additionalHeaders: [.contentType: "new"]) { EmptyHTML() }
        }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(response.headers[.contentType] == "new")
        }
    }

    @Test
    func respondsByWritingToStream() async throws {
        let router = Router().get { _, _ in
            Response(
                status: .ok,
                headers: [:],
                body: .init { writer in
                    try await writer.writeHTML(p { "Hello" })
                    try await writer.finish(nil)
                }
            )
        }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            #expect(String(buffer: response.body) == #"<p>Hello</p>"#)
        }
    }
}

struct TestPage: HTMLDocument {
    var title: String { "Test Page" }

    var head: some HTML {
        link(.rel(.stylesheet), .href("/styles.css"))
    }

    var body: some HTML {
        h1(.id("foo")) { "bar" }
    }
}
