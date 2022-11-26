##PowerShell Deployment
1. az login
2. az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
3. az group create --name ProjectName --location australiaeast
4. az deployment group create --resource-group Orion --template-file main.bicep --parameters file main.parameters.json

