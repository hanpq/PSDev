> :warning: **IMPORTANT**
> This module is early in it´s development phase. Many API function and features are not yet available. You are welcome to contribute on GitHub to accelerate progress further.

# PSDev

This project has adopted the following policies [![CodeOfConduct](https://img.shields.io/badge/Code%20Of%20Conduct-gray)](https://github.com/hanpq/PSDev/blob/main/.github/CODE_OF_CONDUCT.md) [![Contributing](https://img.shields.io/badge/Contributing-gray)](https://github.com/hanpq/PSDev/blob/main/.github/CONTRIBUTING.md) [![Security](https://img.shields.io/badge/Security-gray)](https://github.com/hanpq/PSDev/blob/main/.github/SECURITY.md)

## Project status
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/hanpq/PSDev/build.yml?branch=main&label=build&logo=github)](https://github.com/hanpq/PSDev/actions/workflows/build.yml) [![Codecov](https://img.shields.io/codecov/c/github/hanpq/PSDev?logo=codecov&token=qJqWlwMAiD)](https://codecov.io/gh/hanpq/PSDev) [![Platform](https://img.shields.io/powershellgallery/p/PSDev?logo=ReasonStudios)](https://img.shields.io/powershellgallery/p/PSDev) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSDev?label=downloads)](https://www.powershellgallery.com/packages/PSDev) [![License](https://img.shields.io/github/license/hanpq/PSDev)](https://github.com/hanpq/PSDev/blob/main/LICENSE) [![docs](https://img.shields.io/badge/docs-getps.dev-blueviolet)](https://getps.dev/modules/PSDev/getstarted) [![changelog](https://img.shields.io/badge/changelog-getps.dev-blueviolet)](https://github.com/hanpq/PSDev/blob/main/CHANGELOG.md) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSDev?label=version&sort=semver) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSDev?include_prereleases&label=prerelease&sort=semver)

## About

PSDev contains a collection of utility functions. See the usage section below for a description of each tool.

## Installation

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet run the following command:

```powershell
Install-Module PSDev -Scope CurrentUser
```

## Usage

### Functions

#### Add-NumberFormater
Adds a custom ToString() method to the number variable that will print the value with magnitude notation like KB, MB for datasize and general K, M for normal numbers.

#### Convert-Object
Utility function to convert values between String,Base64,Guid,HexString,IntArray,Int,CharArray,ByteArray,ScriptBlock,SecureString,SecureStringObject,BinaryStringArray,IPAddress,ByteCollection

#### Debug-String
This is a function that can analyze a string and show hidden characters like tabs, line feed, carage return etc. This is a script originally written by Michael Klement

#### Get-Color
Prints the available base console colors, foreground and background combinations

#### Get-DotNetVersion
Checks version of the installed .NET Framework 

#### Get-Office365IPURL
This function will call the Microsoft API and retreive all urls, ips and ip-ranges that Office 365 services use.

#### Get-PublicIP
Utilizes the ipinfo.io API to resolve the public IP of the host executing the script.

#### Get-StringHash
Generates a hash of a string

#### Group-ObjectEvenly
A function that will group objects in a specific number of groups or a specific number of objects per group. This is for instance useful if you have predefined number of jobs that you want to distribute workitems for.

#### New-Password
This function generates new passwords. Default it will create short temporary passwords. Can be used to generate complex passwords with options to include/exclude character groups.

#### Resolve-IPinSubnet
Checks if a specified IP address is included in the IP range of a specific network.

#### Set-EnvironmentVariable
Utility function to set environment variables.

#### Switch-Object
Transposes an object.

#### Test-AllHashKeysAreTrue
Asserts that all keys in a hashtable is true.

#### Test-Office365IPURL
This function takes an IP address as input and searches for it within the IP-ranges defined by Microsoft. This is useful when troubleshooting connectivity issues with Office 365 where you need to verify if a blocked IP is in fact defined in the Microsoft IP ranges.

#### Test-PasswordAgainstPwnedPasswordService
Checks if the specified password is present in the pwned database. Note that the password is never sent to the pwned service instead, a hash is generated of the specified password, then the first 5 characters of the hash is sent to the pwned service which then returns all hashes begining with the 5 chars and the script then checks is the full hash is present in the hash-list returned from the service.

#### Test-PSGalleryNameAvailability
This function will simply try to resolve the specified package name and check if the name is taken. This is useful when a owner of a package unlists the packages but the package name is still allocated to that owner. Those packages will yield no return when searching for the name on PSGallery or using Find-Module. The function circumvents this by calling the package url directly. Even if the package is unlisted the package url will still be resolved. If there is no package with that name (including unlisted) a 404 message will be returned. 

#### Test-RebootPending
Checks if there is a pending reboot.
