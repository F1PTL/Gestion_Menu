#!/bin/bash
#
#===================================
# Creation le 11/05/2020
# Par F1PTL Bruno
#===================================
#####################################
# Variables #
#############
Version="1.9"
REP_COURANT=`pwd`
FIC_REF="Fichiers_Ini_Ref"
FIC_REF_TAR="Fichiers_Ini_Ref.tar"
SER_OUTIL="Services_Outils"
SER_OUTIL_TAR="Services_Outils.tar"
export LANGUAGE=en_US.UTF-8
#####################################
if [ $(id -u) -ne 0 ]
        then
        echo ""
        echo "==> Lancement avec les droits root"
        exit 1
fi

cd ${REP_COURANT}
chmod 755 ./Services_Outils/*
tar -cf ./${FIC_REF_TAR} ./${FIC_REF}
tar -cf ./${SER_OUTIL_TAR} ./${SER_OUTIL}

while : ; do
OPTION=$(whiptail --title "F1PTL Gestion_Menu Version ${Version}" --menu " Votre choix ?" 20 50 11 \
1 "Installation DVSwitch Server" \
2 "Modification DVSwitch Server" \
3 "Service DVSwitch Server" \
4 "Log DVSwitch Server" \
5 "Installation Users DVSwitch Server" \
6 "Suppression Users DVSwitch Server" \
7 "Installation HBlink3 et HBmonitor" \
8 "Modification HBlink3 et HBmonitor" \
9 "Service HBlink3 et HBmonitor" \
10 "Mise a jour DVSwitch Server" \
11 "Redemarrage RaspBerryPi" 3>&1 1>&2 2>&3)
 
exitstatus=$?

if [ $exitstatus != 0 ]; then
    echo "==> vous avez annule"; break;
fi

case $OPTION in
1) ${REP_COURANT}/Installation_DVSwitch.sh ;;
2) ${REP_COURANT}/Modification_DVSwitch.sh ;;
3) ${REP_COURANT}/Service_DVSwitch.sh ;;
4) ${REP_COURANT}/Log_DVSwitch.sh ;;
5) ${REP_COURANT}/Installation_Users_DVSwitch.sh ;;
6) ${REP_COURANT}/Suppression_Users_DVSwitch.sh ;;
7) ${REP_COURANT}/Installation_HB.sh ;;
8) ${REP_COURANT}/Modification_HB.sh ;;
9) ${REP_COURANT}/Service_HBlink3.sh ;;
10) ${REP_COURANT}/Upgrade_DVSwitch.sh ;;
11) if (whiptail --title " Redemarrage RaspBerryPI  Oui / Non" --yesno "Redemarrage du RaspBerryPI ?" 11 60) then
	echo "Demarrage en cours ..." ; reboot
	else
	echo "==> vous avez annule"; exit 1
   fi ;;

esac
done
exit 0
