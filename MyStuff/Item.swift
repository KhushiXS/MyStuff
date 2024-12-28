import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.mystuff.app", category: "Item")

@Model
final class Category {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [Item]
    
    init(name: String) {
        self.name = name
        self.items = []
    }
}

@Model
final class Item {
    var name: String
    var purchaseDate: Date
    var price: Double
    var category: Category?
    
    init(name: String, purchaseDate: Date = Date(), price: Double, category: Category? = nil) {
        self.name = name
        self.purchaseDate = purchaseDate
        self.price = price
        self.category = category
        logger.info("创建新物品: \(name), 价格: \(price), 分类: \(category?.name ?? "无分类")")
    }
    
    // 计算每日平均成本
    var dailyAverageCost: Double {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 1
        return price / Double(max(days, 1))
    }
}
