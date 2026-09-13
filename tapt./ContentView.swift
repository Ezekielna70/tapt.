//
//  ContentView.swift
//  tapt.
//
//  View utama - mengikuti HIG dan Apple Design Guidelines.
//  Desain: monochrome palette + Liquid Glass aesthetic (iOS 26).
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 28) {
                    bigTriggerCircle

                    VStack(spacing: 6) {
                        Text(viewModel.selectedHaptic.title)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(viewModel.selectedHaptic.group.rawValue)
                            .font(.caption.weight(.medium))
                            .textCase(.uppercase)
                            .kerning(3)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    hapticList
                }
                .padding(.vertical, 28)
            }
            .statusBar(hidden: true)
        }
        .onAppear {
            viewModel.prepareAll()
        }
    }

    private var bigTriggerCircle: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.06),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(spacing: 10) {
                Image(systemName: viewModel.selectedHaptic.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.85))

                Text("Tap")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(width: 220, height: 220)
        .contentShape(Circle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onChanged { _ in
                    viewModel.startLongPress()
                }
                .onEnded { _ in
                    viewModel.endLongPress()
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    viewModel.triggerTap()
                }
        )
        .overlay(
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: viewModel.isGlowVisible ? 2 : 1
                )
                .blur(radius: viewModel.isGlowVisible ? 6 : 0)
                .opacity(viewModel.isGlowVisible ? 1 : 0)
                .animation(
                    viewModel.isGlowVisible
                        ? .easeOut(duration: 0.25)
                        : .easeIn(duration: 0.25),
                    value: viewModel.isGlowVisible
                )
        )
        .accessibilityLabel("Trigger \(viewModel.selectedHaptic.title) haptic")
        .accessibilityHint(viewModel.isLongPressing
            ? "Holding for continuous feedback"
            : "Tap for single, long-press for continuous haptic")
        .accessibilityValue(viewModel.isLongPressing
            ? "Continuous mode active"
            : "Idle")
    }

    private var hapticList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(HapticGroup.allGroups) { group in
                    HStack {
                        Text(group.rawValue)
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .kerning(3)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)

                    ForEach(group.haptics) { haptic in
                        HapticRowView(
                            haptic: haptic,
                            isSelected: viewModel.selectedHaptic == haptic
                        ) {
                            viewModel.selectedHaptic = haptic
                        }
                    }

                    if group != HapticGroup.allGroups.last {
                        Divider()
                            .background(Color.white.opacity(0.12))
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

private struct HapticRowView: View {
    let haptic: HapticType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Image(systemName: haptic.icon)
                    .font(.system(size: 20))
                    .frame(width: 24, alignment: .center)
                    .foregroundStyle(.white.opacity(0.8))

                Text(haptic.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(isSelected ? 1 : 0)
                )
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
    }
}

private extension HapticGroup {
    var haptics: [HapticType] {
        HapticType.allCases.filter { $0.group == self }
    }
}

#Preview {
    ContentView()
}
