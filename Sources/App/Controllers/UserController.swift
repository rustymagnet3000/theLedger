import Vapor
import HTTP

final class UserGroupController: ResourceRepresentable {
    typealias Item = User

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: [
            "controller": "UserController.index"
        ])
    }

    func store(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: [
            "controller": "UserController.store"
        ])
    }

    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return try JSON(node: [
            "controller": "UserController.show",
            "user": user
        ])
    }

    func update(request: Request, item user: User) throws -> ResponseRepresentable {
        return try user.makeJSON()
    }

    func destroy(request: Request, item user: User) throws -> ResponseRepresentable {
        return user
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
}
