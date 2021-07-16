//
//  Utils.swift
//  Nudge
//
//  Created by Erik Gomez on 2/5/21.
//

import AppKit
import Foundation
import SystemConfiguration
import SwiftUI

// https://stackoverflow.com/questions/29985614/how-can-i-change-locale-programmatically-with-swift
// Apple recommends against this, but this is super frustrating since Nudge does dynamic UIs
extension String {
    func localized(desiredLanguage :String) ->String {
        // Try to get the language passed and if it does not exist, use en
        let path = Bundle.main.path(forResource: desiredLanguage, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

struct Utils {
    func activateNudge() {
        let msg = "Re-activating Nudge"
        utilsLog.info("\(msg, privacy: .public)")
        // NSApp.windows[0] is only safe because we have a single window. Should we increase windows, this will be a problem.
        // Sheets do not count as windows though.
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows[0].makeKeyAndOrderFront(self)
    }

    func centerNudge() {
        // NSApp.windows[0] is only safe because we have a single window. Should we increase windows, this will be a problem.
        // Sheets do not count as windows though.
        NSApp.windows[0].center()
    }

    func coerceStringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: dateString) ?? Date()
    }

    func createImageData(fileImagePath: String) -> NSImage {
        utilsLog.debug("Creating image path for \(fileImagePath, privacy: .public)")
        let urlPath = NSURL(fileURLWithPath: fileImagePath)
        var imageData = NSData()
        do {
            imageData = try NSData(contentsOf: urlPath as URL)
        } catch {
            uiLog.error("Error accessing file \(fileImagePath). Incorrect permissions")
            let errorImageConfig = NSImage.SymbolConfiguration(pointSize: 200, weight: .regular)
            return NSImage(systemSymbolName: "applelogo", accessibilityDescription: nil)!.withSymbolConfiguration(errorImageConfig)!
        }
        return NSImage(data: imageData as Data)!
    }

    func demoModeEnabled() -> Bool {
        let demoModeArgumentPassed = CommandLine.arguments.contains("-demo-mode")
        if demoModeArgumentPassed {
            let msg = "-demo-mode argument passed"
            uiLog.debug("\(msg, privacy: .public)")
        }
        return demoModeArgumentPassed
    }

    func exitNudge() {
        let msg = "Nudge is terminating due to condition met"
        uiLog.notice("\(msg, privacy: .public)")
        shouldExit = true
        AppKit.NSApp.terminate(nil)
    }

    func forceScreenShotIconModeEnabled() -> Bool {
        let forceScreenShotIconMode = CommandLine.arguments.contains("-force-screenshot-icon")
        if forceScreenShotIconMode {
            let msg = "-force-screenshot-icon argument passed"
            uiLog.debug("\(msg, privacy: .public)")
        }
        return forceScreenShotIconMode
    }

    func fullyUpdated() -> Bool {
        let fullyUpdated = versionGreaterThanOrEqual(currentVersion: currentOSVersion, newVersion: requiredMinimumOSVersion)
        if fullyUpdated {
            let msg = "Current operating system (\(currentOSVersion)) is greater than or equal to required operating system (\(requiredMinimumOSVersion))"
            utilsLog.notice("\(msg, privacy: .public)")
            return true
        } else {
            return false
        }
    }
    
    func getCompanyLogoPath(darkMode: Bool) -> String {
        if darkMode {
            return iconDarkPath
        } else {
            return iconLightPath
        }
    }

    func getCPUTypeInt() -> Int {
        // https://stackoverflow.com/a/63539782
        var cputype = UInt32(0)
        var size = cputype.byteWidth
        let result = sysctlbyname("hw.cputype", &cputype, &size, nil, 0)
        if result == -1 {
            if (errno == ENOENT){
                return 0
            }
            return -1
        }
        return Int(cputype)
    }

    func getCPUTypeString() -> String {
        // https://stackoverflow.com/a/63539782
        let type: Int = getCPUTypeInt()
        if type == -1 {
            return "error in CPU type"
        }

        let cpu_arch = type & 0xff // mask for architecture bits
        if cpu_arch == cpu_type_t(7){
            let msg = "CPU Type is Intel"
            utilsLog.debug("\(msg, privacy: .public)")
            return "Intel"
        }
        if cpu_arch == cpu_type_t(12){
            let msg = "CPU Type is Apple Silicon"
            utilsLog.debug("\(msg, privacy: .public)")
            return "Apple Silicon"
        }
        let msg = "Unknown CPU Type"
        utilsLog.debug("\(msg, privacy: .public)")
        return "unknown"
    }

    func getCurrentDate() -> Date {
        Date()
    }

    func getJSONUrl() -> String {
        let jsonURL = nudgeDefaults.string(forKey: "json-url") ?? "file:///Library/Preferences/com.github.macadmins.Nudge.json" // For Greg Neagle
        utilsLog.debug("JSON url: \(jsonURL, privacy: .public)")
        return jsonURL
    }

    func getInitialDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.date(from: "08-06-2020") ?? Date() // <3
    }

