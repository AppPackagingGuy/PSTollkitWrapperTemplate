[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall')]
    [String]$DeploymentType = 'Uninstall',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $true,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    }
    Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
	[String]$requestNumber = ''
	[String]$appVendor = ''
	[String]$appName = ''
	[String]$appVersion = ''
	[String]$appBit = '' # x86 / x64
	[String]$appLanguage = 'English'
	[String]$appGUID = ''
	[String]$appInstaller = ''
	[String]$releaseNumber = 'R01'
	[String]$buildNumber = 'B01'
	[String]$targetPlatform = '' # Win10 / Win11
	[String]$processes2Kill = ''
	[String]$appScriptDate = 'DD.MM.YYYY'
	[String]$packageAuthor = ''
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.9.3'
    [String]$deployAppScriptDate = '02/05/2023'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters
    [String]$appVendorD = $appVendor -replace '\s',''
	[String]$appNameD = $appName -replace '\s',''
	[String]$appVersionD = $appVersion -replace '\s',''
    [String]$installDateD = Get-Date -Format "dd MMM yyyy HH:mm:ss"
    [String]$packageVersion = $appVersionD + ' ' + $releaseNumber + ' ' + $buildNumber
	[String]$detectionRegKey = "HKLM:\SOFTWARE\InstalledSoftwarePackages\$appVendor $appName $appBit"

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }
	
	## Disable baloon messages
	[boolean]$configShowBalloonNotifications = $false

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ieq 'Install') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close defined processes if required and persist the prompt (Close Apps Countdown is equal 15 min)
        If($processes2Kill){Show-InstallationWelcome -CloseApps $processes2Kill -CloseAppsCountdown 900 -PersistPrompt}

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>

        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'
				
		## <Perform Installation tasks here>

        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>

    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close defined processes if required and persist the prompt (Close Apps Countdown is equal 15 min)
        If($processes2Kill){Show-InstallationWelcome -CloseApps $processes2Kill -CloseAppsCountdown 900 -PersistPrompt}

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>

        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        ## <Perform Uninstallation tasks here>

        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>

    }

    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================
	
	## PACKAGE DETECTION KEY
	If ((($mainExitCode -eq 0) -or ($mainExitCode -eq 3010) -or ($mainExitCode -eq 1641)) -and ($deploymentType -eq 'Install'))
	{
		Set-RegistryKey -Key $detectionRegKey -Name "appBit" -Value $appBit
        Set-RegistryKey -Key $detectionRegKey -Name "appName" -Value $appName
        Set-RegistryKey -Key $detectionRegKey -Name "appVendor" -Value $appVendor
        Set-RegistryKey -Key $detectionRegKey -Name "appVersion" -Value $appVersion
        Set-RegistryKey -Key $detectionRegKey -Name "packageVersion" -Value $packageVersion
        Set-RegistryKey -Key $detectionRegKey -Name "installDate" -Value $installDateD
	}
	elseif ((($mainExitCode -eq 0) -or ($mainExitCode -eq 3010) -or ($mainExitCode -eq 1641)) -and ($deploymentType -eq 'Uninstall'))
	{
		$getPackageVersion = Get-RegistryKey -Key $detectionRegKey -Value 'packageVersion'
        if($getPackageVersion -eq $packageVersion){Remove-RegistryKey -Key $detectionRegKey}
	}
    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}