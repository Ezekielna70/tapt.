//
//  ContentView.swift
//  tapt.
//
//  View utama - mengikuti HIG dan Apple Design Guidelines.
//  Desain: monochrome palette + Liquid Glass aesthetic (iOS 26).
//
//  Layout:
//  - Kartu tengah: lingkaran besar (tap target) yang memicu haptic.
//  - Di bawah kartu: nama haptic yang sedang dipilih.
//  - Di paling bawah: List scroll-y dengan semua jenis haptic,
//    dikelompokkan per keluarga (Impact / Notification).
//
//  MVVM: View hanya menampilkan state dari ContentViewModel
//  dan mengirim intent (tap, selection) kembali ke ViewModel.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background: pure black - monochrome foundation.
                Color.black.ignoresSafeArea()

                VStack(spacing: 28) {
                    // MARK: Big haptic trigger circle
                    bigTriggerCircle

                    // MARK: Selected haptic title
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

                    // MARK: Haptic selection list
                    hapticList
                }
                .padding(.vertical, 28)
            }
            .statusBar(hidden: true)
        }
    }

    // MARK: - Big Trigger Circle

    private var bigTriggerCircle: some View {
        Button(action: {
            viewModel.triggerCurrent()
        }) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .background(Circle().fill(Color.white.opacity(0.08)))

                VStack(spacing: 10) {
                    Image(systemName: viewModel.selectedHaptic.icon)
                        .font(.system(size: 52))
                        .foregroundStyle(.white.opacity(0.85))

                    Text("Tap")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 220, height: 220)
        .contentShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.12),
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
        .accessibilityHint("Double-tap to play this haptic pattern")
    }

    // MARK: - Haptic Selection List

    private var hapticList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(HapticGroup.allCases) { group in
                    // Section header
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

                    // Haptic rows
                    ForEach(group.haptics) { haptic in
                        HapticRowView(
                            haptic: haptic,
                            isSelected: viewModel.selectedHaptic == haptic
                        ) {
                            viewModel.selectedHaptic = haptic
                        }
                    }

                    if group != HapticGroup.allCases.last {
                        Divider()
                            .background(Color.white.opacity(0.12))
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Haptic Row

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

// MARK: - Helper

private extension HapticGroup {
    var haptics: [HapticType] {
        HapticType.allCases.filter { $0.group == self }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
