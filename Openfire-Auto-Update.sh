#!/bin/bash

#	Script de atualização do sistema openfire					      
#	Autor: cleiton Carvalho								  
#	Site: http://cleiton.tech.blog/	
#	Data: 15/06/2018	

#Conteudo configuravel de acordo com suas necessidades 

Porta="9090"				
DirSis="/opt/openfire"
DirBkp="/opt/backup"

DATA=`date +%d%m%Y%H%M` #Data Atual somente os numeros

#Não apartir daqui

wget -q -O /tmp/VerLocal.txt --no-check-certificate http://localhost:$Porta/index.jsp #Busca o index do servidor local
wget -q -O /tmp/VerSite.txt --no-check-certificate https://igniterealtime.org/projects/openfire/index.jsp #Busca o index do site da Ignite Realtime

VerLocal=`cat /tmp/VerLocal.txt | grep 'Openfire, Versão' | cut -d',' -f2 | cut -d':' -f2 | cut -d' ' -f2` #Captura somente a versão no arquivo txt

VerSite=`cat /tmp/VerSite.txt | grep '<strong>Openfire' | cut -d'<' -f2 | cut -d' ' -f2` 	#Captura somente a versão no arquivo txt

if [ `echo $VerLocal | sed -e 's/\.//g'` -lt `echo $VerSite | sed -e 's/\.//g'` ] ; then #Compara a versão local com a versão do site
	echo "Iniciando o Update"
	if [ ! -d $DirSis ]; then # Verifica a existencia do diretório Openfire
		echo "Diretório da instalação Não encontrado!!!"
		echo "Encerrando atualização!"
	else
		echo "Sua versão atual do openfire é"  $VerLocal	
		echo "Efetuando o Backup"
			if [ ! -d $DirBkp ]; then # Verifica a existencia do diretório de backup
				echo "Diretório de backup Não encontrado!!!"
				echo "Encerrando atualização!"
			else
			tar -czf $DirBkp/openfire_"$VerLocal"_"$DATA".tar.gz $DirSis/* 
			echo "Backup escrito em: "$DirBkp"/openfire_"$VerLocal"_"$DATA".tar.gz"		
			echo "Efetuando o download versão"  $VerSite "do Openfire..." 	
				if wget -c --progress=dot -O /tmp/openfire-"`echo $VerSite `-1.x86_64.rpm" http://download.igniterealtime.org/openfire/openfire-`echo $VerSite `-1.x86_64.rpm > /dev/null; then
					echo "Download efetuado com sucesso."
					echo "Encerrando servico Openfire..."
					service openfire stop
					echo "Descompactando nova VerLocal e atualizando seu Openfire"
					rpm -Uvh /tmp/openfire-"`echo $VerSite `-1.x86_64.rpm"
					echo "Habilitando suas configuracoes definidas"
					echo "Inicializando seu Openfire..."
					service openfire start
					echo "OPENFIRE ATUALIZADO - Aguarde 3 minutos para fazer login em seu cliente Jabber"
					echo "Iniciando a limpeza dos arquivos de atualização"
					rm -f /tmp/openfire-"`echo $VerSite `-1.x86_64.rpm"
					rm -f /tmp/VerLocal.txt
					rm -f /tmp/VerSite.txt
				else
				echo "falha no download!!!"
				fi
			fi
	fi
fi
if [ `echo $VerLocal | sed -e 's/\.//g'` -eq `echo $VerSite | sed -e 's/\.//g'` ] ;  then
		echo "Seu Openfire já esta na versão mais Recente!!!"
fi
