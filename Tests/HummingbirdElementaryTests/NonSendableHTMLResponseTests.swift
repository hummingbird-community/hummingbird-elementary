#if swift(>=6.0)
import Elementary
import Hummingbird
import HummingbirdElementary
import HummingbirdTesting
import XCTest

@available(macOS 15.0, *)
final class NonSendableHTMLResponseTests: XCTestCase {
    func testRespondsWithANonSendable() async throws {
        let router = Router().get { _, _ in HTMLResponse { div { NonSendableHTML() } } }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            XCTAssertEqual(String(buffer: response.body), #"<div>Hello</div>"#)
        }
    }

    func testAllowsSendableValuesToBeWrittenTwice() async throws {
        let router = Router().get { request, context in
            let html = HTMLResponse { "Hello" }
            try await html.response(from: request, context: context).body.write(TestWriter())
            return html
        }

        try await Application(router: router).test(.router) { client in
            let response = try await client.execute(uri: "/", method: .get)

            XCTAssertEqual(String(buffer: response.body), #"Hello"#)
        }
    }

    // NOTE: hard to test debug assertions, I leave this test in for manual testing
    // func testThrowsOnSecondWriteOfNonSendable() async throws {
    //     let router = Router().get { request, context in
    //         let html = HTMLResponse { NonSendableHTML() }

    //         try await html.response(from: request, context: context).body.write(TestWriter())
    //         try await html.response(from: request, context: context).body.write(TestWriter())
    //         return html
    //     }

    //     try await Application(router: router).test(.router) { client in
    //         _ = try await client.execute(uri: "/", method: .get)
    //     }
    // }
}

@available(*, unavailable)
extension NonSendableHTML: Sendable {}

struct NonSendableHTML: HTML {
    var content: some HTML {
        "Hello"
    }
}

struct TestWriter: ResponseBodyWriter {
    mutating func write(_: NIOCore.ByteBuffer) async throws {}

    func finish(_: HTTPTypes.HTTPFields?) async throws {}
}
#endif