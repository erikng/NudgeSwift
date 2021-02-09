//
//  Nudge.swift
//  Nudge
//
//  Created by Erik Gomez on 2/2/21.
//

import Foundation
import SwiftUI

// Prefs
let nudgePreferences = nudgePrefs().loadNudgePrefs()

let minimumOSVersion = osUtils().getRequiredMinimumOSVersion()!
let minimumMajorOSVersion = "11"

let currentOSVersion = osUtils().getOSVersion()
let currentMajorOSVersion = String(osUtils().getMajorOSVersion())
let majorUpgradeAppPath = osUtils().getMajorUpgradeAppPath()!

// TODO: Move this to Groob's new stuff
let nudgeRefreshCycle = Double((nudgePreferences!.userExperience.nudgeRefreshCycle))
let allowedDeferrals = nudgePreferences!.optionalFeatures.allowedDeferrals

// Setup Variables for light icon
let iconLightPath = nudgePreferences!.optionalFeatures.iconLightPath
let iconLightImage = createImageData(fileImagePath: iconLightPath)

// Setup Variables for dark icon
let iconDarkPath = nudgePreferences!.optionalFeatures.iconDarkPath
let iconDarkImage = createImageData(fileImagePath: iconDarkPath)

// Setup Variables for company screenshot
let screenShotPath = nudgePreferences!.optionalFeatures.screenShotPath
let screenShotImage = createImageData(fileImagePath: screenShotPath)

// More Info URL
let informationButtonPath = nudgePreferences!.optionalFeatures.informationButtonPath

// Get the default filemanager
let fileManager = FileManager.default

// Primary Nudge UI
struct Nudge: View {
    // Get the color scheme so we can dynamically change properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject var manager: PolicyManager


    // Get the screen frame
    var screen = NSScreen.main?.visibleFrame

    // State variables
    @State var systemConsoleUsername = osUtils().getSystemConsoleUsername()
    @State var serialNumber = osUtils().getSerialNumber()
    @State var cpuType = osUtils().getCPUTypeString()
    @State var daysRemaining = osUtils().numberOfDaysBetween()
    @State var requireDualCloseButtons = osUtils().requireDualCloseButtons()
    @State var pastRequiredInstallationDate = osUtils().pastRequiredInstallationDate()
    @State var hasAcceptedIUnderstand = false
    @State var deferralCount = 0
    
    // Modal view for screenshot
    @State var showSSDetail = false
    
    let timer = Timer.publish(every: nudgeRefreshCycle, on: .main, in: .common).autoconnect()

