#!/bin/sh
#
#===================================
# Creation le 30/12/2019
# Par F1PTL Bruno
#===================================
#####################################
# Variables #
#############
Version="1.0"
REP_COURANT=`pwd`
FIC_REF="Fichiers_Ini_Ref"
FIC_REF_TAR="Fichiers_Ini_Ref_V1.3.tar"
SER_OUTIL="Services_Outils"
SER_OUTIL_TAR="Services_Outils_V1.3.tar"
#####################################
if [ $(id -u) -ne 0 ]
        then
        echo ""
        echo "==> Lancement avec les droits root"
        exit 1
fi

if (whiptail --title "F1PTL MENU Installation Users DVSwitch Version ${Version}" --yesno "Renseigner les informations demandees afin de mettre a jour tous les fichers d initialisations. Autorisation sur le DMR et le C4FM (YSF).\n\n      Indicatif, ID-DMR, ID-NXDN, port USRP..." 10 78); then
    	echo "==> vous avez valider votre choix"
	else
    	echo "==> vous avez annule"; exit 1
fi


INDICATIF=$(whiptail --title "Input" --inputbox "Quel est l indicatif ?" 8 60 FXXXX 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

IDDMR7=$(whiptail --title "Input" --inputbox "Quel est l ID-DMR 7 digits ?" 8 60 208XXXX 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

IDDMR9=$(whiptail --title "Input" --inputbox "Quel est l ID-DMR 9 digits ? \n (Modifier les 2 derniers digits)" 8 60 ${IDDMR7}01 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

IDNXDN=$(whiptail --title "Input" --inputbox "Quel est l ID-NXDN ? \n (Pas d ID-NXDN prendre 9999)" 8 60 9999 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

USRP=$(whiptail --title "Input" --inputbox "Quel est le port USRP ? \n (Valeur a positionner dans votre SmartPhone)" 8 60 51234 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

VALEUR="20"
VALEUR_TXG=`ps -edf | awk '/md380-emu \-S 242/ {print $11}' | cut -c3-4 | tail -1`
VALEUR=`expr ${VALEUR_TXG} + 1`

TXG=$(whiptail --title "Input" --inputbox "Quel est le numero d installation ? \n (Selectionner entre 20 et 29),\n\n Le numero conseille est le : ${VALEUR}" 10 60 ${VALEUR} 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

MASTER_IP_BM=$(whiptail --title "Choix du Master DMR" --radiolist \
"Cocher la case qui correspond a votre choix" 15 60 4 \
"213.222.29.197" "BM_Netherlands_2042" ON \
"217.182.129.131" "BM_France_2082" OFF \
"158.69.203.89" "BM_Canada_3021" OFF \
"109.15.57.11" "HBlink Srv Yvelines" OFF 3>&1 1>&2 2>&3)

if [ ${MASTER_IP_BM} = "109.15.57.11" ]; then
	PORT_HB=$(whiptail --title "Choix du Serveur HBlink" --radiolist \
	"Choisir en fonction du port disponible sur le serveur HBlink" 15 60 6 \
	"55570" "Port 55570" ON \
	"55571" "Port 55571" OFF \
	"55572" "Port 55572" OFF \
	"55573" "Port 55573" OFF \
	"55574" "Port 55574" OFF \
	"55575" "Port 55575" OFF 3>&1 1>&2 2>&3)
fi
 
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "==> vous avez annule"; exit 1
fi

if [ -d "${REP_COURANT}/${FIC_REF}_${INDICATIF}" ]
        then
        echo ""
	echo "ATTENTION :"
	echo "==========="
        echo ""
        echo "==> Le repertoire Fichiers_Ini_Ref_${INDICATIF} existe !"
        echo "==> Impossible de poursuivre l installation."
        echo ""
        exit 1
fi

for file in ${REP_COURANT}/${FIC_REF}/*_indicatif
do
  sed -i -e "s/indicatif/${INDICATIF}/g" "$file"
  sed -i -e "s/iddmr7/${IDDMR7}/g" "$file"
  sed -i -e "s/iddmr9/${IDDMR9}/g" "$file"
  sed -i -e "s/idnxdn/${IDNXDN}/g" "$file"
  sed -i -e "s/usrp_port/${USRP}/g" "$file"
  sed -i -e "s/master_ip_bm/${MASTER_IP_BM}/g" "$file"
  if [ ${MASTER_IP_BM} = "109.15.57.11" ]; then
        sed -i -e "s/Port=62031/Port=${PORT_HB}/g" "$file"
        sed -i -e "s/Password=passw0rd/Password=PASSWORD/g" "$file"
  fi
  sed -i -e "s/TXG/${TXG}/g" "$file"
  mv $file `echo $file | sed "/_indicatif/ s//_${INDICATIF}.ini/"`
done

for file in ${REP_COURANT}/${SER_OUTIL}/*.indicatif
do
  sed -i -e "s/indicatif/${INDICATIF}/g" "$file"
  sed -i -e "s/TXG/${TXG}/g" "$file"
  mv $file `echo $file | sed "/.indicatif/ s//_${INDICATIF}.service/"`
done

mv ${REP_COURANT}/${FIC_REF} ${REP_COURANT}/${FIC_REF}_${INDICATIF}
tar xf ${REP_COURANT}/${FIC_REF_TAR}
sleep 2
mv ${REP_COURANT}/${SER_OUTIL} ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}
tar xf ${REP_COURANT}/${SER_OUTIL_TAR}


clear
echo "==================================================================="
echo "==> Mise en place de ${INDICATIF} sur votre DVSwitch Server <=="
echo "==================================================================="
sleep 3

if [ ! -d "${REP_COURANT}/${SER_OUTIL}_${INDICATIF}" ]
	then
	echo ""
	echo "==> Le repertoire Fichiers_Ini_Ref_${INDICATIF} n existe pas !"
	exit 1
fi

echo "#######################"
echo "==> Depot des logiciels"
echo "#######################"
cd /depot/G4KLX
git clone https://github.com/g4klx/P25Clients.git
git clone https://github.com/g4klx/YSFClients.git
git clone https://github.com/g4klx/NXDNClients.git

cd /depot/DVSwitch
git clone https://github.com/DVSwitch/MMDVM_Bridge.git
git clone https://github.com/DVSwitch/Analog_Bridge.git

echo ""
echo "###########################################"
echo "==> Deplacement des logiciels dans /usr/src"
echo "###########################################"
cd /depot/G4KLX/NXDNClients
cp -rf NXDNGateway NXDNParrot /usr/src
echo "cp -rf NXDNGateway NXDNParrot /usr/src"
rm -rf /depot/G4KLX/NXDNClients

cd /depot/G4KLX/P25Clients
cp -rf P25Gateway P25Parrot /usr/src
echo "cp -rf P25Gateway P25Parrot /usr/src"
rm -rf /depot/G4KLX/P25Clients

cd /depot/G4KLX/YSFClients
cp -rf YSFGateway YSFParrot /usr/src
echo "cp -rf YSFGateway YSFParrot /usr/src"
rm -rf /depot/G4KLX/YSFClients

cd /depot/DVSwitch
cp -rf MMDVM_Bridge /usr/src
echo "cp -rf MMDVM_Bridge /usr/src"
rm -rf /depot/DVSwitch/MMDVM_Bridge

cd /depot/DVSwitch
cp -rf Analog_Bridge /usr/src
echo "cp -rf Analog_Bridge /usr/src"
rm -rf /depot/DVSwitch/Analog_Bridge


echo ""
echo "######################################################"
echo "==> Compilation des logiciels et deplacement dans /opt"
echo "######################################################"
cd /usr/src/NXDNGateway
make clean
make
[ -d /opt/NXDNGateway_${INDICATIF} ] && rm -rf /opt/NXDNGateway_${INDICATIF}
mkdir -p /opt/NXDNGateway_${INDICATIF}
cp NXDNGateway /opt/NXDNGateway_${INDICATIF}
cp -rf Audio /opt/NXDNGateway_${INDICATIF}
cp NXDNGateway.ini /opt/NXDNGateway_${INDICATIF}

cd /usr/src/NXDNParrot
make clean
make
[ -d /opt/NXDNParrot_${INDICATIF} ] && rm -rf /opt/NXDNParrot_${INDICATIF}
mkdir -p /opt/NXDNParrot_${INDICATIF}
cp NXDNParrot /opt/NXDNParrot_${INDICATIF}

cd /usr/src/P25Gateway
make clean
make
[ -d /opt/P25Gateway_${INDICATIF} ] && rm -rf /opt/P25Gateway_${INDICATIF}
mkdir -p /opt/P25Gateway_${INDICATIF}
cp -rf P25Gateway /opt/P25Gateway_${INDICATIF}
cp -rf Audio /opt/P25Gateway_${INDICATIF}
cp P25Gateway.ini /opt/P25Gateway_${INDICATIF}

cd /usr/src/P25Parrot
make clean
make
[ -d /opt/P25Parrot_${INDICATIF} ] && rm -rf /opt/P25Parrot_${INDICATIF}
mkdir -p /opt/P25Parrot_${INDICATIF}
cp -rf P25Parrot /opt/P25Parrot_${INDICATIF}

cd /usr/src/YSFGateway
make clean
make
[ -d /opt/YSFGateway_${INDICATIF} ] && rm -rf /opt/YSFGateway_${INDICATIF}
mkdir -p /opt/YSFGateway_${INDICATIF}
cp -rf YSFGateway /opt/YSFGateway_${INDICATIF}
cp YSFGateway.ini /opt/YSFGateway_${INDICATIF}

cd /usr/src/YSFParrot
make clean
make
[ -d /opt/YSFParrot_${INDICATIF} ] && rm -rf /opt/YSFParrot_${INDICATIF}
mkdir -p /opt/YSFParrot_${INDICATIF}
cp -rf YSFParrot /opt/YSFParrot_${INDICATIF}

cd /opt
[ -d /opt/md380-emu_${INDICATIF} ] && rm -rf /opt/md380-emu_${INDICATIF}
cp -rf /opt/md380-emu /opt/md380-emu_${INDICATIF}

echo ""
echo "#############################################"
echo "==> Copie des binaires MMDVM et Analog_Bridge"
echo "#############################################"
cd /usr/src/MMDVM_Bridge/bin
PROC=`uname -m`
case ${PROC} in
	armv7l) cp -rf MMDVM_Bridge.armhf ../MMDVM_Bridge
		chmod 755 /usr/src/MMDVM_Bridge/MMDVM_Bridge ;;
			
	x86_64) cp -rf MMDVM_Bridge.amd64 ../MMDVM_Bridge
		chmod 755 /usr/src/MMDVM_Bridge/MMDVM_Bridge ;;
			
	     *) echo "Modele de serveur non pris en charge"
		exit 1 ;;
esac

[ -d /opt/MMDVM_Bridge_${INDICATIF} ] && rm -rf /opt/MMDVM_Bridge_${INDICATIF}
cp -rf /usr/src/MMDVM_Bridge /opt/MMDVM_Bridge_${INDICATIF}
echo "cp -rf /usr/src/MMDVM_Bridge /opt/MMDVM_Bridge_${INDICATIF}"


cd /usr/src/Analog_Bridge/bin
PROC=`uname -m`
case ${PROC} in
	armv7l) cp -rf Analog_Bridge.armhf ../Analog_Bridge
		chmod 755 /usr/src/Analog_Bridge/Analog_Bridge ;;
			
	x86_64) cp -rf Analog_Bridge.amd64 ../Analog_Bridge
		chmod 755 /usr/src/Analog_Bridge/Analog_Bridge ;;
			
	     *) echo "Modele de serveur non pris en charge"
		exit 1 ;;
esac

[ -d /opt/Analog_Bridge_${INDICATIF} ] && rm -rf /opt/Analog_Bridge_${INDICATIF}
cp -rf /usr/src/Analog_Bridge /opt/Analog_Bridge_${INDICATIF}
echo "cp -rf /usr/src/Analog_Bridge /opt/Analog_Bridge_${INDICATIF}"


echo ""
echo "#####################################"
echo "==> Mise en place des services outils"
echo "#####################################"

cd ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}
cp md380-emu_${INDICATIF}.service /lib/systemd/system
cp mmdvm_bridge_${INDICATIF}.service /lib/systemd/system
cp analog_bridge_${INDICATIF}.service /lib/systemd/system
sleep 1
systemctl daemon-reload
cd $REP_COURANT/${SER_OUTIL}_${INDICATIF}
systemctl enable md380-emu_${INDICATIF}.service
systemctl enable mmdvm_bridge_${INDICATIF}.service
systemctl enable analog_bridge_${INDICATIF}.service

cd $REP_COURANT
cp -rf ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}/dvs*.sh /opt/Analog_Bridge_${INDICATIF}
echo "cp -rf ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}/dvs*.sh /opt/Analog_Bridge_${INDICATIF}"

cp -rf ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}/dvswitch_${INDICATIF}.service /opt/Analog_Bridge_${INDICATIF}/dvswitch.sh
echo "cp -rf ${REP_COURANT}/${SER_OUTIL}_${INDICATIF}/dvswitch_${INDICATIF}.service /opt/Analog_Bridge_${INDICATIF}/dvswitch.sh"


echo ""
echo "###########################################"
echo "==> Copie des fichiers .ini de ${INDICATIF}"
echo "###########################################"
cd $REP_COURANT
cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/Analog_Bridge_${INDICATIF}.ini /opt/Analog_Bridge_${INDICATIF}/Analog_Bridge.ini
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/Analog_Bridge_${INDICATIF}.ini /opt/Analog_Bridge_${INDICATIF}/Analog_Bridge.ini"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/dvsm.macro_${INDICATIF}.ini /opt/Analog_Bridge_${INDICATIF}/dvsm.macro
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/dvsm.macro_${INDICATIF}.ini /opt/Analog_Bridge_${INDICATIF}/dvsm.macro"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/DVSwitch_${INDICATIF}.ini /opt/MMDVM_Bridge_${INDICATIF}/DVSwitch.ini
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/DVSwitch_${INDICATIF}.ini /opt/MMDVM_Bridge_${INDICATIF}/DVSwitch.ini"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/MMDVM_Bridge_${INDICATIF}.ini /opt/MMDVM_Bridge_${INDICATIF}/MMDVM_Bridge.ini
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/MMDVM_Bridge_${INDICATIF}.ini /opt/MMDVM_Bridge_${INDICATIF}/MMDVM_Bridge.ini"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/NXDNGateway.ini /opt/NXDNGateway_${INDICATIF}
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/NXDNGateway.ini /opt/NXDNGateway_${INDICATIF}"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/P25Gateway.ini /opt/P25Gateway_${INDICATIF}
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/P25Gateway.ini /opt/P25Gateway_${INDICATIF}"

cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/YSFGateway.ini /opt/YSFGateway_${INDICATIF}
echo "cp -rf ${REP_COURANT}/${FIC_REF}_${INDICATIF}/YSFGateway.ini /opt/YSFGateway_${INDICATIF}"


echo ""
echo ""
echo "===================================================="
echo " L indicatif est installe sur votre RaspBerry PI"
echo "         Fichiers_Ini_Ref_${INDICATIF}"
echo "       Redemarrage de votre RaspBerry PI"
echo "===================================================="

echo ""
echo "########################################"
echo "==>        Fin d installation        <=="
echo "==> Appuyer sur Enter pour continuer <=="
echo "########################################"
read x
