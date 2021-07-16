//
//  DefaultPreferencesNudge.swift
//  Nudge
//
//  Created by Erik Gomez on 2/8/21.
//

import Foundation

// Globals
let currentOSVersion = OSVersion(ProcessInfo().operatingSystemVersion).description

// optionalFeatures
let optionalFeaturesProfile = getOptionalFeaturesProfile()
let optionalFeaturesJSON = getOptionalFeaturesJSON()
let asyncronousSoftwareUpdate = optionalFeaturesProfile?["asyncronousSoftwareUpdate"] as? Bool ?? optionalFeaturesJSON?.asyncronousSoftwareUpdate ?? true
let attemptToFetchMajorUpgrade = optionalFeaturesProfile?["attemptToFetchMajorUpgrade"] as? Bool ?? optionalFeaturesJSON?.attemptToFetchMajorUpgrade ?? false
let enforceMinorUpdates = optionalFeaturesProfile?["enforceMinorUpdates"] as? Bool ?? optionalFeaturesJSON?.enforceMinorUpdates ?? true

// osVersionRequirements
let osVersionRequirementsProfile = getOSVersionRequirementsProfile()
let osVersionRequirementsJSON = getOSVersionRequirementsJSON()
let majorUpgradeAppPath = osVersionRequirementsProfile?.majorUpgradeAppPath ?? osVersionRequirementsJSON?.majorUpgradeAppPath ?? ""
let majorUpgradeAppPathExists = FileManager.default.fileExists(atPath: majorUpgradeAppPath)
let requiredInstallationDate = osVersionRequirementsProfile?.requiredInstallationDate ?? osVersionRequirementsJSON?.requiredInstallationDate ?? Date(timeIntervalSince1970: 0)
let requiredMinimumOSVersion = osVersionRequirementsProfile?.requiredMinimumOSVersion ?? osVersionRequirementsJSON?.requiredMinimumOSVersion ?? "0.0"
let aboutUpdateURL = getAboutUpdateURL(OSVerReq: osVersionRequirementsProfile) ?? getAboutUpdateURL(OSVerReq: osVersionRequirementsJSON) ?? ""

// userExperience
let userExperienceProfile = getUserExperienceProfile()
let userExperienceJSON = getUserExperienceJSON()
let allowedDeferrals = userExperienceProfile?["allowedDeferrals"] as? Int ?? userExperienceJSON?.allowedDeferrals ?? 1000000
let allowedDeferralsUntilForcedSecondaryQuitButton = userExperienceProfile?["allowedDeferralsUntilForcedSecondaryQuitButton"] as? Int ?? userExperienceJSON?.allowedDeferralsUntilForcedSecondaryQuitButton ?? 14
let approachingRefreshCycle = userExperienceProfile?["approachingRefreshCycle"] as? Int ?? userExperienceJSON?.approachingRefreshCycle ?? 6000
let approachingWindowTime = userExperienceProfile?["approachingWindowTime"] as? Int ?? userExperienceJSON?.approachingWindowTime ?? 72
let elapsedRefreshCycle = userExperienceProfile?["elapsedRefreshCycle"] as? Int ?? userExperienceJSON?.elapsedRefreshCycle ?? 300
let imminentRefreshCycle = userExperienceProfile?["imminentRefreshCycle"] as? Int ?? userExperienceJSON?.imminentRefreshCycle ?? 600
let imminentWindowTime = userExperienceProfile?["imminentWindowTime"] as? Int ?? userExperienceJSON?.imminentWindowTime ?? 24
let initialRefreshCycle = userExperienceProfile?["initialRefreshCycle"] as? Int ?? userExperienceJSON?.initialRefreshCycle ?? 18000
let maxRandomDelayInSeconds = userExperienceProfile?["maxRandomDelayInSeconds"] as? Int ?? userExperienceJSON?.maxRandomDelayInSeconds ?? 1200
let noTimers = userExperienceProfile?["noTimers"] as? Bool ?? userExperienceJSON?.noTimers ?? false
let nudgeRefreshCycle = userExperienceProfile?["nudgeRefreshCycle"] as? Int ?? userExperienceJSON?.nudgeRefreshCycle ?? 60
let randomDelay = userExperienceProfile?["randomDelay"] as? Bool ?? userExperienceJSON?.randomDelay ?? false

