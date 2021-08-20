proc logger {text type} {
    set colours [dict create WARNING "\033\[1;33m" INFO "\033\[1;34m" SUCCESS "\033\[1;32m" ERROR "\033\[1;31m" NONE "\033\[1;0m"]
    puts [dict get $colours $type]${text}[dict get $colours NONE]
}

logger "Colour logging enabled!" SUCCESS