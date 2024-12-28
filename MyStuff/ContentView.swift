import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.mystuff.app", category: "ContentView")

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.purchaseDate, order: .reverse) private var items: [Item]
    @Query private var categories: [Category]
    
    @State private var showingAddItem = false
    @State private var showingAddCategory = false
    @State private var selectedItem: Item?
    @State private var selectedCategory: Category?
    @State private var newCategoryName = ""
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    private var filteredItems: [Item] {
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return items
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AssetSummaryCard(
                        totalValue: totalAssetValue,
                        dailyCost: totalDailyCost,
                        categoryName: selectedCategory?.name
                    )
                    
                    ItemListView(
                        items: filteredItems,
                        onItemSelected: { selectedItem = $0 },
                        onDeleteItems: deleteItems
                    )
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: { selectedCategory = nil }) {
                            HStack {
                                Text("全部")
                                if selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        if !categories.isEmpty {
                            Divider()
                            
                            ForEach(categories) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack {
                                        Text(category.name)
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { showingAddCategory = true }) {
                            Label("新增分类", systemImage: "plus.circle")
                        }
                    } label: {
                        Text(selectedCategory?.name ?? "全部")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Label("添加物品", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(categories: categories)
            }
            .sheet(item: $selectedItem) { item in
                EditItemView(item: item, categories: categories)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Text(alertMessage)
                Button("确定", role: .cancel) { }
            }
            .alert("添加新分类", isPresented: $showingAddCategory) {
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
    
    private var totalAssetValue: Double {
        let itemsToCalculate = selectedCategory == nil ? items : filteredItems
        return itemsToCalculate.reduce(0) { $0 + $1.price }
    }
    
    private var totalDailyCost: Double {
        let itemsToCalculate = selectedCategory == nil ? items : filteredItems
        return itemsToCalculate.reduce(0) { $0 + $1.dailyAverageCost }
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        if categories.contains(where: { $0.name == newCategoryName }) {
            showAlert(title: "分类已存在", message: "请使用不同的分类名称。")
            return
        }
        
        let category = Category(name: newCategoryName)
        modelContext.insert(category)
        newCategoryName = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = filteredItems[index]
                logger.info("删除物品: \(item.name)")
                modelContext.delete(item)
            }
            
            do {
                try modelContext.save()
                logger.info("成功保存删除操作")
            } catch {
                logger.error("保存删除操作失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - 子视图组件
struct AssetSummaryCard: View {
    let totalValue: Double
    let dailyCost: Double
    let categoryName: String?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(categoryName == nil ? "我的总资产" : "我的 \(categoryName!)")
                    .font(.title3)
                    .foregroundStyle(.black)
                Text("¥\(String(format: "%.2f", totalValue))")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            }
            .padding()
            
            // 日均成本显示
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("日均成本")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                    Text("¥\(String(format: "%.2f", dailyCost))")
                        .font(.title2.bold())
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct ItemListView: View {
    let items: [Item]
    let onItemSelected: (Item) -> Void
    let onDeleteItems: (IndexSet) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(items) { item in
                ItemRowView(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onItemSelected(item)
                    }
            }
            .onDelete(perform: onDeleteItems)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
