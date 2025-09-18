# Background

Microsoft offers no REST API for accessing the access rights of shared mailboxes, which means that it is impossible to know which users are allowed to access shared mailboxes through Microsoft Graph API. However, there is a way to introduce this data to amberSearch, enabling all amberSearch users to search through shared mailboxes easily.

We have published a PowerShell script that establishes a connection with on-premises Exchange Servers and retrieves the mappings between the shared mailboxes and the users who have access to them. You can find it here: https://github.com/ambersearch/Tools/tree/main/Office365/Exchange-Server

## Requirements
- You should have administrator access to your on-premises Exchange Server
- The script needs to be run directly on the Exchange Server
- Exchange Management Shell must be run as administrator

## Output
The PowerShell script generates a .csv file containing all shared mailbox permissions. Please send this file to the amberSearch team to enable shared mailbox search functionality in your amberSearch instance. 