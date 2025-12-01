//
//  Version.swift
//  LearnCHANGELOG
//
//  Created by west on 30/11/25.
import Foundation

/// Application version information
public enum AppVersion {
    /// The current version of the application
    /// This value is automatically updated by release-please
    public static let current = "0.1.0" // x-release-please-version
    
    /// The build number
    public static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Full version string (e.g., "1.0.0 (1)")
    public static var fullVersion: String {
        "\(current) (\(build))"
    }
    
    /// Marketing version from Info.plist
    public static var marketingVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? current
    }
}
