import SwiftUI
import SwiftData

struct DataPenjualanView: View {
    @Query var sales: [Sale]
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate: Date = Date()
    @State private var showTambahPenjualan = false
    @State private var searchText: String = ""

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }

    private var totalPenjualan: Int {
        filteredSales.reduce(0) { $0 + $1.totalPrice }
        
    }
    
    private var filteredSales: [Sale] {
        sales.filter { sale in
            let isSameDate = Calendar.current.isDate(sale.date, inSameDayAs: selectedDate)
            let matchesSearch = searchText.isEmpty || sale.productNames.localizedCaseInsensitiveContains(searchText)
            return isSameDate && matchesSearch
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Kembali")
                    }
                }
                .foregroundColor(.blue)

                Spacer()

                Button {
                    showTambahPenjualan = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Tambah")
                    }
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)

            Text("Kelola Penjualan")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal)

            HStack(spacing: 12) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.blue)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Cari pesanan...", text: $searchText)
                        .autocorrectionDisabled()
                        .font(.callout)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .cornerRadius(12)
            }
            .padding(.horizontal)

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Penjualan")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Rp\(Int(totalPenjualan).formattedWithSeparator())")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
  
                }

                Spacer()
            }
            .padding()
            .background(Color.green)
            .cornerRadius(12)
            .padding(.horizontal)

            if filteredSales.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cart.badge.questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    Text("Belum ada penjualan untuk tanggal ini.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(filteredSales.enumerated()), id: \.element.id) { index, sale in
                        PenjualanCardView(sale: sale, index: index)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .foregroundColor(Color(.systemGray6))
                .listStyle(.plain)
            }

            Spacer()
        }
        .background(Color(.systemGray6))
        .sheet(isPresented: $showTambahPenjualan) {
            TambahPenjualanView(selectedDate: selectedDate)
                .presentationDetents([.large])
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
#Preview {
    DataPenjualanView()
}
