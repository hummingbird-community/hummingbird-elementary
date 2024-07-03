# Elementary: HTML Templating in Pure Swift

**A modern and efficient HTML rendering library - inspired by SwiftUI, built for the web.**

This packages helps you serve [Elementary](https://swiftpackageindex.com/sliemeobn/elementary) HTML web apps with Hummingbird.

Simply wrap `HTMLResponse` around your HTML content and return it from your routes.

```swift
import Hummingbird
import HummingbirdElementary

let router = Router()
router.get("index") { _, _ in
    HTMLResponse {
        MyIndexPage()
    }
}
```

Check out the docs in the [Elementary repo](https://github.com/sliemeobn/elementary) for more information.
