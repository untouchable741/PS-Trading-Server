import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let authController = AuthController()
    router.post("register", use: authController.login)
    router.post("login", use: authController.login)
    
    let authMiddlewares = [User.tokenAuthMiddleware()]
    let authedRoutes = router.grouped(authMiddlewares)
    userRoutes(authedRoutes.grouped("user"))
    diskRoutes(authedRoutes.grouped("disk"))
}

func userRoutes(_ router: Router) {
    let userController = UserController()
    router.group("profile") { router in
        router.get(use: userController.profile)
        router.post("update", use: userController.update)
    }
}

func diskRoutes(_ router: Router) {
    let diskController = DiskController()
    router.post("create", use: diskController.create)
    router.get("list", use: diskController.list)
    router.post(Int.parameter, use: diskController.update)
    router.delete(Int.parameter, use: diskController.delete)
}
