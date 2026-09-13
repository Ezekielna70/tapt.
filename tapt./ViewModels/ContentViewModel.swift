//
//  ContentViewModel.swift
//  tapt.
//
//  ViewModel untuk ContentView — mengikuti pola MVVM.
//  Bertanggung jawab atas:
//  - State UI (apakah lagi memunculkan haptic)
//  - Memicu haptic melalui HapticService (abstraksi dari UIKit)
//  - Mengelola timer feedback glow effect
//
//  Design note: semua logika interaksi berada di sini.
//  View hanya bertugas menampilkan state dan mengirim intent.
//

import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {

    /// Haptic yang sedang dipilih / ditampilkan di kartu tengah.
    /// Default ke Light Impact — entry point yang paling netral.
    @Published var selectedHaptic: HapticType = .impactLight {
        didSet { triggerHaptic(selectedHaptic) }
    }

    /// Flag untuk animasi visual saat haptic terpicu.
    @Published private(set) var isGlowVisible: Bool = false

    /// Flag untuk menandai apakah haptic sudah dipicu selama sesi ini.
    /// Dipakai untuk menampilkan hint aksesibilitas.
    @Published var hasTriggered: Bool = false

    private var glowCancellable: AnyCancellable?

    // MARK: - Public API

    /// Memicu haptic secara eksplisit — dipanggil ketika pengguna
    /// menekan tombol "Trigger" di luar perubahan selectedHaptic.
    func triggerCurrent() {
        triggerHaptic(selectedHaptic)
    }

    /// Memilih haptic berikutnya secara circular.
    func selectNext() {
        let all = HapticType.allCases
        guard let currentIndex = all.firstIndex(of: selectedHaptic) else {
            selectedHaptic = all.first ?? .impactLight
            return
        }
        let nextIndex = all.index(after: currentIndex)
        selectedHaptic = all[nextIndex == all.endIndex ? all.startIndex : nextIndex]
    }

    // MARK: - Private

    private func triggerHaptic(_ type: HapticType) {
        glowPulse()
        hasTriggered = true
        HapticService.shared.trigger(type)
    }

    /// Animasi visual singkat (glow pulse) untuk feedback visual
    /// yang melengkapi haptic — konsisten dengan HIG "provide visible affirmation".
    private func glowPulse() {
        isGlowVisible = true
        glowCancellable?.cancel()
        glowCancellable = Just(())
            .delay(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { _ in
                self.isGlowVisible = false
            }
    }
}