    // Nudge UI
    var body: some View {
        HStack(spacing: 0){
            // Left side of Nudge
            VStack{
                // Company Logo
                if colorScheme == .dark {
                    if fileManager.fileExists(atPath: iconDarkPath) {
                        Image(nsImage: iconDarkImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128)
                    } else {
                        Image(systemName: "applelogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128)
                            .padding(.bottom, 10.0)
                    }
                } else {
                    if fileManager.fileExists(atPath: iconLightPath) {
                        Image(nsImage: iconLightImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128)
                    } else {
                        Image(systemName: "applelogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128, height: 128)
                            .padding(.bottom, 10.0)
                    }
                }

                // Horizontal line
                HStack{
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                }
                .frame(width:215)
                
                // Can only have 10 objects per stack unless you hack it and use groups
                Group {
                    // Required OS Version
                    HStack{
                        Text("Required OS Version: ")
                            .fontWeight(.bold)
                        Spacer()
                        Text(minimumOSVersion.description)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }.padding(.vertical, 1.0)
                    
                    // Current OS Version
                    HStack{
                        Text("Current OS Version: ")
                        Spacer()
                        Text(manager.current.description)
                            .foregroundColor(.gray)
                    }.padding(.vertical, 1.0)
                    
                    // Username
                    HStack{
                        Text("Username: ")
                        Spacer()
                        Text(self.systemConsoleUsername)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 1.0)

                    // Serial Number
                    HStack{
                        Text("Serial Number: ")
                        Spacer()
                        Text(self.serialNumber)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 1.0)

                    // Architecture
                    HStack{
                        Text("Architecture: ")
                        Spacer()
                        Text(self.cpuType)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 1.0)

                    // Fully Updated
//                    HStack{
//                        Text("Fully Updated: ")
//                        Spacer()
//                        Text(String(fullyUpdated()).capitalized)
//                            .foregroundColor(.gray)
//                    }.padding(.vertical, 1.0)

                    // Days Remaining
                    HStack{
                        Text("Days Remaining: ")
                        Spacer()
                        if self.daysRemaining <= 0 {
                            Text(String(0))
                                .foregroundColor(.gray)
                        } else {
                            Text(String(self.daysRemaining))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 1.0)

                    // Deferral Count
                    HStack{
                        Text("Deferral Count: ")
                        Spacer()
                        Text(String(self.deferralCount))
                            .onReceive(timer) { _ in
                                if needToActivateNudge(deferralCount: self.deferralCount) {
                                    self.deferralCount += 1
                                }
                            }
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20.0)

                // Force buttons to the bottom with a spacer
                Spacer()

                // More Info
                // https://developer.apple.com/documentation/swiftui/openurlaction
                HStack(alignment: .top) {
                    if informationButtonPath != "" {
                        Button(action: moreInfo, label: {
                            Text("More Info")
                          }
                        )
                    }
                    // Force the button to the left with a spacer
                    Spacer()
                }
            }
            .padding(.bottom, 7.5)
            .padding(.leading, -20.0)
            .frame(width: 300, height: 450)
            
            // Vertical Line
            VStack{
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1)
            }
            .frame(height: 300)

            // Right side of Nudge
            VStack{
                // mainHeader Text
                HStack{
                    Text(nudgePreferences!.userInterface.updateElements.mainHeader)
                        .font(.largeTitle)
                }
                .padding(.top, 5.0)
                .padding(.leading, 15.0)

                // subHeader Text
                HStack{
                    Text(nudgePreferences!.userInterface.updateElements.subHeader)
                        .font(.body)
                }
                .padding(.vertical, 0.5)
                .padding(.leading, 15.0)

                // mainContent Header
                HStack{
                    Text(nudgePreferences!.userInterface.updateElements.mainContentHeader)
                        .font(.body)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 0.5)
                .padding(.leading, 15.0)

                VStack(alignment: .leading) {
                    // mainContent Text
                    Text(nudgePreferences!.userInterface.updateElements.mainContentText)
                        .font(.body)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 5.0)

                // Company Screenshot
                    HStack{
                        Spacer()
                        Group{
                            if fileManager.fileExists(atPath: screenShotPath) {
                                Image(nsImage: screenShotImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                    .frame(width: 128, height: 128)
                            } else {
                                Image("CompanyScreenshotIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                    .frame(width: 128, height: 128)
                            }
                            Button(action: {
                                self.showSSDetail.toggle()
                            }) {
                                Image(systemName: "plus.magnifyingglass")
                            }
                            .padding(.leading, -15.0)
                            .sheet(isPresented: $showSSDetail) {
                                screenShotZoom()
                            }
                            .help("Click to zoom into screenshot")
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 1.0)
                .padding(.leading, 15.0)
                .frame(width: 520)

                // Force buttons to the bottom with a spacer
                Spacer()
                VStack(alignment: .leading) {
                    // lowerHeader Text
                    Text(nudgePreferences!.userInterface.updateElements.lowerHeader)
                        .font(.body)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // lowerSubHeader Text
                    Text(nudgePreferences!.userInterface.updateElements.lowerSubHeader)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 15.0)
                .frame(width: 520)

                // Bottom buttons
                HStack(alignment: .top){
                    // Update Device button
                    Button(action: manager.update, label: {
                        Text("Update Device")
                      }
                    )
                    
                    // Separate the buttons with a spacer
                    Spacer()
                    
                    if !pastRequiredInstallationDate && allowedDeferrals > self.deferralCount {
                        // I understand button
                        if requireDualCloseButtons {
                            if self.hasAcceptedIUnderstand {
                                Button(action: {}, label: {
                                    Text("I understand")
                                  }
                                )
                                .hidden()
                                .padding(.trailing, 10.0)
                            } else {
                                Button(action: {
                                    hasAcceptedIUnderstand = true
                                }, label: {
                                    Text("I understand")
                                  }
                                )
                                .padding(.trailing, 10.0)
                            }
                        } else {
                            Button(action: {}, label: {
                                Text("I understand")
                              }
                            )
                            .hidden()
                            .padding(.trailing, 10.0)
                        }
                    
                        // OK button
                        if requireDualCloseButtons {
                            if self.hasAcceptedIUnderstand {
                                Button(action: {AppKit.NSApp.terminate(nil)}, label: {
                                    Text("OK")
                                        .frame(minWidth: 35.0)
                                  }
                                )
                            } else {
                                Button(action: {
                                    hasAcceptedIUnderstand = true
                                }, label: {
                                    Text("OK")
                                        .frame(minWidth: 35.0)
                                  }
                                )
                                .hidden()
                            }
                        } else {
                            Button(action: {AppKit.NSApp.terminate(nil)}, label: {
                                Text("OK")
                                    .frame(minWidth: 35.0)
                              }
                            )
                        }
                    }
                }
                .padding(.leading, 25.0)
                .padding(.trailing, -20.0)
            }
            .frame(width: 550, height: 450)
            .padding(.bottom, 15.0)
            // https://www.hackingwithswift.com/books/ios-swiftui/running-code-when-our-app-launches
            .onAppear(perform: nudgeStartLogic)
        }
    }

    func moreInfo() {
        let url_info = informationButtonPath
        guard let url = URL(string: url_info) else {
            return
        }
        print(url)
        openURL(url)
    }
}

// Sheet view for Screenshot zoom
struct screenShotZoom: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {self.presentationMode.wrappedValue.dismiss()}, label: {
            if fileManager.fileExists(atPath: screenShotPath) {
                Image(nsImage: screenShotImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 512, height: 512)
            } else {
                Image("CompanyScreenshotIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 512, height: 512)
            }
          }
        )
        .buttonStyle(PlainButtonStyle())
        .help("Click to close")
    }
}


#if DEBUG
// Xcode preview for both light and dark mode
struct Nudge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Nudge().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.1") ))
                .preferredColorScheme(.light)
            Nudge().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.1") ))
                .preferredColorScheme(.dark)
            Nudge().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.1") ))
                .preferredColorScheme(.dark)
                .environment(\.locale, .init(identifier: "fr"))
        }
    }
}
#endif

// Functions
func fullyUpdated() -> Bool {
    return osUtils().versionGreaterThanOrEqual(current_version: currentOSVersion, new_version: "11.2")
}

func requireMajorUpgrade() -> Bool {
    return osUtils().versionGreaterThanOrEqual(current_version: currentMajorOSVersion, new_version: "11.2")
}

// Start doing a basic check
func nudgeStartLogic() {
    if fullyUpdated() {
        // Because Nudge will bail if it detects installed OS >= required OS, this will cause the Xcode preview to fail.
        // https://zacwhite.com/2020/detecting-swiftui-previews/
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        } else {
            AppKit.NSApp.terminate(nil)
        }
    }
}

