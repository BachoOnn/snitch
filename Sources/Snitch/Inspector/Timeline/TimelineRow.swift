#if os(iOS)
import SwiftUI

/// The HTTP method in a pill colored by how the request ended. Sits on the timeline wire.
struct MethodPill: View {
    let method: String
    let outcome: NetworkEntry.Outcome

    var body: some View {
        let color = Theme.color(for: outcome)
        Text(method)
            .font(Theme.mono(10, .bold))
            .tracking(0.3)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(color)
            .frame(width: 52, height: 28)
            .background {
                Capsule()
                    .fill(Theme.background)
                    .overlay(Capsule().fill(color.opacity(outcome == .pending ? 0 : 0.08)))
            }
            .overlay {
                Capsule().strokeBorder(
                    color.opacity(outcome == .pending ? 1 : 0.38),
                    style: StrokeStyle(lineWidth: 1, dash: outcome == .pending ? [3, 2] : [])
                )
            }
    }
}

/// The vertical line that joins the timeline's pills.
struct Wire: View {
    var dashed = false

    var body: some View {
        if dashed {
            Line()
                .stroke(Theme.silver.opacity(0.45), style: StrokeStyle(lineWidth: 2, dash: [3, 4]))
                .frame(width: 2)
        } else {
            Rectangle().fill(Theme.border).frame(width: 2)
        }
    }

    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            }
        }
    }
}

/// One request in the timeline: method pill, endpoint, host, status and a small duration.
struct TimelineRow: View {
    let entry: NetworkEntry

    var body: some View {
        HStack(spacing: 12) {
            MethodPill(method: entry.method, outcome: entry.outcome)
                .frame(width: 52)
                .frame(maxHeight: .infinity)
                .background(Wire())

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayPath)
                    .font(Theme.mono(13))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                Text(entry.displayHost)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 9)

            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.displayStatus)
                    .font(Theme.mono(13, .semibold))
                    .foregroundStyle(entry.outcome == .pending ? Theme.secondary : Theme.color(for: entry.outcome))
                if let duration = entry.displayDuration {
                    Text(duration)
                        .font(Theme.mono(10))
                        .foregroundStyle(entry.isSlow ? Theme.warning : Theme.faint)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [entry.method, entry.displayPath, entry.displayHost]
        switch entry.outcome {
        case .pending: parts.append("pending")
        case .failed: parts.append("failed")
        default: parts.append([entry.displayStatus, entry.reasonPhrase].compactMap { $0 }.joined(separator: " "))
        }
        if let duration = entry.displayDuration { parts.append(duration) }
        return parts.joined(separator: ", ")
    }
}

/// Marks a stretch of time when capture was paused.
struct PauseDivider: View {
    let pause: NetworkStore.Pause

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pause.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.silver)
                .frame(width: 16, height: 16)
                .background(Theme.background)
                .frame(width: 52)
                .frame(maxHeight: .infinity)
                .background(Wire(dashed: true))

            HStack(spacing: 0) {
                Text(pause.start.formatted(date: .omitted, time: .standard))
                    .foregroundStyle(Theme.textMuted)
                Text(" · \(pause.durationText)")
                    .foregroundStyle(Theme.tertiary)
            }
            .font(Theme.mono(10))
            .tracking(0.6)
            .fixedSize()

            LinearGradient(colors: [Theme.silver.opacity(0.45), Theme.silver.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(height: 1)
        }
        .padding(.vertical, 6)
        .frame(minHeight: 32)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pause.end == nil
            ? "Paused since \(pause.start.formatted(date: .omitted, time: .shortened)), new requests are not recorded"
            : "Paused for \(pause.durationText), requests were not recorded")
    }
}
#endif