    func getMajorOSVersion() -> Int {
        let MajorOSVersion = ProcessInfo().operatingSystemVersion.majorVersion
        utilsLog.info("OS Version: \(MajorOSVersion, privacy: .public)")
        return MajorOSVersion
    }

    func getMajorRequiredNudgeOSVersion() -> Int {
        let parts = requiredMinimumOSVersion.split(separator: ".", omittingEmptySubsequences: false)
        let majorRequiredNudgeOSVersion = Int((parts[0]))!
        utilsLog.info("Major required OS version: \(majorRequiredNudgeOSVersion, privacy: .public)")
        return majorRequiredNudgeOSVersion
    }

    func getMinorOSVersion() -> Int {
        let MinorOSVersion = ProcessInfo().operatingSystemVersion.minorVersion
        utilsLog.info("Minor OS Version: \(MinorOSVersion, privacy: .public)")
        return MinorOSVersion
    }

    func getNudgeJSONPreferences() -> NudgePreferences? {
        let url = Utils().getJSONUrl()
        
        if url.contains("https://") || url.contains("http://") {
            if let json_url = URL(string: url) {
                if let data = try? Data(contentsOf: json_url) {
                    do {
                        let decodedData = try NudgePreferences(data: data)
                        return decodedData
                    } catch {
                        prefsJSONLog.error("\(error.localizedDescription, privacy: .public)")
                        return nil
                    }
                }
            }
        }
        
        guard let fileURL = URL(string: url) else {
            let msg = "Could not find on-disk json"
            prefsJSONLog.error("\(msg, privacy: .public)")
            return nil
        }
        
        if Utils().demoModeEnabled() {
            return nil
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let content = try Data(contentsOf: fileURL)
                let decodedData = try NudgePreferences(data: content)
                return decodedData
                
            } catch let error {
                prefsJSONLog.error("\(error.localizedDescription, privacy: .public)")
                return nil
            }
        }
        return nil
    }
    
    func getNudgeVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }

    func getNumberOfDaysBetween() -> Int {
       let currentCal = Calendar.current
       let fromDate = currentCal.startOfDay(for: getCurrentDate())
       let toDate = currentCal.startOfDay(for: requiredInstallationDate)
       let numberOfDays = currentCal.dateComponents([.day], from: fromDate, to: toDate)
       return numberOfDays.day!
    }

    func getNumberOfHoursBetween() -> Int {
        return Int(requiredInstallationDate.timeIntervalSince(getCurrentDate()) / 3600 )
    }

    func getPatchOSVersion() -> Int {
        let PatchOSVersion = ProcessInfo().operatingSystemVersion.patchVersion
        utilsLog.info("Patch OS Version: \(PatchOSVersion, privacy: .public)")
        return PatchOSVersion
    }
    
    func getScreenShotPath(darkMode: Bool) -> String {
        if darkMode {
            return screenShotDarkPath
        } else {
            return screenShotLightPath
        }
    }

    func getSerialNumber() -> String {
        if Utils().demoModeEnabled() {
                return "C00000000000"
        }
        // https://ourcodeworld.com/articles/read/1113/how-to-retrieve-the-serial-number-of-a-mac-with-swift
        var serialNumber: String? {
            let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )

            guard platformExpert > 0 else {
                return nil
            }

            guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return nil
            }

            IOObjectRelease(platformExpert)

            utilsLog.debug("Serial Number: \(serialNumber, privacy: .public)")
            return serialNumber
        }

        return serialNumber ?? ""
    }

    func getSystemConsoleUsername() -> String {
        // https://gist.github.com/joncardasis/2c46c062f8450b96bb1e571950b26bf7
        var uid: uid_t = 0
        var gid: gid_t = 0
        let SystemConsoleUsername = SCDynamicStoreCopyConsoleUser(nil, &uid, &gid) as String? ?? ""
        utilsLog.debug("System console username: \(SystemConsoleUsername, privacy: .public)")
        return SystemConsoleUsername
    }

    func getTimerController() -> Int {
        let timerCycle = getTimerControllerInt()
        utilsLog.info("Timer cycle: \(timerCycle, privacy: .public)")
        return timerCycle
    }

    func getTimerControllerInt() -> Int {
        if 0 >= getNumberOfHoursBetween() {
            return elapsedRefreshCycle
        } else if imminentWindowTime >= getNumberOfHoursBetween() {
            return imminentRefreshCycle
        } else if approachingWindowTime >= getNumberOfHoursBetween() {
            return approachingRefreshCycle
        } else {
            return initialRefreshCycle
        }
    }

    func openMoreInfo() {
        guard let url = URL(string: aboutUpdateURL) else {
            return
        }
        let msg = "User clicked moreInfo button"
        uiLog.notice("\(msg, privacy: .public)")
        NSWorkspace.shared.open(url)
    }

    func pastRequiredInstallationDate() -> Bool {
        let pastRequiredInstallationDate = getCurrentDate() > requiredInstallationDate
        utilsLog.notice("Device pastRequiredInstallationDate: \(pastRequiredInstallationDate, privacy: .public)")
        return pastRequiredInstallationDate
    }

    func requireDualQuitButtons() -> Bool {
        if singleQuitButton {
            uiLog.info("Single quit button configured")
            return false
        }
        let requireDualQuitButtons = (approachingWindowTime / 24) >= getNumberOfDaysBetween()
        uiLog.info("Device requireDualQuitButtons: \(requireDualQuitButtons, privacy: .public)")
        return requireDualQuitButtons
    }

    func requireMajorUpgrade() -> Bool {
        if requiredMinimumOSVersion == "0.0" {
            let msg = "Device requireMajorUpgrade: false"
            utilsLog.info("\(msg, privacy: .public)")
            return false
        }
        let requireMajorUpdate = versionGreaterThanOrEqual(currentVersion: currentOSVersion, newVersion: requiredMinimumOSVersion)
        utilsLog.info("Device requireMajorUpgrade: \(requireMajorUpdate, privacy: .public)")
        return requireMajorUpdate
    }

    func simpleModeEnabled() -> Bool {
        let simpleModeEnabled = CommandLine.arguments.contains("-simple-mode")
        if simpleModeEnabled {
            let msg = "-simple-mode argument passed"
            uiLog.debug("\(msg, privacy: .public)")
        }
        return simpleModeEnabled
    }

    func updateDevice(userClicked: Bool = true) {
        if userClicked {
            let msg = "User clicked updateDevice"
            uiLog.notice("\(msg, privacy: .public)")
        } else {
            let msg = "Synthetically clicked updateDevice due to allowedDeferral count"
            uiLog.notice("\(msg, privacy: .public)")
        }
        if requireMajorUpgrade() && majorUpgradeAppPathExists {
            NSWorkspace.shared.open(URL(fileURLWithPath: majorUpgradeAppPath))
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane"))
            // NSWorkspace.shared.open(URL(fileURLWithPath: "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=softwareupdateapp"))
        }
    }

    func userInitiatedExit() {
        let msg = "User clicked primaryQuitButton"
        uiLog.notice("\(msg, privacy: .public)")
        shouldExit = true
        AppKit.NSApp.terminate(nil)
    }

    func userInitiatedDeviceInfo() {
        let msg = "User clicked deviceInfo"
        uiLog.notice("\(msg, privacy: .public)")
    }

    func versionArgumentPassed() -> Bool {
        let versionArgumentPassed = CommandLine.arguments.contains("-version")
        if versionArgumentPassed {
            let msg = "-version argument passed"
            uiLog.debug("\(msg, privacy: .public)")
        }
        return versionArgumentPassed
    }

    func versionEqual(currentVersion: String, newVersion: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/25453654
        return currentVersion.compare(newVersion, options: .numeric) == .orderedSame
    }

    func versionGreaterThan(currentVersion: String, newVersion: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/25453654
        return currentVersion.compare(newVersion, options: .numeric) == .orderedDescending
    }

    func versionGreaterThanOrEqual(currentVersion: String, newVersion: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/25453654
        return currentVersion.compare(newVersion, options: .numeric) != .orderedAscending
    }

    func versionLessThan(currentVersion: String, newVersion: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/25453654
        return currentVersion.compare(newVersion, options: .numeric) == .orderedAscending
    }

    func versionLessThanOrEqual(currentVersion: String, newVersion: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/25453654
        return currentVersion.compare(newVersion, options: .numeric) != .orderedDescending
    }
}

extension FixedWidthInteger {
    // https://stackoverflow.com/a/63539782
    var byteWidth:Int {
        return self.bitWidth/UInt8.bitWidth
    }
    static var byteWidth:Int {
        return Self.bitWidth/UInt8.bitWidth
    }
}