func createImageData(fileImagePath: String) -> NSImage {
    let urlPath = NSURL(fileURLWithPath: fileImagePath)
    let imageData:NSData = NSData(contentsOf: urlPath as URL)!
    return NSImage(data: imageData as Data)!
}


func updateDevice() {
    if requireMajorUpgrade() {
        NSWorkspace.shared.open(URL(fileURLWithPath: majorUpgradeAppPath))
    } else {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane"))
//        NSWorkspace.shared.open(URL(fileURLWithPath: "x-apple.systempreferences:com.apple.preferences.softwareupdate?client=softwareupdateapp"))
    }
}


extension PolicyManager {
    
    func update() {
        let status = try! evaluateStatus() // TODO: errors
        switch status {
        case .noUpdateRequired: break
        case .minorUpdate:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/SoftwareUpdate.prefPane"))
        case let .majorUpgrade(major):
            NSWorkspace.shared.open(URL(fileURLWithPath: major.majorUpgradeAppPath))
        }
    }
    
}

func needToActivateNudge(deferralCount: Int) -> Bool {
    let currentlyActive = NSApplication.shared.isActive
    let frontmostApplication = NSWorkspace.shared.frontmostApplication
    let acceptableApps = [
        "com.apple.loginwindow",
        "com.apple.systempreferences"
    ]
    
    // Don't nudge if major upgrade is frontmostApplication
    if NSURL.fileURL(withPath: majorUpgradeAppPath) == frontmostApplication?.bundleURL {
        print("Upgrade app is currently frontmostApplication")
        return false
    }
    
    // Don't nudge if acceptable apps are frontmostApplication
    if acceptableApps.contains((frontmostApplication?.bundleIdentifier!)!) {
        print("An acceptable app is currently frontmostApplication")
        return false
    }
    
    // If we get here, Nudge if not frontmostApplication
    if !currentlyActive {
        // TODO: this needs to be rethought out. It's one integer behind
        _ = deferralCount + 1
        activateNudge()
        if deferralCount > allowedDeferrals  {
            print("Nudge deferral count over threshold")
            updateDevice()
        }
        return true
    }
    return false
}

func activateNudge() {
    print("Re-activating Nudge")
    NSApp.activate(ignoringOtherApps: true)
}
