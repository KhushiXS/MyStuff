import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.mystuff.app", category: "EditItem")

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    let categories: [Category]
    
    @State private var name: String
    @State private var price: String
    @State private var purchaseDate: Date
    @State private var selectedCategory: Category?
    
    init(item: Item, categories: [Category]) {
        self.item = item
        self.categories = categories
        _name = State(initialValue: item.name)
        _price = State(initialValue: String(format: "%.2f", item.price))
        _purchaseDate = State(initialValue: item.purchaseDate)
        _selectedCategory = State(initialValue: item.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("物品名称", text: $name)
                TextField("价格", text: $price)
                    .keyboardType(.decimalPad)
                DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                
                Picker("分类", selection: $selectedCategory) {
                    Text("无分类").tag(nil as Category?)
                    ForEach(categories) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
            }
            .navigationTitle("编辑物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let priceValue = Double(price) else { return }
        
        item.name = name
        item.price = priceValue
        item.purchaseDate = purchaseDate
        item.category = selectedCategory
        
        do {
            try item.modelContext?.save()
            logger.info("成功更新物品: \(name)")
        } catch {
            logger.error("更新物品失败: \(error.localizedDescription)")
        }
        
        dismiss()
    }
}
