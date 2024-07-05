# Elementary: HTML Templating in Pure Swift

**A modern and efficient HTML rendering library - inspired by SwiftUI, built for the web.**

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fhummingbird-community%2Fhummingbird-elementary%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/hummingbird-community/hummingbird-elementary)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fhummingbird-community%2Fhummingbird-elementary%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/hummingbird-community/hummingbird-elementary)

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
