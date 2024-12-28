import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.mystuff.app", category: "AddItem")

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let categories: [Category]
    
    @State private var name = ""
    @State private var price = ""
    @State private var purchaseDate = Date()
    @State private var selectedCategory: Category?
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("物品名称", text: $name)
                TextField("价格", text: $price)
                    .keyboardType(.decimalPad)
                DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                
                Section("分类") {
                    Picker("选择分类", selection: $selectedCategory) {
                        Text("无分类").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    
                    Button(action: { showingAddCategory = true }) {
                        Label("新增分类", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("添加新物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Text(alertMessage)
                Button("确定", role: .cancel) { }
            }
            .alert("新增分类", isPresented: $showingAddCategory) {
                TextField("分类名称", text: $newCategoryName)
                Button("取消", role: .cancel) {
                    newCategoryName = ""
                }
                Button("添加") {
                    addCategory()
                }
            }
        }
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        // 检查分类名称是否已存在
        if categories.contains(where: { $0.name == newCategoryName }) {
            // 提示用户分类已存在
            showAlert(title: "分类已存在", message: "请使用不同的分类名称。")
            return
        }
        
        let category = Category(name: newCategoryName)
        modelContext.insert(category)
        selectedCategory = category // 自动选择新创建的分类
        newCategoryName = ""
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func saveItem() {
        guard let priceValue = Double(price) else { return }
        let item = Item(name: name, purchaseDate: purchaseDate, price: priceValue, category: selectedCategory)
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            logger.info("成功保存物品: \(name)")
        } catch {
            logger.error("保存物品失败: \(error.localizedDescription)")
        }
        
        dismiss()
    }
} 