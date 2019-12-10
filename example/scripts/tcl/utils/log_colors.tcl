set WARNING "\033\[1;33m"
set INFO "\033\[1;34m"
set SUCCESS "\033\[1;32m"
set ERROR "\033\[1;31m"
set NONE "\033\[1;0m"

proc logger {text type} {
   puts $type$text$NONE
}