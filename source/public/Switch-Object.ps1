function Switch-Object {
    <#
    .DESCRIPTION
       Transposes an object, foreach parameter an object is created
    .PARAMETER InputObject
       Defined the object to transpose
    .EXAMPLE
       Get-Process | Select-object -first 1 | Switch-object
       Description
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]$InputObject
    )
    PROCESS {
        $InputObject | ForEach-Object {
            $instance = $_
            $instance.PSObject.Properties.Name | ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_
                    Value = $instance.$_
                }
            }
        }
    }
}
