#!/bin/bash

# Description: Script that generate a test <...>.arch file

# Parameters checkin'
if [ $# -gt 1 ]; then
	echo "USAGE='$0 <name of the .arch file>'"
	echo "no args will generate a 'test.arch' file in your current directory"
	exit 1
elif [ $# -eq 0 ]; then
	file_name='test'
elif [ $# -eq 1 ]; then
	file_name="$1"
fi

# File content
file_content="
3:25\n
\ndirectory Exemple/Test/\nA drwxr-xr-x 4096\nB drwxr-xr-x 4096\ntoto1 -rwxr-xr-x 29 1 3\ntoto2 -rw-r--r-- 249 4 10\n@\ndirectory Exemple/Test/A\nA1 drwxr-xr-x 4096\nA2 drwxr-xr-x 4096\nA3 drwxr-xr-x 4096\ntoto3 -rw-r--r-- 121 14 3\n@\ndirectory Exemple/Test/A/A1\ntoto4 -rw-r--r-- 0 17 0\n@\ndirectory Exemple/Test/A/A2\n@\ndirectory Exemple/Test/A/A3\n@\ndirectory Exemple/Test/B\nbar -rw-r--r-- 202 17 6\n@\n#!/bin/bash\n\necho 'bonjour!'\nNAME\n
\tls - list directory contents\n\nSYNOPSIS\n
\tls [OPTION]... [FILE]...\n\nDESCRIPTION\n
\tList information about the FILEs.\nDESCRIPTION\n
\tman formats and displays the on-line manual pages.\nNAME\n
\tcat - concatenate files and print on the standard output\n\nSYNOPSIS\n
\tcat [OPTION] [FILE]...\n\nDESCRIPTION\n
\tConcatenate FILE(s), or standard input, to standard out-\n
\tput.
" 			

echo -e $file_content >> Archives/$file_name.arch
echo -e "log - $file_name.arch successfully generated (test-gen)" >> vsh.log

exit 0