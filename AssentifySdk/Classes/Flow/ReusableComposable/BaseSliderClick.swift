import SwiftUI

public struct BaseSliderClick: View {
    
    public let onNext: () -> Void
    public let label: String
    public let icon: String          // SF Symbol name (replaces ImageVector)
    public let isActive: Bool
    
    public init(
        onNext: @escaping () -> Void,
        label: String,
        icon: String,
        isActive: Bool = true
    ) {
        self.onNext = onNext
        self.label = label
        self.icon = icon
        self.isActive = isActive
    }
    
    // MARK: – State
    @State private var rawOffset: CGFloat = 0
    @State private var trackWidth: CGFloat = 0
    
    // MARK: – Constants
    private let height: CGFloat = 54
    private let knobPadding: CGFloat = 5
    
    private var knobSize: CGFloat { height - 10 }                         // 44 pt
    private var maxOffset: CGFloat {
        max(0, trackWidth - knobSize - knobPadding * 2)
    }
    private var threshold: CGFloat { maxOffset * 0.85 }
    
    // MARK: – Body
    public var body: some View {
        ZStack {
            // ── Track background ────────────────────────────────
            RoundedRectangle(cornerRadius: 100)
                .fill(Color(BaseTheme.fieldColor).opacity(isActive ? 1 : 0.4))
            
            // ── Centre label ────────────────────────────────────
            Text(label)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(
                    (isActive
                     ? Color(BaseTheme.baseTextColor)
                     : Color(BaseTheme.baseTextColor).opacity(0.4))
                )
            
            // ── Right arrows ────────────────────────────────────
            HStack {
                Spacer()
                Image(systemName: "chevron.right.2")       // closest SF symbol
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(
                        Color(BaseTheme.baseTextColor)
                            .opacity(isActive ? 0.5 : 0.2)
                    )
                    .padding(.trailing, 18)
            }
            
            // ── Sliding knob ────────────────────────────────────
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .overlay(
                            BaseTheme.baseClickColor!.toSwiftUIBackground()
                                .clipShape(Circle())
                        )
                        .opacity(isActive ? 1 : 0.4)
                    
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(
                            Color(BaseTheme.fieldColor)
                                .opacity(isActive ? 1 : 0.4)
                        )
                }
                .frame(width: knobSize, height: knobSize)
                .offset(x: rawOffset)
                .animation(.linear(duration: 0.05), value: rawOffset)
                .padding(.leading, knobPadding)
                
                Spacer()
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 100))
        // ── Measure track width ──────────────────────────────────
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    trackWidth = geo.size.width
                }
                .onChange(of: geo.size.width) { newValue in
                    trackWidth = newValue
                }
            }
        )
        // ── Drag gesture ─────────────────────────────────────────
        .gesture(
            isActive
            ? DragGesture(minimumDistance: 1)
                .onChanged { value in
                    rawOffset = min(max(0, value.translation.width), maxOffset)
                }
                .onEnded { _ in settle() }
            : nil
        )
    }
    

    
    private func settle() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if rawOffset >= threshold {
                rawOffset = maxOffset
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onNext()
                    rawOffset = 0           // reset after firing
                }
            } else {
                rawOffset = 0
            }
        }
    }
}
