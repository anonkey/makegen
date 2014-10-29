#!/bin/sh
makename="Makefile"
name=`basename $PWD`
lib=""
flags="-Wall -Wextra -Werror"
cc="clang"
src=`ls src/***/*.c`
while getopts "af:n:l:" opt; do
  case $opt in
    f)
	  flags+=$OPTARG
      ;;
    n)
	  name=$OPTARG
      ;;
    l)
	  lib+="$OPTARG "
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

echo "name $name \n"
#mkdir src include obj || exit

if [ ! "$lib" = "" ]
then
	#mkdir lib || exit
	echo "lib $lib"
fi

echo "CC = $CC
ifeq (\$(DEBUG), 1)
	CFLAGS = $flags
else
	normal! oCFLAGS = -Wall -Wextra -Werror
endif
NAME = $name"
if [ ! "$lib" = "" ]
then
	echo -n "LIBFLAGS =" >> $makename
	foreach $var in $lib
	#TODO: lib copy
		echo "-l$lib " >> $makename
	end
	echo "" >> $makename

	echo -n "LIBDIRS =" >> $makename
	foreach $var in $lib
	#TODO: lib copy
		echo -n "-L ./lib/lib$lib/ " >> $makename
	end
	echo "" >> $makename
	echo -n "INCDIRS =" >> $makename
	foreach $var in $lib
	#TODO: lib copy
		echo -n "-I ./lib/lib$lib/include " >> $makename
	end
	echo "" >> $makename
fi
echo "INCDIR += include" >> $makename
echo -n "SRC = main.c" >> $makename
foreach $var in $src
#TODO: lib copy
	echo -n " \\
	$src" >> $makename
end
echo "
OBJ = \$(SRC:.c=.o)
" >> $makename
if [ ! "$lib" = "" ]
then
	echo "all: \$(LIBNAME) \$(NAME)" >> $makename
	foreach $var in $lib
		#TODO: lib copy
		echo "$var:
	make -C lib/lib$var
$var\_fclean:
	make -C lib/lib$var fclean" >> $makename
	end
	echo "
\$(NAME): \$(OBJ)
	\$(CC) \$(CFLAGS) \$(LIBDIRS) \$(LIBFLAGS) -o \$(NAME) -I \$(INCDIR) \$(OBJ)" >> $makename
	
%.o: %.c"
	\$(CC) -I \$(INCDIR) \$(INCDIRS) \$(CFLAGS) -c \$< -o \$@ " >> $makename
else
	echo "all: \$(NAME)

\$(NAME): \$(OBJ)
	\$(CC) \$(CFLAGS) \$(OBJ) -o \$(NAME)
%.o: %.c
	\$(CC) -o \$@ -c \$< \$(CFLAGS)

clean:
	rm -rf \$(OBJ)
" >> $makename
if [ ! "$lib" = "" ]
then
	echo -n "fclean: " >> $makename
	foreach $var in $lib
		#TODO: lib copy
		echo -n "$var\_fclean " >> $makename
	end
	echo "clean
rm -rf \$(NAME)" >> $makename
	echo -n "re: " >> $makename
	foreach $var in $lib
		#TODO: lib copy
		echo -n "$var\_fclean " >> $makename
	end
	echo "fclean all" >> $makename
else
echo "fclean: clean
	rm -rf \$(NAME)
re: fclean all

.PHONY: clean fclean all re" >> $makename

