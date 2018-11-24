import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let authController = AuthController()
    router.post("register", use: authController.login)
    router.post("login", use: authController.login)
    
    let authMiddlewares = [User.tokenAuthMiddleware()]
    let authedRoutes = router.grouped(authMiddlewares)
    userRoutes(authedRoutes.grouped("user"))
    inventoryRoutes(authedRoutes.grouped("inventories"))
}

func userRoutes(_ router: Router) {
    let userController = UserController()
    router.group("profile") { router in
        router.get(use: userController.profile)
        router.post("update", use: userController.update)
    }
}

func inventoryRoutes(_ router: Router) {
    let inventoriesController = InventoriesController()
    router.post("create", use: inventoriesController.create)
    router.get("list", use: inventoriesController.list)
    router.post(Int.parameter, use: inventoriesController.update)
    router.delete(Int.parameter, use: inventoriesController.delete)
}
