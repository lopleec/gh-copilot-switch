import SwiftUI

struct StatusBannerView: View {
    let status: StatusMessage
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: status.level.iconName)
                .foregroundStyle(status.level.tint)

            Text(status.text)
                .font(.callout)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 420, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, y: 4)
        .padding(.top, 16)
        .padding(.trailing, 16)
    }
}
