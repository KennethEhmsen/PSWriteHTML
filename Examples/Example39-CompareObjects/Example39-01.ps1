﻿Import-Module $PSScriptRoot\..\..\PSWriteHTML.psd1 -Force

$Users1 = Get-ADUser -Filter * | Select-Object -First 15 SamAccountName, GivenName, Name, UserPrincipalName, Enabled, ObjectClass, DistinguishedName, SID
$Users2 = Get-ADUser -Filter * | Select-Object -Last 300 SamAccountName, GivenName, Name, UserPrincipalName, Enabled, ObjectClass, DistinguishedName, SID
#$Users3 = Get-ADUser -Filter * | Select-Object -First 2 SamAccountName, GivenName, Name, UserPrincipalName, Enabled, ObjectClass, DistinguishedName, SID
$Users2[0].Enabled = $false
$Users2[0].GivenName = 'test'
$Users2[3].SamAccountName = 'test'
$Users2[4].UserPrincipalName = 'ole@ole.pl'
$Users2[0].UserPrincipalName = 'Oops@nope.pl'
$Users2[5].UserPrincipalName = 'Oops@nope.pl'

$Higlights = Compare-HTMLTable -Objects $Users1,$Users2 -MatchingProperty 'DistinguishedName' -standard

#$Higlights = Compare-HTMLTable -Objects $Process1,$Process2 -MatchingProperty 'ID' -standard


return

New-HTML {
    $Higlights = Compare-HTMLTable -Objects @($Users1, $Users2) -MatchingProperty 'DistinguishedName'
    New-HTMLTable -DataTable $Users1
    New-HTMLTable -DataTable $Users2 {
        $Higlights[0]
    }
    New-HTMLTable -DataTable $Users3 {
        $Higlights[1]
    }
} -Online -ShowHTML -FilePath $Env:USERPROFILE\Desktop\Test.html