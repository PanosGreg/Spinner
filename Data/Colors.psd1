
# A small set of colors

# example on how to use this file:
# Let's assume that you're running this from the Module root folder.
# $Data = Import-LocalizedData -BaseDirectory Data -FileName Colors.psd1

@{
    Blue        = @{R =  61 ; G = 148 ; B = 243}
    Green       = @{R = 146 ; G = 208 ; B =  80}
    Orange      = @{R = 255 ; G = 126 ; B =   0}
    Yellow      = @{R = 240 ; G = 230 ; B = 140}
    Red         = @{R = 231 ; G =  72 ; B =  86}
    Magenta     = @{R = 254 ; G = 140 ; B = 255}

    LiteBlue    = @{R = 153 ; G = 204 ; B = 255}
    LiteGreen   = @{R = 139 ; G = 231 ; B = 139}
    LiteOrange  = @{R = 255 ; G = 179 ; B = 102}
    LiteYellow  = @{R = 248 ; G = 248 ; B =   0}
    LiteRed     = @{R = 232 ; G =  82 ; B =  83}
    LiteMagenta = @{R = 247 ; G = 179 ; B = 247}

    DarkBlue    = @{R =  68 ; G = 114 ; B = 196}
    DarkGreen   = @{R =   0 ; G = 128 ; B =   0}
    DarkOrange  = @{R = 191 ; G =  96 ; B =   0}
    DarkYellow  = @{R = 148 ; G = 148 ; B =   0}
    DarkRed     = @{R = 124 ; G =  35 ; B =  35}
    DarkMagenta = @{R = 153 ; G =  51 ; B = 255}
}