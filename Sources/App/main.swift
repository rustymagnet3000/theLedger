import Vapor
import VaporMySQL
import Foundation
import Fluent

let drop = Droplet()

drop.preparations.append(User.self)
drop.preparations.append(Ledger.self)

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


drop.run()
