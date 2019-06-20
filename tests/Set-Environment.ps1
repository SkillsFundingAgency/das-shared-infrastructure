$ENV:isTest = $true
$ENV:environmentNames = "['DTA']"
$ENV:resourceEnvironmentName = "['DTA']"
$ENV:serviceName = "shared"
$ENV:threatDetectionEmailAddress = "test@test.com"
$ENV:sqlServerActiveDirectoryAdminLogin =  "test@test.com"
$ENV:keyVaultAccessObjectIds = "['fb0eac10-bda1-4410-9f8f-f4d381268d13']"
$ENV:sqlServerActiveDirectoryAdminObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
$ENV:diskEncryptionAppRegistrationObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
$ENV:backupManagementServiceObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
$ENV:gatewaySubnetCount = 1
$ENV:internalAppSubnetCount = 1
$ENV:externalAppSubnetCount = 1
$ENV:sqlAdminPasswordSeed = "test seed"


. ..\Initialize-SharedInfrastructureDeployment.ps1 -SubscriptionAbbreviation "DTA" -Verbose