// userInterface
let userInterfaceProfile = getUserInterfaceProfile()
let userInterfaceJSON = getUserInterfaceJSON()
let userInterfaceUpdateElementsProfile = getUserInterfaceUpdateElementsProfile()
let userInterfaceUpdateElementsJSON = getUserInterfaceUpdateElementsJSON()
let fallbackLanguage = userInterfaceProfile?["fallbackLanguage"] as? String ?? userInterfaceJSON?.fallbackLanguage ?? "en"
let forceFallbackLanguage = userInterfaceProfile?["forceFallbackLanguage"] as? Bool ?? userInterfaceJSON?.forceFallbackLanguage ?? false
let iconDarkPath = userInterfaceProfile?["iconDarkPath"] as? String ?? userInterfaceJSON?.iconDarkPath ?? ""
let iconLightPath = userInterfaceProfile?["iconLightPath"] as? String ?? userInterfaceJSON?.iconLightPath ?? ""
let screenShotDarkPath = userInterfaceProfile?["screenShotDarkPath"] as? String ?? userInterfaceJSON?.screenShotDarkPath ?? ""
let screenShotLightPath = userInterfaceProfile?["screenShotLightPath"] as? String ?? userInterfaceJSON?.screenShotLightPath ?? ""
let actionButtonText = userInterfaceUpdateElementsProfile?["actionButtonText"] as? String ?? userInterfaceUpdateElementsJSON?.actionButtonText ?? "Update Device".localized(desiredLanguage: getDesiredLanguage())
let informationButtonText = userInterfaceUpdateElementsProfile?["informationButtonText"] as? String ?? userInterfaceUpdateElementsJSON?.informationButtonText ?? "More Info".localized(desiredLanguage: getDesiredLanguage())
let mainContentHeader = userInterfaceUpdateElementsProfile?["mainContentHeader"] as? String ?? userInterfaceUpdateElementsJSON?.mainContentHeader ?? "Your device will restart during this update".localized(desiredLanguage: getDesiredLanguage())
let mainContentNote = userInterfaceUpdateElementsProfile?["mainContentNote"] as? String ?? userInterfaceUpdateElementsJSON?.mainContentNote ?? "Important Notes".localized(desiredLanguage: getDesiredLanguage())
let mainContentSubHeader = userInterfaceUpdateElementsProfile?["mainContentSubHeader"] as? String ?? userInterfaceUpdateElementsJSON?.mainContentSubHeader ?? "Updates can take around 30 minutes to complete".localized(desiredLanguage: getDesiredLanguage())
let mainContentText = userInterfaceUpdateElementsProfile?["mainContentText"] as? String ?? userInterfaceUpdateElementsJSON?.mainContentText ?? "A fully up-to-date device is required to ensure that IT can accurately protect your device.\n\nIf you do not update your device, you may lose access to some items necessary for your day-to-day tasks.\n\nTo begin the update, simply click on the Update Device button and follow the provided steps.".localized(desiredLanguage: getDesiredLanguage())
let primaryQuitButtonText = userInterfaceUpdateElementsProfile?["primaryQuitButtonText"] as? String ?? userInterfaceUpdateElementsJSON?.primaryQuitButtonText ?? "Later".localized(desiredLanguage: getDesiredLanguage())
let secondaryQuitButtonText = userInterfaceUpdateElementsProfile?["secondaryQuitButtonText"] as? String ?? userInterfaceUpdateElementsJSON?.secondaryQuitButtonText ?? "I understand".localized(desiredLanguage: getDesiredLanguage())
let showDeferralCount = userInterfaceProfile?["showDeferralCount"] as? Bool ?? userInterfaceJSON?.showDeferralCount ?? true
let singleQuitButton = userInterfaceProfile?["singleQuitButton"] as? Bool ?? userInterfaceJSON?.singleQuitButton ?? false
let subHeader = userInterfaceUpdateElementsProfile?["subHeader"] as? String ?? userInterfaceUpdateElementsJSON?.subHeader ?? "A friendly reminder from your local IT team".localized(desiredLanguage: getDesiredLanguage())

// Other important defaults
let acceptableApps = [
    "com.apple.loginwindow",
    "com.apple.systempreferences"
]
