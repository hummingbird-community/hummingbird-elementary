import Elementary
import Hummingbird
import HummingbirdElementary
import HummingbirdTesting
import XCTest

final class HTMLResponseTests: XCTestCase {
    func testSetsHeadersAndStatus() async throws {
        let router = Router().get { _, _ in HTMLResponse { EmptyHTML() } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.headers[.contentType], "text/html; charset=utf-8")
            XCTAssertEqual(response.body.readableBytes, 0)
        }
    }

    func testRespondsWithAPage() async throws {
        let router = Router().get { _, _ in HTMLResponse { TestPage() } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            XCTAssertEqual(String(buffer: response.body), #"<!DOCTYPE html><html><head><title>Test Page</title><link rel="stylesheet" href="/styles.css"></head><body><h1 id="foo">bar</h1></body></html>"#)
        }
    }

    func testRespondsWithAFragment() async throws {
        let router = Router().get { _, _ in HTMLResponse { p {} } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            XCTAssertEqual(String(buffer: response.body), #"<p></p>"#)
        }
    }

    func testRespondsWithALargeDocument() async throws {
        let count = 1000
        let router = Router().get { _, _ in HTMLResponse {
            for _ in 0..<count {
                p {}
            }
        } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            XCTAssertEqual(String(buffer: response.body), Array(repeating: "<p></p>", count: count).joined())
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
