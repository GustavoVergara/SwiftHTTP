## [Unreleased]
## [1.0.0] - 2021-07-16
### Added
- `HTTPClient`, to receive HTTPRoutes and execute requests
- `HTTPLogger`, to log requests/responses to the console
- `HTTPBody` protocol, to simplify different types of bodys being added to the request
- `JSONBody`, to handle encoding object into JSON and serving as a body to the request
- `Data` conformance to HTTPBody
- HTTPTestKit module with spys to the public protocols, to make it easier to test systems that use this package
