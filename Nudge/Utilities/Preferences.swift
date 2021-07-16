//
//  Preferences.swift
//  Nudge
//
//  Created by Erik Gomez on 2/18/21.
//

import Foundation

let nudgeJSONPreferences = Utils().getNudgeJSONPreferences()
let nudgeDefaults = UserDefaults.standard
let language = NSLocale.current.languageCode!
var shouldExit = false

// Get the language
func getDesiredLanguage() -> String {
    var desiredLanguage = language
    if forceFallbackLanguage {
        desiredLanguage = fallbackLanguage
    }
    return desiredLanguage
}

// optionalFeatures
// Even if profile/JSON is installed, return nil if in demo-mode
func getOptionalFeaturesProfile() -> [String:Any]? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let optionalFeatures = nudgeDefaults.dictionary(forKey: "optionalFeatures") {
        return optionalFeatures
    } else {
        let msg = "profile optionalFeatures key is empty"
        prefsProfileLog.info("\(msg, privacy: .public)")
    }
    return nil
}

func getOptionalFeaturesJSON() -> OptionalFeatures? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let optionalFeatures = nudgeJSONPreferences?.optionalFeatures {
        return optionalFeatures
    } else {
        let msg = "json optionalFeatures key is empty"
        prefsJSONLog.info("\(msg, privacy: .public)")
    }
    return nil
}

// osVersionRequirements
// Mutate the profile into our required construct and then compare currentOS against targetedOSVersions
// Even if profile/JSON is installed, return nil if in demo-mode
func getOSVersionRequirementsProfile() -> OSVersionRequirement? {
    if Utils().demoModeEnabled() {
        return nil
    }
    var requirements = [OSVersionRequirement]()
    if let osRequirements = nudgeDefaults.array(forKey: "osVersionRequirements") as? [[String:AnyObject]] {
        for item in osRequirements {
            requirements.append(OSVersionRequirement(fromDictionary: item))
        }
    }
    if !requirements.isEmpty {
        if requirements.count >= 2 {
            let v1ErrorMsg = "Multiple hashes may result in undefined behavior. Please deploy a single hash for OS enforcement at this time."
            prefsProfileLog.error("\(v1ErrorMsg, privacy: .public)")
        }
        for (_ , subPreferences) in requirements.enumerated() {
            if subPreferences.targetedOSVersions?.contains(currentOSVersion) == true || Utils().versionGreaterThanOrEqual(currentVersion: currentOSVersion, newVersion: subPreferences.requiredMinimumOSVersion ?? "0.0")  {
                return subPreferences
            }
        }
    } else {
        let msg = "profile osVersionRequirements key is empty"
        prefsProfileLog.info("\(msg, privacy: .public)")
    }
    return nil
}
// Loop through JSON osVersionRequirements preferences and then compare currentOS against targetedOSVersions
func getOSVersionRequirementsJSON() -> OSVersionRequirement? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let requirements = nudgeJSONPreferences?.osVersionRequirements {
        if requirements.count >= 2 {
            let v1ErrorMsg = "Multiple hashes may result in undefined behavior. Please deploy a single hash for OS enforcement at this time."
            prefsJSONLog.error("\(v1ErrorMsg, privacy: .public)")
        }
        for (_ , subPreferences) in requirements.enumerated() {
            if subPreferences.targetedOSVersions?.contains(currentOSVersion) == true || Utils().versionGreaterThanOrEqual(currentVersion: currentOSVersion, newVersion: subPreferences.requiredMinimumOSVersion ?? "0.0") {
                return subPreferences
            }
        }
    } else {
        let msg = "json osVersionRequirements key is empty"
        prefsJSONLog.info("\(msg, privacy: .public)")
    }
    return nil
}

// Compare current language against the available updateURLs
func getAboutUpdateURL(OSVerReq: OSVersionRequirement?) -> String? {
    if Utils().demoModeEnabled() {
        return "https://support.apple.com/en-us/HT201541"
    }
    if let update = OSVerReq?.aboutUpdateURL {
        return update
    }
    if let updates = OSVerReq?.aboutUpdateURLs {
        for (_, subUpdates) in updates.enumerated() {
            if subUpdates.language == getDesiredLanguage() {
                return subUpdates.aboutUpdateURL ?? ""
            }
        }
    }
    return nil
}

