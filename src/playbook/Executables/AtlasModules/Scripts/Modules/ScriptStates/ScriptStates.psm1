function Add-ScriptEntry {
    param (
        [string]$scriptId, # ID for the script
        [string]$scriptPath, # Path to the script
        [string]$state # State of script, string to support scripts with various states
    )

    $regPath = "HKLM:\SOFTWARE\AtlasOS\$scriptId"

    # Create registry key if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the script path, state, and last updated time
    Set-ItemProperty -Path $regPath -Name "path" -Value $scriptPath
    Set-ItemProperty -Path $regPath -Name "state" -Value $state.ToString()
    Set-ItemProperty -Path $regPath -Name "lastUpdated" -Value (Get-Date).ToString()
}

function Update-ScriptState {
    param (
        [string]$scriptId,
        [string]$newState,
        [string]$scriptPath = $null # Path should be provided if you want to create a new entry if it doesn't exist
    )

    $regPath = "HKLM:\SOFTWARE\AtlasOS\$scriptId"

    if (Test-Path $regPath) {
        # Update the state and last updated time
        Set-ItemProperty -Path $regPath -Name "state" -Value $newState.ToString()
        Set-ItemProperty -Path $regPath -Name "lastUpdated" -Value (Get-Date).ToString()
    } else {
        # Create a new entry if it doesn't exist
        if ($scriptPath -eq $null) {
            Write-Error "Cannot update state for '$scriptId': script path is required for new entries."
            return
        }
        Add-ScriptEntry -scriptId $scriptId -scriptPath $scriptPath -state $newState
    }
}

function Get-ScriptState {
    param (
        [string]$scriptId
    )

    $regPath = "HKLM:\SOFTWARE\AtlasOS\$scriptId"

    if (Test-Path $regPath) {
        return (Get-ItemProperty -Path $regPath).state
    } else {
        Write-Error "Script ID '$scriptId' does not exist."
        return $null
    }
}
