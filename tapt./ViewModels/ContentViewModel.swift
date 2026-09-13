//
//  ContentViewModel.swift
//  tapt.
//
//  ViewModel untuk ContentView — mengikuti pola MVVM.
//
//  Bertanggung jawab atas:
//  - State UI (apakah lagi memunculkan haptic)
//  - Memicu haptic melalui HapticService (abstraksi dari UIKit)
//  - Long-press continuous haptic (timer berulang)
//  - Pre-warming generators untuk latency minimal
//
//  Design note: semua logika interaksi berada di sini.
//  View hanya bertugas menampilkan state dan mengirim intent.
//

import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {

    // MARK: - Published State

    /// Haptic yang sedang dipilih / ditampilkan di kartu tengah.
    /// Default ke Light Impact — entry point yang paling netral.
    @Published var selectedHaptic: HapticType = .impactLight

    /// Flag untuk animasi visual saat haptic terpicu.
    @Published private(set) var isGlowVisible: Bool = false

    /// Flag untuk menandai apakah haptic sudah dipicu selama sesi ini.
    @Published var hasTriggered: Bool = false

    /// Flag saat long-press aktif — haptic terus-menerus sedang berjalan.
    @Published private(set) var isLongPressing: Bool = false

    // MARK: - Private State

    private var glowCancellable: AnyCancellable?
    private var continuousHapticTimer: Timer?

    // MARK: - Public API

    /// Trigger haptic sekali — dipanggil saat tap biasa.
    /// Langsung memanggil generator (sudah di-prepare) untuk latency minimal.
    func triggerTap() {
        glowPulse()
        hasTriggered = true
        HapticService.shared.trigger(selectedHaptic)
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

    /// Mulai long-press — memicu haptic berulang setiap ~120ms.
    /// Interval dipilih agar "continuous" terasa natural di tangan,
    /// konsisten dengan HIG haptic feedback untuk interaksi berkelanjutan.
    func startLongPress() {
        isLongPressing = true
        hasTriggered = true
        glowPulse()

        // Fire immediately
        HapticService.shared.trigger(selectedHaptic)

        // Then repeat on a timer
        continuousHapticTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            HapticService.shared.trigger(self.selectedHaptic)
        }
    }

    /// Hentikan long-press — invalidate timer, reset state.
    func endLongPress() {
        isLongPressing = false
        continuousHapticTimer?.invalidate()
        continuousHapticTimer = nil
        glowPulse()
    }

    /// Pre-warm semua generators saat view muncul.
    /// HIG merekomendasikan prepare() dipanggil sebelum feedback
    /// untuk memastikan response paling cepat.
    func prepareAll() {
        HapticService.shared.prepareAll()
    }

    // MARK: - Private

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

    deinit {
        continuousHapticTimer?.invalidate()
    }
}
