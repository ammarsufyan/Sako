import SwiftUI
import SwiftData

struct TambahPenjualanView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allProducts: [Product]
    
    @State private var selectedItems: [Product: Int] = [:]
    @State private var searchText = ""
    @State private var showConfirmationSheet = false

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return allProducts
        }
        return allProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var totalItems: Int {
        selectedItems.values.reduce(0, +)
    }

    var totalPrice: Double {
        selectedItems.reduce(0) { $0 + (Double($1.value) * $1.key.price) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 🔙 Header
            HStack {
                Button("Batal") { dismiss() }
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            Text("Tambah Penjualan")
                .font(.system(size: 34, weight: .bold))
                .padding(.horizontal)

            // 🔍 Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Cari Produk", text: $searchText)
                    .font(.body)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // 📋 Product List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredProducts) { product in
                        ProductRowCardView(product: product, quantity: selectedItems[product] ?? 0) { newQty in
                            if newQty == 0 {
                                selectedItems.removeValue(forKey: product)
                            } else {
                                selectedItems[product] = newQty
                            }
                        }
                    }
                }
                .padding()
            }

            // ✅ Confirm Bar
            if totalItems > 0 {
                Button {
                    showConfirmationSheet = true
                } label: {
                    HStack {
                        Label("\(totalItems) Item", systemImage: "basket.fill")
                        Spacer()
                        Text("Rp\(Int(totalPrice).formattedWithSeparator())")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            KonfirmasiPenjualanView(
                selectedItems: selectedItems,
                onSave: {
                    selectedItems = [:] // 🧼 reset after save
                    dismiss()
                }
            )
        }
    }
}
