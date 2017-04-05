import Vapor
import VaporMySQL
import Foundation
import Fluent
import Auth

let drop = Droplet()

drop.preparations.append(LedgerUser.self)
drop.preparations.append(Ledger.self)
drop.addConfigurable(middleware: AuthMiddleware(user: LedgerUser.self), name: "auth")
try drop.addProvider(VaporMySQL.Provider.self)

drop.middleware.append(VersionMiddleware())
drop.middleware.append(LedgerErrorMiddleware())

let ledger = LedgerController()
ledger.addRoutes(drop: drop)
ledger.addSmokeRoutes(drop: drop)

let user = UserController()
user.addRoutes(drop: drop)

drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.get("/skeleton") { request in
    return try drop.view.make("skeleton.leaf")
}

drop.run()
