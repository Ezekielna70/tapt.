//
//  HapticService.swift
//  tapt.
//
//  Service layer yang meng-abstraksi UIKit haptic generators.
//  Dipisahkan dari ViewModel agar logika feedback physics tidak
//  mencemurikan framework ke dalam business logic.
//
//  Menggunakan lazy generator — generator hanya dibuat saat pertama
//  dipakai, konsisten dengan HIG rekomendasi "minimal generator usage".
//  Semua generator di-prepare() pada init untuk latency minimal.
//

import UIKit

/// Servic e yang mengelola semua jenis haptic feedback di iOS.
///
/// - Impact haptics: physical interaction feedback (light -> rigid)
/// - Notification haptics: system state feedback (success / warning / error)
///
/// Setiap metode akan otomatis memicu generator-nya.
/// Semua generator di-prepare() saat init untuk response instan.
final class HapticService {

    // MARK: - Shared Instance

    static let shared = HapticService()

    // MARK: - Impact Generators (pre-prepared)

    private let impactLight: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        return g
    }()

    private let impactMedium: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        return g
    }()

    private let impactHeavy: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        return g
    }()

    private let impactSoft: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.prepare()
        return g
    }()

    private let impactRigid: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .rigid)
        g.prepare()
        return g
    }()

    // MARK: - Notification Generator (pre-prepared)

    private let notification: UINotificationFeedbackGenerator = {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        return g
    }()

    // MARK: - Public API

    /// Re-prepare ALL generators — call on viewWillAppear for
    /// minimal-latency feedback. HIG recommends prepare() right
    /// before triggering.
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        notification.prepare()
    }

    /// Memicu haptic berdasarkan tipe yang dipilih.
    /// Semua generator sudah di-prepare sehingga response instan.
    func trigger(_ type: HapticType) {
        switch type {

        // --- Impact ---
        case .impactLight:
            impactLight.impactOccurred()
            impactLight.prepare()

        case .impactMedium:
            impactMedium.impactOccurred()
            impactMedium.prepare()

        case .impactHeavy:
            impactHeavy.impactOccurred()
            impactHeavy.prepare()

        case .impactSoft:
            impactSoft.impactOccurred()
            impactSoft.prepare()

        case .impactRigid:
            impactRigid.impactOccurred()
            impactRigid.prepare()

        // --- Notification ---
        case .notificationSuccess:
            notification.notificationOccurred(.success)
            notification.prepare()

        case .notificationWarning:
            notification.notificationOccurred(.warning)
            notification.prepare()

        case .notificationError:
            notification.notificationOccurred(.error)
            notification.prepare()
        }
    }
}
