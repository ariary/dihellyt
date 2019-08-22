
# dihellyt
Download Music (mp3) from YT  with tags &amp; art.
To use it install the dependencies and make the bash script executable:

    # apt-get install youtube-dl ffmpeg python-mutagen jq
    # chmod a+x dihellyt.sh 

## Options
`-u` | `--url` specify the youtube url to download. This option is required.
 -a | --artist specify the artist tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. 
 `-A` | `--album` specify the album tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. 
 `-t` | `--title` specify the artist tag of the mp3 resulted file. If the flag is not used the shell will try to find it by itself. 
 `-q`|`--quiet-mode` Verbose mode is enable by default. Enable to run the script without I/O information. **TODO**
`-h`|`--help` display the available options. **TODO**


## Behavior
In case of the user doesn't use th `-a` or `-A` or `-t` flag and the script doesn't find the information by itself a prompt will be shown to the user to aski him if he want to specify it manually. (The default behavior is no, hence by pressing the `return` key you won't specify it).
