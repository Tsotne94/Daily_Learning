class User {
    var name: String
    let password: String
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
}

@MainActor
struct App {
    static func main() async {
        async let user = User(name: "twostraws", password: "fr0st1es")
        await print(user.name)
    }
}
