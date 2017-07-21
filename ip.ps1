######################################################################
# Script pour Changer l'IP si l'on doit travailler avec BTS Site Manager
# version 1.1
# Auteur: Jeremy VERGNAUD
# Synopsis: Automatisation du changement d'IP et du lancement de BTS Site Manager et du retour en IP Dynamique
# Usage: Changer le nom de la carte réseau qui est après la variable $INTERFACE si votre carte à un autre nom. Juste lancer le script en mode 
# Administrateur afin de pouvoir changer les configurations.
# Si vous ne voulez ne plus avoir la question sur l'execution, dans un powershell elevé (en mode admin) tapez: Set-ExecutionPolicy Unrestricted
######################################################################


# Recupération Info de sécurité de l'utilisateur actuel
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Passage en mode Admin
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Vérifie si nous sommes "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # Nous sommes "as Administrator" - On change la couleur pour le montrer
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # Nous ne sommes pas "as Administrator" - on relance comme administrateur
   
   # Créer un nouvel objet qui démarre Powershell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Spécifie le chemin du script actuel et le met en paramètre
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Annonce que l'on recherche une élévation des droits
   $newProcess.Verb = "runas";
   
   # Démarrage du process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # On quitte l'ancien process non élevé
   exit
   }
 
# Votre Code ci-dessous

# Importe le module NetTCPIP
Import-Module NetTCPIP

#Change les règles d'éxacutions
#Set-ExecutionPolicy Unrestricted

Echo "Configuration de l'addresse IP selon votre machine"

$IP="192.168.255.130"
$MASK="24"
$INTERFACE="Ethernet"

#Check si l'interface est configurée pour BTS Site Manager
Get-NetIPConfiguration | findstr 192.168.255.130 | Out-Null

if ($LASTEXITCODE -eq 0)
{
    #Si l'IP pour BTS Site Manager est déjà en place, alors on switch sur le DHCP
    Echo "Passage en DHCP"
    Set-NetIPInterface -InterfaceAlias $INTERFACE -Dhcp Enabled
    Get-NetIPConfiguration $INTERFACE
}
else
{
    #Si l'IP pour BTS Site Manager est absente, alors on switch sur la configuration Manuelle
    Echo "Passage en IP Fixe"
    New-NetIPAddress -InterfaceAlias $INTERFACE -IPAddress $IP -PrefixLength $MASK
    Get-NetIPConfiguration $INTERFACE
    #Une fois la configuration faite, pour ne pas perdre de temps nous lançons BTS Site Manager
    Echo "Lancement de BTS Site Manager"
    Start-Process "c:\Program Files (x86)\Nokia Siemens Networks\Managers\BTS Site\BTS Site Manager\BTSSiteManager.bat"
}
