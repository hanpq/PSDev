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

#### Debug-String
This is a function that can analyze a string and show hidden characters like tabs, line feed, carage return etc. This is a script originally written by Michael Klement

#### Get-Office365IPURL
This function will call the Microsoft API and retreive all urls, ips and ip-ranges that Office 365 services use.

#### Test-Office365IPURL
This function takes an IP address as input and searches for it within the IP-ranges defined by Microsoft. This is useful when troubleshooting connectivity issues with Office 365 where you need to verify if a blocked IP is in fact defined in the Microsoft IP ranges.

#### Test-PSGalleryNameAvailability
This function will simply try to resolve the specified package name and check if the name is taken. This is useful when a owner of a package unlists the packages but the package name is still allocated to that owner. Those packages will yield no return when searching for the name on PSGallery or using Find-Module. The function circumvents this by calling the package url directly. Even if the package is unlisted the package url will still be resolved. If there is no package with that name (including unlisted) a 404 message will be returned. 
