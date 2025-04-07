import SwiftUI
import SwiftData

struct KonfirmasiPenjualanView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let selectedItems: [Product: Int]
    let onSave: () -> Void

    @State private var isSaving = false

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

                Text("Konfirmasi Penjualan")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal)
                
                // 🧾 List Produk yang Dipilih
                List {
                    ForEach(Array(selectedItems.keys), id: \.id) { product in
                        let quantity = selectedItems[product] ?? 0
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                Text("Rp\(Int(product.price).formattedWithSeparator()) × \(quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Rp\(Int(product.price * Double(quantity)).formattedWithSeparator())")
                                .bold()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 10)
                .cornerRadius(16)
            

                // 💰 Total
                HStack {
                    Text("Total")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("Rp\(totalHarga.formattedWithSeparator())")
                        .font(.title2)
                        .bold()

                }
                .padding(.horizontal)

                // ✅ Tombol Simpan
                Button {
                    saveTransaction()
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Selesai")
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(isSaving)

                Spacer()
            }
        .background(Color(.systemGray6))
        }

    // MARK: - Total Harga
    private var totalHarga: Double {
        selectedItems.reduce(0) { result, entry in
            let (product, quantity) = entry
            return result + (product.price * Double(quantity))
        }
    }

    // MARK: - Simpan Transaksi
    private func saveTransaction() {
        guard !isSaving else { return }
        isSaving = true

        let sale = Sale(date: .now)

        for (product, quantity) in selectedItems where quantity > 0 {
            let item = ProductOnSale(product: product, quantity: quantity, priceAtSale: product.price)
            sale.items.append(item)
        }

        context.insert(sale)

        do {
            try context.save()
            isSaving = false
            onSave()
            dismiss()
        } catch {
            print("❌ Gagal menyimpan transaksi:", error.localizedDescription)
            isSaving = false
        }
    }
}
