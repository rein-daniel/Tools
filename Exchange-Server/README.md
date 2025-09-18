# Getting shared mailboxes and permissions (On-Premises Exchange)

This script is designed to generate .csv file with shared mailbox permission report for on-premises Exchange Server.

## Script Highlights: 
- The script display only **"Explicitly assigned permissions"** to mailboxes which means it will ignore "SELF" permission that each user on his mailbox and inherited permission. 
- Exports output to **CSV** file. 
- You can choose to either "export permissions of all mailboxes" or pass an input file to **get permissions of specific mailboxes** alone. 
- Allows you to filter output using your desired permissions like **Send-as, Send-on-behalf** or **Full access**. 
- This script is for **on-premises Exchange Server** environments.

## Opening Exchange Management Shell:

To run the script, you need to open Exchange Management Shell first.

Connecto to the Exchange Server via RDP:
   - Click Start
   - Find "Exchange Management Shell" in the programs list
   - Rightclick and 'Run as administrator'

## Export Shared Mailbox Permission Report Using PowerShell: 

You need to download the script and save it on the Exchange Server.

To execute the script, use the below format from the Exchange Management Shell:

```powershell
./GetSharedMailboxPermissionsOnprem.ps1
```

To filter specific permissions, use these parameters:
```powershell
./GetSharedMailboxPermissionsOnprem.ps1 -FullAccess
./GetSharedMailboxPermissionsOnprem.ps1 -SendAs
./GetSharedMailboxPermissionsOnprem.ps1 -SendOnBehalf
```

To get permissions for specific mailboxes, create a text file with mailbox names and use:
```powershell
./GetSharedMailboxPermissionsOnprem.ps1 -MBNamesFile "path\to\mailboxes.txt"
```

## Additional information:

Additional information and use cases can be found here: https://o365reports.com/2020/01/03/shared-mailbox-permission-report-to-csv/

## Known issues

Sometimes script sign error can occur preventing form executing unsigned scripts. 

<img src="https://github.com/ambersearch/Tools/assets/44996098/e9dcd605-205d-496a-b6ae-8dab1f10be3f" height="100px" />


To solve this issue you can temporary or permanently change current security policy.

To check current policy following command can be used in PowerShell **with administrative rights**. 

```powershell
Get-ExecutionPolicy -List
```

You will see something like this:
<img src="https://github.com/ambersearch/Tools/assets/44996098/226894eb-9a33-4390-a138-b42c35406374" height="200px" />

To change current execution policy:

```powershell
Set-ExecutionPolicy -Scope  LocalMachine -ExecutionPolicy bypass
```

More info: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4