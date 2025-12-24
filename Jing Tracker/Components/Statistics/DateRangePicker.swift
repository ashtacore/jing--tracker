import SwiftUI

struct DateRangePicker: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date
    var defaultStartDate: Date = Date()
    
    private var effectiveStartDate: Binding<Date> {
        Binding(
            get: { startDate ?? defaultStartDate },
            set: { startDate = $0 }
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Date Range")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: effectiveStartDate, in: ...endDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $endDate, in: (startDate ?? defaultStartDate)..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
}
