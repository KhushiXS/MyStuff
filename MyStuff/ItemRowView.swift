import SwiftUI
import SwiftData

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                Text("¥\(String(format: "%.2f", item.price))")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text(item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .foregroundStyle(.secondary)
                    Text("¥\(String(format: "%.2f", item.dailyAverageCost))/天")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            
            if let category = item.category {
                HStack {
                    Image(systemName: "tag")
                        .foregroundStyle(.secondary)
                    Text(category.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }
} 