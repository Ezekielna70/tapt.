//
//  ContentViewModel.swift
//  tapt.
//
//  ViewModel untuk ContentView — MVVM architecture.
//

import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {

    @Published var selectedHaptic: HapticType = .impactLight
    @Published private(set) var isGlowVisible: Bool = false
    @Published var hasTriggered: Bool = false
    @Published private(set) var isLongPressing: Bool = false

    private var glowCancellable: AnyCancellable?
    private var continuousHapticTimer: Timer?

    func triggerTap() {
        glowPulse()
        hasTriggered = true
        HapticService.shared.trigger(selectedHaptic)
    }

    func startLongPress() {
        guard !isLongPressing else { return }
        isLongPressing = true
        hasTriggered = true
        glowPulse()
        HapticService.shared.trigger(selectedHaptic)
        continuousHapticTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            HapticService.shared.trigger(self.selectedHaptic)
        }
    }

    func endLongPress() {
        isLongPressing = false
        continuousHapticTimer?.invalidate()
        continuousHapticTimer = nil
        glowPulse()
    }

    func prepareAll() {
        HapticService.shared.prepareAll()
    }

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
