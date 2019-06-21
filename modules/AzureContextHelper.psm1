class AzureContextHelper {

    AzureContextHelper() {
    }

    static [void] IsSessionLoggedIn() {
        $IsLoggedIn = $null -ne (Get-AzContext -ErrorAction SilentlyContinue).Account
        if (!$IsLoggedIn) {
            throw "You are not logged in. Run Add-AzAccount to continue"
        }
    }
}
