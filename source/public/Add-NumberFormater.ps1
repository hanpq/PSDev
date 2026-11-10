function Add-NumberFormater {
    <#
    .DESCRIPTION
        Adding formater capabilities by overwriting the ToString method of the input double value
    .PARAMETER InputObject
        Defines the input value to process
    .PARAMETER Type
        Defines what type of value it is and what units to use. Available values is Standard and DataSize
    .EXAMPLE
        Add-NumberFormater -InputObject 2138476234 -Type DataSize
        Processes the number 2138476234 and returns the value with the replaced ToString() method. This case would return "1,99 GB"
    #>

    [CmdletBinding()] # Enabled to support verbose
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Parameter use is not correctly identified by PSScriptAnalyzer')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][Alias('Double', 'Number')][double[]]$InputObject,
        [ValidateSet('DataSize', 'Standard')][string]$Type = 'Standard'
    )

    begin {
        $Configuration = @{
            DataSize = @{
                Base  = 1024
                Units = @('', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
            }
            Standard = @{
                Base  = 1000
                Units = @('', 'K', 'MN', 'MD', 'BN', 'BD', 'TN', 'TD')
            }
        }
    }

    process {
        $InputObject | foreach-object {
            $CurrentNumber = $_
            $TempCopyOfCurrentNumber = $CurrentNumber

            if ($TempCopyOfCurrentNumber -lt $Configuration.($Type).Base) {
                $DisplayString = "'{0:N}'" -f [double]($TempCopyOfCurrentNumber)
            } else {
                $i = 0
                while ($TempCopyOfCurrentNumber -ge $Configuration.($Type).Base -and $i -lt $Configuration.($Type).Units.Length - 1 ) {
                    $TempCopyOfCurrentNumber /= $Configuration.($Type).Base
                    $i++
                }
                $DisplayString = "'{0:N2} {1}'" -f [double]($TempCopyOfCurrentNumber), ($Configuration.($Type).Units[$i])
            }

            $NewObject = $CurrentNumber | Add-Member -MemberType ScriptMethod -Name ToString -Value ([Scriptblock]::Create($DisplayString)) -Force -PassThru
            return $NewObject
        }
    }
    end { }
}
