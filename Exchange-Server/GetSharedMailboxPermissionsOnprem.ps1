<#
=============================================================================================
Name:           Get Shared Mailbox Permission Report (On-Prem Exchange)
=============================================================================================

Script Highlights: 
~~~~~~~~~~~~~~~~~~

1.The script display only "Explicitly assigned permissions" to mailboxes which means it will ignore "SELF" permission that each user on his mailbox and inherited permission. 
2.Exports output to CSV file. 
3.You can choose to either "export permissions of all mailboxes" or pass an input file to get permissions of specific mailboxes alone. 
4.Allows you to filter output using your desired permissions like Send-as, Send-on-behalf or Full access. 
5.This script is for on-premises Exchange Server environments.

=============================================================================================
#>

param(
    [switch]$FullAccess,
    [switch]$SendAs,
    [switch]$SendOnBehalf,
    [string]$MBNamesFile
)

# Output CSV path
$ExportCSV = "SharedMBOnpremPermissionReport_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"

function Print_Output
{
 #Print Output
 if($Print -eq 1)
 {
  $Result = @{'Display Name'=$DisplayName;'User PrinciPal Name'=$UPN;'Primary SMTP Address'=$PrimarySMTP;'Access Type'=$AccessType;'User With Access'=$userwithAccess;'Email Aliases'=$EmailAlias}
  $Results = New-Object PSObject -Property $Result
  $Results |select-object 'Display Name','User PrinciPal Name','Primary SMTP Address','Access Type','User With Access','Email Aliases' | Export-Csv -Path $ExportCSV -Notype -Append
 }
}

function Get_MBPermission {
    param ($Mailbox)

    $DisplayName = $Mailbox.DisplayName
    $UPN = $Mailbox.UserPrincipalName
    $PrimarySMTP = $Mailbox.PrimarySmtpAddress
    $EmailAliases = ($Mailbox.EmailAddresses | Where-Object { $_ -like "smtp:*" }) -join ","

    # FullAccess
    if (($FullAccess -or !$FullAccess.IsPresent -and !$SendAs.IsPresent -and !$SendOnBehalf.IsPresent)) {
        $Permissions = Get-MailboxPermission -Identity $Mailbox.Identity | Where-Object {
            $_.AccessRights -contains "FullAccess" -and !$_.IsInherited -and $_.User -notlike "NT AUTHORITY*" -and $_.User -notlike "S-1-5-21*"
        }
        if([string]$Permissions -ne "")
  {
   $Print=1
   $UserWithAccess=""
   $AccessType="FullAccess"
   foreach ($FullAccessPermission in $Permissions) {
        $User = Get-Recipient -Identity $FullAccessPermission.user
        $Email = $User.PrimarySmtpAddress.Address

    if ($UserWithAccess -ne "") { $UserWithAccess = $UserWithAccess + "," }
    $UserWithAccess = $UserWithAccess + $Email
}
   Print_Output
  }
    }

    # SendAs
    if (($SendAs -or !$FullAccess.IsPresent -and !$SendOnBehalf.IsPresent)) {
        $Permissions = Get-ADPermission -Identity $Mailbox.Identity | Where-Object {
            $_.ExtendedRights -contains "Send As" -and !$_.IsInherited -and $_.User -notlike "NT AUTHORITY*" -and $_.User -notlike "S-1-5-21*"
        }
        if([string]$Permissions -ne "")
  {
   $Print=1
   $UserWithAccess=""
   $AccessType="SendAs"
   foreach ($SendAsPermission in $Permissions) {
        $User = Get-Recipient -Identity $SendAsPermission.user
        $Email = $User.PrimarySmtpAddress.Address

    if ($UserWithAccess -ne "") { $UserWithAccess = $UserWithAccess + "," }
    $UserWithAccess = $UserWithAccess + $Email
}
   Print_Output
  }
    }

    # SendOnBehalf
    if (($SendOnBehalf -or !$SendAs.IsPresent -and !$FullAccess.IsPresent)) {
        $Delegates = $Mailbox.GrantSendOnBehalfTo
       if([string]$Delegates -ne "")
  {
   $Print=1
   $UserWithAccess=""
   $AccessType="SendOnBehalf"
foreach ($SendOnBehalfPermissionDN in $Delegates) {
        $User = Get-Recipient -Identity $SendOnBehalfPermissionDN.user
        $Email = $User.PrimarySmtpAddress.Address

    if ($UserWithAccess -ne "") { $UserWithAccess = $UserWithAccess + "," }
    $UserWithAccess = $UserWithAccess + $Email
}

   Print_Output
  }
    }
}

# Collect mailboxes
if ($MBNamesFile) {
    $Mailboxes = Get-Content $MBNamesFile | ForEach-Object {
        Get-Mailbox -Identity $_
    }
} else {
    $Mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox
}

foreach ($mb in $Mailboxes) {
    Get_MBPermission -Mailbox $mb
}

Write-Host "`nPermissions exported to: $ExportCSV" -ForegroundColor Green