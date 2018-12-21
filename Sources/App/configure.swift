import FluentMySQL
import Vapor
import Authentication
import S3

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    try env.injectConfigFile(DirectoryConfig.detect().workDir + "config.json")
    
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    try services.register(FluentMySQLProvider())
    let config = MySQLDatabaseConfig(hostname: Environment.get("mysql_db_host")!,
                                          port: Int(Environment.get("mysql_db_port")!)!,
                                          username: Environment.get("mysql_db_username")!,
                                          password: Environment.get("mysql_db_password")!,
                                          database: Environment.get("mysql_db_name")!)
    services.register(config)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: AuthToken.self, database: .mysql)
    migrations.add(model: Inventory.self, database: .mysql)
    services.register(migrations)

    let s3Config = S3Signer.Config(accessKey: Environment.get("s3_access_key")!,
                                   secretKey: Environment.get("s3_secret_key")!,
                                   region: .apSoutheast1)
    try services.register(s3: s3Config, defaultBucket: Environment.get("s3_default_bucket")!)
}

extension Environment {
    func injectConfigFile(_ path: String) throws {
        guard let data = FileManager.default.contents(atPath: path),
              let jsonConfig = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] else {
            return
        }
        jsonConfig.forEach { setenv($0.key, $0.1, 1) }
    }
}
