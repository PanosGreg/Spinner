
# A list of various escape sequences for cursor positioning, view modes or different buffer-related changes

# example on how to use this file:
# Let's assume that you're running this from the Module root folder.
# $Data = Import-LocalizedData -BaseDirectory Data -FileName Cursors.psd1

# NOTE: most of the following escape sequences can also be done using the [System.Console] class
#       and its various properties and methods. But according to Microsoft, we should be using the
#       VT100 escape sequences instead of the console class, in order to have the code work in
#       both Windows and Linux

@{
    Save        = [char]27 + '[s'
    Restore     = [char]27 + '[u'
    Hide        = [char]27 + '[?25l'
    Show        = [char]27 + '[?25h'
    MoveUp      = [char]27 + '[1F'  # <-- move cursor up by 1 line
    MoveDn      = [char]27 + '[1E'  # <-- move cursor down by 1 line
    ScrollUp    = [char]27 + '[1S'  # <-- scroll buffer up by 1 line
    ScrollDn    = [char]27 + '[1T'  # <-- scroll buffer down by 1 line
    DeleteEnd   = [char]27 + '[0K'  # <-- not limited to scroll margin, from cursor till end of line
    DeleteStart = [char]27 + '[1K'  # <-- not limited to scroll margin, from start of line till cursor
    DeleteLine  = [char]27 + '[2K'  # <-- not limited to scroll margin, where the cursor is currently on
    NoFormat    = [char]27 + '[m'
    Underline   = [char]27 + '[4m'
    NoUnderline = [char]27 + '[24m'
    Italic      = [char]27 + '[3m'
    NoItalic    = [char]27 + '[23m'
    Blink       = [char]27 + '[5m'
    NoBlink     = [char]27 + '[25m'
    Reset       = [char]27 + '[!p'
}