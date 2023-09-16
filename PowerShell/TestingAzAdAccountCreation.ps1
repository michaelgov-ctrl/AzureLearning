



#Create list of fake users

$FirstNames = (Import-Csv C:\Users\micha\Desktop\Az104Testing\FirstNames.csv).FirstName
$LastNames = (Import-Csv C:\Users\micha\Desktop\Az104Testing\LastNames.csv).LastName
$CompanyNames = (Import-Csv C:\Users\micha\Desktop\Az104Testing\Companies.csv).CompanyName

[int]$UsersToCreate = 100

$NewUserList = foreach ($i in 1..$UsersToCreate) {
    [pscustomobject]@{
        Id = $i
        FirstName = Get-Random -InputObject $FirstNames
        LastName = Get-Random -InputObject $LastNames
        Company = Get-Random -InputObject $CompanyNames
        TelephoneNumber = (Get-Random -Maximum 9999999999 -Minimum 1111111111).ToString('(###) ###-####')
    }
}




#Connect AzureAD tentant

try {
    $TenantId = ""
    Connect-AzureAD -TenantId $TenantId
} catch {$_ ; break}




#Create AzureAD Users

foreach ($SingleNewUser in $NewUserList) {
    try {
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = ((((New-Guid).Guid).split("-")[-1] -split '') + ((33..47)+(58..64)+(91..96)+(123..126) | Get-Random | % {[char]$_}) | Sort-Object {Get-Random}) -join ''
        $NewAzAdUserArgs = @{
            DisplayName = $SingleNewUser.FirstName + " " + $SingleNewUser.LastName
            PasswordProfile = $PasswordProfile
            UserPrincipalName = ($SingleNewUser.FirstName -split "")[1] + $SingleNewUser.LastName + "@michaelgovernantigmail.onmicrosoft.com"
            AccountEnabled = $true
            MailNickName = ($SingleNewUser.FirstName -split "")[1] + $SingleNewUser.LastName
        }
        New-AzureADUser @NewAzAdUserArgs
    } catch {$_}
}




# Delete created AzureAD users

Read-Host "toots"
$NewUserList | % { $DisplayName = $_.FirstName + " " + $_.LastName ; Get-AzureADUser -Filter "DisplayName eq '$DisplayName'" } | ? {$_.DisplayName -ne ""} | % { Remove-AzureADUser -ObjectId $_.ObjectID -Verbose }

<#
testing password
(((New-Guid).Guid).split("-")[-1]).substring(0,1)
#>
