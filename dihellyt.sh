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

banner()
{
	echo -ne \
"\
   ${Bold}┌─────────────────────────────────────────────────────────────────────┐${Wh}\n\
   │${Gr}${Bold}DihelYT${Wh}: ${Dim}${Br}Download Music (mp3) from YT  with tags & art ${Wh} ${Pr}1.0 (C) 2019${Wh} │\n\
   │${Gr}${Bold}Author${Wh}   : ${Gr}Ariary${Wh}			                                 │\n\
   │${Gr}${Bold}Notes${Wh}   : ${Gr}Huge inspiration from https://github.com/iamrootsh3ll/odio ${Wh}│\n\
   │${Gr}${Bold}Dependencies${Wh}   : ${Br}youtube-dl, ffmpepg, and python-mutagen, jq   ${Wh}   	 │\n\
   ${Dim}${Bold}└─────────────────────────────────────────────────────────────────────┘${Wh}\n\
"
}

function youtube-audio-downloader()
{
	if [[ -z $1 ]]; then
		echo -ne "\r${Bold}${Rd}[Error]  \b\b${Wh} Please provide an URL\n"
	else
		thumbnail=$(youtube-dl --skip-download --get-thumbnail $1) #get thumbnail URL location
		filename_base=$(youtube-dl --skip-download --get-filename $1 | rev | cut -d "." -f2 | rev ) #get filename. By default youtube-dl put the mp4 extension so we must delete the extension
		youtube-dl  -x  --audio-format mp3 --write-thumbnail --write-info-json $1 # Download
		filename_output=$(youtube-dl --skip-download --get-title $1)
		
		add_art "$filename_base.mp3" "$thumbnail" "$filename_output.mp3" #Add thumbnail image
		edit_info "$filename_base.info.json" "$filename_output.mp3"
		remove_files "$filename_base"


	fi
}

function add_art(){
	ffmpeg -i "$1" -i "$2" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$3"
}

function edit_info(){ #TO IMPROVE, avoid cat repetition
	artist="$(cat $1 | jq ."creator" | cut -d "\"" -f 2)"
	album="$(cat $1 | jq ."album" | cut -d "\"" -f 2)"
	title="$(cat $1 | jq ."title" | cut -d "\"" -f 2)"
	year="$(cat $1 | jq ."release_year" | cut -d "\"" -f 2)"


	mid3v2 -a "$artist" -A "$album" -t "$title" -y "$year" "$2"  #Track info edition
}

function remove_files(){
	rm "$1"*  
}

banner
youtube-audio-downloader "$1"
