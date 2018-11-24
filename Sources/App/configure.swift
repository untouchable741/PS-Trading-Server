import FluentSQLite
import Vapor
import Authentication
import S3

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    try env.injectConfigFile(DirectoryConfig.detect().workDir + "config.json")
    
    /// Register providers first
    try services.register(FluentSQLiteProvider())
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

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .file(path: "\(DirectoryConfig.detect().workDir)ps-trading.db"))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: AuthToken.self, database: .sqlite)
    migrations.add(model: Disk.self, database: .sqlite)
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
