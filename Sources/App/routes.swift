import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let authController = AuthController()
    router.post("register", use: authController.register)
    
    let authMiddlewares = [User.tokenAuthMiddleware()]
    let authedRoutes = router.grouped(authMiddlewares)
    userRoutes(authedRoutes.grouped("user"))
}

func userRoutes(_ router: Router) {
    let userController = UserController()
    router.get("profile", use: userController.profile)
}
