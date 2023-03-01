using System;

namespace Spinner {

    public enum IconSet {
        BoxSmall,
        BoxLarge,
        DotsSmall,
        TriangleSmall,
        TriangleLarge,
        BounceBoxSmall,
        BounceCircleSmall
    }

    public enum ColorSet {
        Default,
        Blue,
        Green,
        Orange,
        Yellow,
        Red,
        Magenta,
    }

    public enum CursorAction {
        Save,
        Restore,
        Hide,
        Show,
        MoveUp,
        MoveDn,
        ScrollUp,
        ScrollDn,
        DeleteEnd,
        DeleteStart,
        DeleteLine,
        NoColor,
        Underline,
        NoUnderline,
        Italic,
        NoItalic,
        Blink,
        NoBlink,
        Reset,
        GetPosition
    }

    public enum Speed {
        VerySlow   = 320,
        Slow       = 240,
        MediumSlow = 200,
        Medium     = 160,
        MediumFast = 120,
        Fast       =  80,
        VeryFast   =  40
    }
}