// userExperience
// Even if profile/JSON is installed, return nil if in demo-mode
func getUserExperienceProfile() -> [String:Any]? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let userExperience = nudgeDefaults.dictionary(forKey: "userExperience") {
        return userExperience
    } else {
        let msg = "profile userExperience key is empty"
        prefsProfileLog.info("\(msg, privacy: .public)")
    }
    return nil
}

func getUserExperienceJSON() -> UserExperience? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let userExperience = nudgeJSONPreferences?.userExperience {
        return userExperience
    } else {
        let msg = "json userExperience key is empty"
        prefsJSONLog.info("\(msg, privacy: .public)")
    }
    return nil
}


// userInterface
// Even if profile/JSON is installed, return nil if in demo-mode
func getUserInterfaceProfile() -> [String:Any]? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let userInterface = nudgeDefaults.dictionary(forKey: "userInterface") {
        return userInterface
    } else {
        let msg = "profile userInterface key is empty"
        prefsProfileLog.info("\(msg, privacy: .public)")
    }
    return nil
}

func getUserInterfaceJSON() -> UserInterface? {
    if Utils().demoModeEnabled() {
        return nil
    }
    if let userInterface = nudgeJSONPreferences?.userInterface {
        return userInterface
    } else {
        let msg = "json userInterface key is empty"
        prefsJSONLog.info("\(msg, privacy: .public)")
    }
    return nil
}

func forceScreenShotIconMode() -> Bool {
    if Utils().forceScreenShotIconModeEnabled() {
        return true
    } else {
        return userInterfaceProfile?["forceScreenShotIcon"] as? Bool ?? nudgeJSONPreferences?.userInterface?.forceScreenShotIcon ?? false
    }
}

func simpleMode() -> Bool {
    if Utils().simpleModeEnabled() {
        return true
    } else {
        return userInterfaceProfile?["simpleMode"] as? Bool ?? nudgeJSONPreferences?.userInterface?.simpleMode ?? false
    }
}

// Mutate the profile into our required construct
// Even if profile/JSON is installed, return nil if in demo-mode
func getUserInterfaceUpdateElementsProfile() -> [String:AnyObject]? {
    if Utils().demoModeEnabled() {
        return nil
    }
    let updateElements = userInterfaceProfile?["updateElements"] as? [[String:AnyObject]]
    if updateElements != nil {
        for (_ , subPreferences) in updateElements!.enumerated() {
            if subPreferences["_language"] as? String == getDesiredLanguage() {
                return subPreferences
            }
        }
    } else {
        let msg = "profile updateElements key is empty"
        prefsProfileLog.info("\(msg, privacy: .public)")
    }
    return nil
}

// Loop through JSON userInterface -> updateElements preferences and then compare language
func getUserInterfaceUpdateElementsJSON() -> UpdateElement? {
    if Utils().demoModeEnabled() {
        return nil
    }
    let updateElements = getUserInterfaceJSON()?.updateElements
    if updateElements != nil {
        for (_ , subPreferences) in updateElements!.enumerated() {
            if subPreferences.language == getDesiredLanguage() {
                return subPreferences
            }
        }
    } else {
        let msg = "json updateElements key is empty"
        prefsJSONLog.info("\(msg, privacy: .public)")
    }
    return nil
}

// Returns the mainHeader
func getMainHeader() -> String {
    if Utils().demoModeEnabled() {
        return "Your device requires a security update (Demo Mode)".localized(desiredLanguage: getDesiredLanguage())
    } else {
        return userInterfaceUpdateElementsProfile?["mainHeader"] as? String ?? getUserInterfaceUpdateElementsJSON()?.mainHeader ?? "Your device requires a security update".localized(desiredLanguage: getDesiredLanguage())
    }
}
