Hi,
This is my custom modification of the PSAppDeployToolkit, which is used for daily packaging tasks.

What was changed:
1. The template has been minimized:
   - the "Deploy-Application.ex"e file has been replaced with the "install.cmd" and "uninstall.cmd" files
   - Banners and Logos were removed
   - the "Files" folder has been renamed to "Source"
   - the "SupportFiles" folder has been removed
   - added "Help.cmd" in the "AppDeployToolkit" folder to start the help console if the powershell is blocked
   - The "Repair" section has been removed.

3. Language set to English.
4. Set the msi parameters according to the global standards.
   ALLUSERS=1 ARPNOREMOVE=1 ARPNOMODIFY=1 ARPNOREPAIR=1 ReinstallModeText=oms MSIDISABLERMRESTART=0 MSIRMSHUTDOWN=2
   MSIRESTARTMANAGERCONTROL=0 ISCHECKFORPRODUCTUPDATES=0 REBOOT=ReallySuppress /QN
5. Toast notifications are disabled.
6. Log path set to "${Env:ProgramData}\InstalledSoftwarePackages\LOGS".
7. Added the creation of a package detection key in 'HKLM:\SOFTWARE\InstalledSoftwarePackages' during package installation and its removal during uninstallation.
8. Updated examples in the Help console.
9. The "Show-InstallationWelcome" function automatically displays a message about installation or uninstallation based on the deployment type.
10. Added AppLogo.ico to set the SCCM Application Icon
