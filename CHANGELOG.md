# Changelog for PSDev

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Get-DotNetVersion: Updated versions to include values for 4.8.1

## [1.1.0] - 2022-12-25

### Added

- Added function Convert-Object
- Added function Get-Color
- Added function Get-DotNetVersion
- Added function Get-PublicIP
- Added function Get-StringHash
- Added function Group-ObjectEvenly
- Added function New-Password
- Added function Resolve-IPinSubnet
- Added function Set-EnvironmentVariable
- Added function Switch-Object
- Added function Test-AllHashKeysAreTrue
- Added function Test-RebootPending
- Added function Test-PasswordAgainstPwnedPasswordService

### Fixed

- Fix: Convert-Object: Changed securestring to string length evaulation. Length is different on windows and unix based systems so a fixed length value can not be evaluated.
- Fix: Test-PasswordAgainstPwnedPasswordService: Splitting response array on carrage return and linefeed only works on windows. On unix only a linefeed is used and string is not splitted correctly.

## [1.0.3] - 2022-12-22

### Fixed

- Fixed an issue in build pipeline that caused web docs to not update.

## [1.0.1] - 2022-12-22

### Added

- Added function Test-PSGalleryNameAvailability
- Added function Test-Office365IPURL
- Added function Get-Office365IPURL
- Added function Debug-String
- Added function Add-NumberFormater

### Fixed

- Removed debug-string tests because of incompatibility with Windows Powershell. New tests should be created.
