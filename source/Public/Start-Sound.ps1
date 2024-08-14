function Start-Sound
{
    <#
    .DESCRIPTION
        Plays windows default sounds
    .PARAMETER Sound
        Defines the sound to play
    .EXAMPLE
        Start-Sound
        Plays the selected sound
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'FP, not changing any state')]
    [CmdletBinding()]
    param()
    DynamicParam
    {
        # Define base parameter attributes
        $ParameterName = 'Sound'
        $ParameterDataType = [string]
        $ParameterValidateSet = [array](Get-ChildItem HKCU:\AppEvents\Schemes\Apps\.Default | Where-Object { $_.PSChildName -ne '.Default' } | ForEach-Object { $Value = (Get-ItemProperty "$($PSITEM.PSPath)\.Current").'(Default)'; if ($Value)
                {
                    $PSItem.PSChildName
                } })

        # Create simple parameter attributes
        $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ParameterSetName = '__AllParameterSets'
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ValueFromPipeline = $false
        $ParameterAttribute.ValueFromPipelineByPropertyName = $false
        $ParameterAttribute.ValueFromRemainingArguments = $false

        # Create validateset attribute
        $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $ParameterValidateSet

        # Slä samman attribut-komponenter till collection
        $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
        $AttributeCollection.Add($AliasAttribute)

        # Define Dynamic parameter based on attribute collection
        $DynamicParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParameterName, $ParameterDataType, $AttributeCollection)

        $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add($ParameterName, $DynamicParameter)
        return $paramDictionary
    }

    BEGIN
    {

        if ($PSBoundParameters.ContainsKey('Sound'))
        {
            $SoundName = $PSBoundParameters['Sound']
        }
        else
        {
            $SoundName = 'Notification.Proximity'
        }

        $SoundPath = (Get-ItemProperty "HKCU:\AppEvents\Schemes\Apps\.Default\$($SoundName)\.Current").'(Default)'
        if ($SoundPath)
        {
            $SoundPlayer = [System.Media.SoundPlayer]::New($SoundPath)
            $SoundPlayer.Play()
            $SoundPlayer.Dispose()
        }
        else
        {
            Write-Warning -Message "Sound $($SoundName) does not have a wav file defined"
        }
    }
}
