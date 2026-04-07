//
//  LaunchAtLoginService.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation
import ServiceManagement
import Combine

class LaunchAtLoginService: ObservableObject {
    static let shared = LaunchAtLoginService()

    @Published var isEnabled: Bool {
        didSet {
            if isEnabled != oldValue {
                if isEnabled {
                    enableLaunchAtLogin()
                } else {
                    disableLaunchAtLogin()
                }
            }
        }
    }

    private init() {
        // Check current status
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func enableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.register()
            print("Successfully enabled launch at login")
        } catch {
            print("Failed to enable launch at login: \(error.localizedDescription)")
            // Reset the toggle if it failed
            isEnabled = false
        }
    }

    private func disableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.unregister()
            print("Successfully disabled launch at login")
        } catch {
            print("Failed to disable launch at login: \(error.localizedDescription)")
            // Reset the toggle if it failed
            isEnabled = true
        }
    }

    var statusDescription: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "Launch at login is enabled"
        case .notRegistered:
            return "Launch at login is not registered"
        case .notFound:
            return "Service not found"
        case .requiresApproval:
            return "Requires approval in System Settings"
        @unknown default:
            return "Unknown status"
        }
    }
}
