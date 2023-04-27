# Author           : Patryk Pardej ( s165249@student.pg.gda.pl )
# Created On       : 10.06.2017
# Last Modified By : Patryk Pardej ( s165249@student.pg.gda.pl )
# Last Modified On : 13.06.2017
# Version          : 1
#
# Description      : Skrypt pozwalający wyszukać pliki mp3 na według ich tagów: tytuł, wykonawca, album, gatunek, rok wydania.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
#!/bin/bash
ODP=0
FOLDER="."
while getopts f:t:w:a:g:r: ARG; do case $ARG in
	f) FOLDER="$OPTARG";;
	t) TYTUL="$OPTARG";;
	w) WYKONAWCA="$OPTARG";;
	a) ALBUM="$OPTARG";;
	g) GATUNEK="$OPTARG";;
	r) ROK="$OPTARG";;
	:) echo "brak argumentu"; exit 1;;
	*) echo "zła opcja"; exit 1;;
	esac
done

while true; do
	exec 3>&1
	if [ "$FOLDER" = "." ]; then
		MENU=$(dialog \
		--title "Menu opcji" \
		--backtitle "Wyszukiwarka plików mp3" \
		--menu "Wyszukiwanie w folderze, w którym znajduje się plik wyszukiwarki" 14 50 6 \
		"1" "Tytuł: $TYTUL" \
		"2"	"Wykonawca: $WYKONAWCA" \
		"3" "Album: $ALBUM" \
		"4" "Gatunek: $GATUNEK" \
		"5" "Rok wydania: $ROK" \
		"6" "Wyszukaj" \
		2>&1 1>&3)
	else
		MENU=$(dialog \
		--title "Menu opcji" \
		--backtitle "Wyszukiwarka plików mp3" \
		--menu "Wyszukiwanie w $FOLDER" 14 50 6 \
		"1" "Tytuł: $TYTUL" \
		"2"	"Wykonawca: $WYKONAWCA" \
		"3" "Album: $ALBUM" \
		"4" "Gatunek: $GATUNEK" \
		"5" "Rok wydania: $ROK" \
		"6" "Wyszukaj" \
		2>&1 1>&3)
	fi
		

	WYJSCIE=$?
	exec 3>&-
	case $WYJSCIE in
		1)
		  clear
		  echo "Program zakończony."
		  exit
		  ;;
		255)
		  clear
		  echo "Program zakończony."
		  exit 1
		  ;;
	esac
	case $MENU in
		1) 
			clear
			exec 3>&1
			TYTUL=$(dialog --title "Menu opcji" \
			--backtitle "Wyszukiwarka plików mp3" \
			--inputbox "Wpisz tytuł szukanej piosenki" 8 40 2>&1 1>&3)
			exec 3>&-
			;;
		2) 	
			clear
			exec 3>&1
			WYKONAWCA=$(dialog --title "Menu opcji" \
			--backtitle "Wyszukiwarka plików mp3" \
			--inputbox "Wpisz wykonawcę szukanej piosenki" 8 40 2>&1 1>&3)
			exec 3>&-
			;;
		3) 
			clear
			exec 3>&1
			ALBUM=$(dialog --title "Menu opcji" \
			--backtitle "Wyszukiwarka plików mp3" \
			--inputbox "Wpisz album z którego pochodzi szukana piosenka" 8 40 2>&1 1>&3)
			exec 3>&-
			;;
		4) 
			clear
			exec 3>&1
			GATUNEK=$(dialog --title "Menu opcji" \
			--backtitle "Wyszukiwarka plików mp3" \
			--inputbox "Wpisz gatunek szukanej piosenki" 8 40 2>&1 1>&3)
			exec 3>&-
			;;
		5) 
			clear
			exec 3>&1
			ROK=$(dialog --title "Menu opcji" \
			--backtitle "Wyszukiwarka plików mp3" \
			--inputbox "Wpisz rok wydania szukanej piosenki" 8 40 2>&1 1>&3)
			exec 3>&-
			;;
		6) 
			clear
			break
			;;
	esac
done
find "$FOLDER" -name "*.mp3" -print0 | while read -r -d $'\0' PLIK;
do
	WARUNEK=0
	POSIADANE=0
	INFO=$(id3info "$PLIK")
	if [ "$TYTUL" ]; then
		WARUNEK=$((WARUNEK+1))
		echo "$INFO" | grep -q "=== TIT2 (Title/songname/content description): $TYTUL"
		if [ $? -eq 0 ]; then
			POSIADANE=$((POSIADANE+1))
		fi
	fi
	if [ "$WYKONAWCA" ]; then
		WARUNEK=$((WARUNEK+1))
		echo "$INFO" | grep -q "=== TPE1 (Lead performer(s)/Soloist(s)): $WYKONAWCA"
		if [ $? -eq 0 ]; then
			POSIADANE=$((POSIADANE+1))
		fi
	fi
	if [ "$ALBUM" ]; then
		WARUNEK=$((WARUNEK+1))
		echo "$INFO" | grep -q "=== TALB (ALBUM/Movie/Show title): $ALBUM"
		if [ $? -eq 0 ]; then
			POSIADANE=$((POSIADANE+1))
		fi
	fi
	if [ "$GATUNEK" ]; then
		WARUNEK=$((WARUNEK+1))
		echo "$INFO" | grep -q "=== TCON (Content type): $GATUNEK"
		if [ $? -eq 0 ]; then
			POSIADANE=$((POSIADANE+1))
		fi
	fi
	if [ "$ROK" ]; then
		WARUNEK=$((WARUNEK+1))
		echo "$INFO" | grep -q "=== TYER (Year): $ROK"
		if [ $? -eq 0 ]; then
			POSIADANE=$((POSIADANE+1))
		fi
	fi
	if [ "$WARUNEK" -eq "$POSIADANE" ]; then
		if [ "$FOLDER" = "." ]; then
			echo "$PLIK" | cut -d '/' -f 2
		else
			echo "$PLIK"
		fi
	fi
done