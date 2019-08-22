#!/bin/bash

#Color Codes - In Case of Emergency
Gr="\033[0;32m"  		#Green
Br="\033[0;33m"		    #Brown
Yl="\033[1;33m"		    #Yellow
Pr="\033[0;35m"		    #Purple
Bl="\033[0;34m"		    #Blue
Rd="\033[0;31m"	    	#Red
Wh="\033[0;m"		    #White
Bold="\033[1m"  		#Bold
Dim="\033[2m"		    #Dim
Ul="\033[4m"		    #UnderLine

# GET OPTS

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--url)
    if [[ -z $2 ]]; then
        echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} $key option requires an argument\n"
        exit
    fi
    URL="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--artist)
    if [[ -z $2 ]]; then
        echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} $key option requires an argument\n"
        exit
    fi
    ARTIST="$2"
    shift # past argument
    shift # past value
    ;;
    -A|--album)
    if [[ -z $2 ]]; then
        echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} $key option requires an argument\n"
        exit
    fi
    ALBUM="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--title)
    if [[ -z $2 ]]; then
        echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} $key option requires an argument\n"
        exit
    fi
    TITLE="$2"
    shift # past argument
    shift # past value
    ;;
    -q|--quiet-mode)
    QUIET=YES
    shift # past argument
    ;;
    -h|--help)
    HELP=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    echo "$POSITIONAL"
    echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} Unknown option: $POSITIONAL. Please check the help page with -h or --help to see the possible options.\n"
    exit
fi

# echo "URL  = ${URL}"
# echo "ARTIST    = ${ARTIST}"
# echo "ALBUM         = ${ALBUM}"
# echo "TITLE         = ${TITLE}"
# echo "QUIET MODE         = ${QUIET}"
# echo "HELP         = ${HELP}"

## CHECK REQUIRED OPTIONS
if  [[ -z "$URL" && -z "$HELP" ]] ; then
    echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} Please use at least the -u option (for a URL link download) .Please check the help page with -h or --help to see the possible options.\n"
    exit
fi

banner()
{
	echo -ne \
"\
   ${Bold}┌─────────────────────────────────────────────────────────────────────┐${Wh}\n\
   │${Gr}${Bold}DihelYT${Wh}: ${Dim}${Br}Download Music (mp3) from YT  with tags & art ${Wh} ${Pr}1.0 (C) 2019${Wh} │\n\
   │${Gr}${Bold}Author${Wh}   : ${Gr}Ariary${Wh}			                                 │\n\
   │${Gr}${Bold}Notes${Wh}   : ${Gr}Huge inspiration from https://github.com/iamrootsh3ll/odio ${Wh}│\n\
   │${Gr}${Bold}Dependencies${Wh}   : ${Br}youtube-dl, ffmpeg, and python-mutagen, jq   ${Wh}   	 │\n\
   ${Dim}${Bold}└─────────────────────────────────────────────────────────────────────┘${Wh}\n\
"
}

help()
{
	echo -ne \
"\
   -u | --url specify the youtube url to download. This option is required. -a | -- artist specify the artist tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. \n\

   -A | --album specify the album tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. \n\

   -t | --title specify the artist tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. \n\

   -q|--quiet-mode Verbose mode is enable by default. Enable to run the script without I/O information. \n\

   -h|--help display the available options. \n\
"
}




function youtube_audio_download(){
	thumbnail=$(youtube-dl --skip-download --get-thumbnail --restrict-filenames $1) #get thumbnail URL location
	filename_base=$(youtube-dl --skip-download --get-filename --restrict-filenames $1 | rev | cut -d "." -f2- | rev ) #get filename. By default youtube-dl put the mp4 extension so we must delete the extension
	if [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]]; then
		if [[ -z "$QUIET" ]]; then
			youtube-dl  -x  --audio-format mp3 --write-thumbnail --write-info-json --restrict-filenames $1 # Download
		else
			youtube-dl  -x  --audio-format mp3 --write-thumbnail --write-info-json --restrict-filenames -q $1 # Download non-verbose
		fi
		
		read_json "$filename_base.info.json"
	else
		youtube-dl  -x  --audio-format mp3 --write-thumbnail --restrict-filenames $1 # nothing to read in the information json file
	fi
	
	
	filename_output=$(youtube-dl --skip-download --get-title --restrict-filenames $1)
	
	add_art "$filename_base.mp3" "$thumbnail" "$filename_output.mp3" #Add thumbnail image

	#last Chek-up
	if [[ -z "$ARTIST" ]]; then
		echo -ne "\r${Bold}${Gr}[Action required]  \b\b${Wh} "
		read -r -p "No artist has been found. Do you want to specify one? [y/N] (Press enter to continue without specify it)" response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then
		    read -r -p "Please specify the title: " ARTIST
		fi
	fi

	if [[ -z "$ALBUM" ]]; then
		echo -ne "\r${Bold}${Gr}[Action required]  \b\b${Wh} "
		read -r -p "No Album title has been found. Do you want to specify one? [y/N] (Press enter to continue without specify it)" response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then
		    read -r -p "Please specify the title: " ALBUM
		fi
	fi

	if [[ -z  "$TITLE" ]]; then
		echo -ne "\r${Bold}${Gr}[Action required]  \b\b${Wh} "
		read -r -p "No title has been found. Do you want to specify one? [y/N] (Press enter to continue without specify it)" response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then
		    read -r -p "Please specify the title: " TITLE
		fi
	fi

	if [[ -z  "$YEAR" ]]; then
		YEAR="$(date +"%Y")" #current year
	fi

	edit_info "$filename_output.mp3" "$TITLE" "$ARTIST" "$TITLE" "$YEAR"
	remove_files "$filename_base"
}


function add_art(){
	if [[ -z "$QUIET" ]]; then
		ffmpeg -i "$1" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$3"
	else
		ffmpeg -i "$1" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -loglevel error "$3" # non-verbose
	fi
}

function read_json(){
	if [[ -z "$ARTIST" ]]; then
		ARTIST="$(cat $1 | jq ."creator" | cut -d "\"" -f 2)"
	fi

	if [[ -z "$ALBUM" ]]; then
		ALBUM="$(cat $1 | jq ."album" | cut -d "\"" -f 2)"
	fi

	if [[ -z  "$TITLE" ]]; then
		TITLE="$(cat $1 | jq ."title" | cut -d "\"" -f 2)"
	fi

	YEAR="$(cat $1 | jq ."release_year" | cut -d "\"" -f 2)"
}

function edit_info(){
	if [[ -z "$QUIET" ]]; then
		mid3v2 -a "$3" -A "$4" -t "$2" -y "$YEAR" "$1"  #Track info edition
	else
		mid3v2 -a "$3" -A "$4" -t "$2" -y "$YEAR" "$1"  #Track info edition
	fi
}

function remove_files(){
	rm "$1"*  
}


#START PRGM
## BANNER
if [[ -z "$QUIET" ]]; then
	banner
fi

## DL / HELP
if [[ -z "$HELP" ]]; then
	youtube_audio_download "$URL" "$TITLE" "$ARTIST" "$ALBUM"
else
	help
fi

