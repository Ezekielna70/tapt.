//
//  HapticType.swift
//  tapt.
//
//  Enum yang mewakili semua jenis haptic feedback di iOS.
//  iOS menyediakan dua keluarga haptic:
//  1. UIImpactFeedbackGenerator — untuk interaksi fisik (impact)
//  2. UINotificationFeedbackGenerator — untuk notifikasi sistem (success, warning, error)
//
//  Setiap kasus punya deskripsi HIG-compliant untuk ditampilkan di UI.
//

import Foundation

/// Semua jenis haptic yang didukung oleh iOS,
/// dikelompokkan berdasarkan keluarga feedback generator.
enum HapticType: CaseIterable, Identifiable, Hashable {

    // --- Impact haptics (gerak fisik) ---
    case impactLight
    case impactMedium
    case impactHeavy
    case impactSoft
    case impactRigid

    // --- Notification haptics (state sistem) ---
    case notificationSuccess
    case notificationWarning
    case notificationError

    var id: String { title }

    /// Nama tampilan pengguna — dipakai di List dan sebagai label aksesibilitas.
    var title: String {
        switch self {
        // Impact
        case .impactLight:  return "Light Impact"
        case .impactMedium: return "Medium Impact"
        case .impactHeavy:  return "Heavy Impact"
        case .impactSoft:   return "Soft Impact"
        case .impactRigid:  return "Rigid Impact"

        // Notification
        case .notificationSuccess: return "Success Notification"
        case .notificationWarning: return "Warning Notification"
        case .notificationError:   return "Error Notification"
        }
    }

    /// Ikon SFSymbol yang mewakili tiap jenis haptic.
    /// Ikon dipilih agar konsisten dengan semantic-nya di HIG.
    var icon: String {
        switch self {
        case .impactLight:  return "circle.circle"
        case .impactMedium: return "circle.diamond"
        case .impactHeavy:  return "circle.square"
        case .impactSoft:   return "circle.ellipse"
        case .impactRigid:  return "circle.rectangle"
        case .notificationSuccess: return "checkmark.circle"
        case .notificationWarning: return "exclamationmark.triangle"
        case .notificationError:   return "xmark.octagon"
        }
    }

    /// Kelompok — berguna untuk dipisahkan di UI dengan section header.
    var group: HapticGroup {
        switch self {
        case .impactLight, .impactMedium, .impactHeavy, .impactSoft, .impactRigid:
            return .impact
        case .notificationSuccess, .notificationWarning, .notificationError:
            return .notification
        }
    }
}

/// Kelompok haptic untuk section header di List.
enum HapticGroup: String, CaseIterable, Identifiable, Hashable {
    case impact = "Impact Feedbacks"
    case notification = "Notification Feedbacks"

    var id: String { rawValue }

    /// Array of all groups — for ForEach which requires RandomAccessCollection.
    static var allGroups: [HapticGroup] {
        [.impact, .notification]
    }
}
