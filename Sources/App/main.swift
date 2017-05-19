import Vapor
import VaporMySQL
import Foundation
import Fluent
import Auth
import VaporSecurityHeaders

/* initalize droplet */
let drop = Droplet()
drop.preparations.append(LedgerUser.self)
drop.preparations.append(Ledger.self)
try drop.addProvider(VaporMySQL.Provider.self)
/*********************************************/

/* middleware setup */
let securityHeaders = SecurityHeaders()
drop.middleware.insert(securityHeaders, at: 0)

drop.addConfigurable(middleware: AuthMiddleware(user: LedgerUser.self), name: "auth")
drop.middleware.append(VersionMiddleware())
drop.middleware.append(NonceMiddleware())
drop.middleware.append(LedgerErrorMiddleware())
/*********************************************/

/* add routes setup */
let ledger = LedgerController()
ledger.addRoutes(drop: drop)
let user = UserController()
user.addRoutes(drop: drop)
let user_auth = UserController_Auth()
user_auth.addRoutes(drop: drop)
/*********************************************/

/* add catch-all drop requests */
drop.get("/") { request in
    return try drop.view.make("welcome.html")
}

drop.get("/skeleton") { request in
    return try drop.view.make("skeleton.leaf")
}

drop.run()
