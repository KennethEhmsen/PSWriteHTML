Function New-HTMLSection {
    [alias('New-HTMLContent', 'Section')]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0)][ValidateNotNull()][ScriptBlock] $Content = $(Throw "Open curly brace"),
        [alias('Name', 'Title')][Parameter(Mandatory = $false)][string]$HeaderText,
        [alias('TextColor')][string]$HeaderTextColor = "White",
        [alias('TextAlignment')][string][ValidateSet('center', 'left', 'right', 'justify')] $HeaderTextAlignment = 'center',
        [alias('TextBackGroundColor')][string]$HeaderBackGroundColor = "DeepSkyBlue",
        [alias('BackgroundShade')][string]$BackgroundColor = "",
        [alias('Collapsable')][Parameter(Mandatory = $false)][switch] $CanCollapse,
        [Parameter(Mandatory = $false)][switch] $IsHidden,
        [switch] $Collapsed,
        [int] $Height,
        [switch] $Invisible,
        # Following are based on https://css-tricks.com/snippets/css/a-guide-to-flexbox/
        [string][ValidateSet('wrap', 'nowrap', 'wrap-reverse')] $Wrap,
        [string][ValidateSet('row', 'row-reverse', 'column', 'column-reverse')] $Direction,
        [string][ValidateSet('flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'stretch')] $AlignContent,
        [string][ValidateSet('stretch', 'flex-start', 'flex-end', 'center', 'baseline')] $AlignItems,
        [string][ValidateSet('flex-start', 'flex-end', 'center')] $JustifyContent,

        [System.Collections.IDictionary] $StyleSheetsConfiguration
    )
    # This is so we can support external CSS configuration
    if (-not $StyleSheetsConfiguration) {
        $StyleSheetsConfiguration = [ordered] @{
            Section     = 'defaultSection'
            SectionText = 'defaultSectionText'
        }
    }
    $RandomNumber = Get-Random
    $TextHeaderColorFromRGB = ConvertFrom-Color -Color $HeaderTextColor
    $HiddenDivStyle = [ordered] @{ }

    if ($CanCollapse) {
        $Script:HTMLSchema.Features.HideSection = $true
        if ($IsHidden) {
            $ShowStyle = "color: $TextHeaderColorFromRGB;" # shows Show button
            $HideStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Hide button
        } else {
            if ($Collapsed) {
                $HideStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Show button
                $ShowStyle = "color: $TextHeaderColorFromRGB;" # shows Hide button
                $HiddenDivStyle['display'] = 'none'
            } else {
                $ShowStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Show button
                $HideStyle = "color: $TextHeaderColorFromRGB;" # shows Hide button
            }
        }
    } else {
        if ($IsHidden) {
            $ShowStyle = "color: $TextHeaderColorFromRGB;" # shows Show button
            $HideStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Hide button
        } else {
            $ShowStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Show button
            $HideStyle = "color: $TextHeaderColorFromRGB; display:none;" # hides Show button
        }
    }
    if ($IsHidden) {
        $DivContentStyle = @{
            "display"          = 'none'
            "background-color" = ConvertFrom-Color -Color $BackgroundColor
        }
    } else {
        $DivContentStyle = @{
            "background-color" = ConvertFrom-Color -Color $BackgroundColor
        }
    }

    $HiddenDivStyle['height'] = if ($Height -ne 0) { "$($Height)px" } else { '' }

    if ($Wrap -or $Direction) {
        [string] $ClassName = "flexParent$(Get-RandomStringName -Size 8 -LettersOnly)"
        $Attributes = @{
            'display'        = 'flex'
            'flex-wrap'      = if ($Wrap) { $Wrap } else { }
            'flex-direction' = if ($Direction) { $Direction } else { }
            'align-content'  = if ($AlignContent) { $AlignContent } else { }
            'align-items'    = if ($AlignItems) { $AlignItems } else { }
        }
        $Css = ConvertTo-LimitedCSS -ClassName $ClassName -Attributes $Attributes

        $Script:HTMLSchema.CustomHeaderCSS.Add($Css)
    } else {
        [string] $ClassName = 'flexParent flexElement overflowHidden'
    }

    $DivHeaderStyle = @{
        "text-align"       = $HeaderTextAlignment
        "background-color" = ConvertFrom-Color -Color $HeaderBackGroundColor
    }
    $HeaderStyle = "color: $TextHeaderColorFromRGB;"
    if ($Invisible) {
        New-HTMLTag -Tag 'div' -Attributes @{ class = $ClassName } -Value {
            New-HTMLTag -Tag 'div' -Attributes @{ class = $ClassName; Style = @{ 'justify-content' = $JustifyContent } } -Value {
                $Object = Invoke-Command -ScriptBlock $Content
                if ($null -ne $Object) {
                    $Object
                }
            }
        }
    } else {
        New-HTMLTag -Tag 'div' -Attributes @{ class = "$($StyleSheetsConfiguration.Section) roundedCorners overflowHidden"; style = $DivContentStyle } -Value {
            New-HTMLTag -Tag 'div' -Attributes @{ class = "defaultHeader"; style = $DivHeaderStyle } -Value {
                New-HTMLTag -Tag 'div' -Attributes @{ class = $($StyleSheetsConfiguration.SectionText) } {
                    New-HTMLAnchor -Name $HeaderText -Text "$HeaderText " -Style $HeaderStyle
                }
                New-HTMLAnchor -Id "show_$RandomNumber" -Href 'javascript:void(0)' -OnClick "show('$RandomNumber');" -Style $ShowStyle -Text '(Show)'
                New-HTMLAnchor -Id "hide_$RandomNumber" -Href 'javascript:void(0)' -OnClick "hide('$RandomNumber');" -Style $HideStyle -Text '(Hide)'
            }
            New-HTMLTag -Tag 'div' -Attributes @{ class = $ClassName; id = $RandomNumber; Style = $HiddenDivStyle } -Value {
                New-HTMLTag -Tag 'div' -Attributes @{ class = "$ClassName collapsable"; id = $RandomNumber; Style = @{'justify-content' = $JustifyContent } } -Value {
                    $Object = Invoke-Command -ScriptBlock $Content
                    if ($null -ne $Object) {
                        $Object
                    }
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName HeaderTextColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName HeaderBackGroundColor -ScriptBlock $Script:ScriptBlockColors
Register-ArgumentCompleter -CommandName New-HTMLSection -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors
