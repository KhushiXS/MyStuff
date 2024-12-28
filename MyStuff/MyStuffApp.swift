import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.mystuff.app", category: "App")

@main
struct MyStuffApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([Item.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
            logger.info("成功初始化数据容器")
        } catch {
            logger.error("初始化数据容器失败: \(error.localizedDescription)")
            fatalError("无法初始化数据容器：\(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
