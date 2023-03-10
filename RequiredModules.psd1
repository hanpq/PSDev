@{
    PSDependOptions              = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                  = 'latest'
    PSScriptAnalyzer             = 'latest'
    Pester                       = 'latest'
    Plaster                      = 'latest'
    ModuleBuilder                = 'latest'
    ChangelogManagement          = 'latest'
    Sampler                      = 'latest'
    'Sampler.GitHubTasks'        = 'latest'
    Encoding                     = 'latest'
    PlatyPS                      = 'latest'
    'Alt3.Docusaurus.Powershell' = 'latest'
    'PowershellGet'              = @{
        Name           = 'PowershellGet'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository      = 'PSGallery'
            AllowPrerelease = $true
        }
        Version        = '3.0.18-beta18'
    }
    'indented.net.ip'            = 'latest'

}
