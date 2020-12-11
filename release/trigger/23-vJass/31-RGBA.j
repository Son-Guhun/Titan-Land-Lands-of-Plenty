library RGBA
/*
Code by Guhun aka. SonGuhun
MIT license
Version 1.0.0

=========
 Description
=========

    This library defines the immutable struct RGBA, which can be used to store color data. These objects are internally
just integers, in which each byte pair represents a channel. This means you don't have to worry about destroying them to
free up memory.
    
=========
 Documentation
=========
    
    struct RGBA:
    
        Constants:
            integer R  -> Represents the red channel and can be used in methods that require a channel.
            integer G  -> Represents the green channel and can be used in methods that require a channel.
            integer B  -> Represents the blue channel and can be used in methods that require a channel.
            integer A  -> Represents the alpha channel and can be used in methods that require a channel.
            
            integer RGB  -> Represents all except the alpha channel and can be used in methods that require a channel.
    
        Fields:
            integer red
            integer green
            integer blue
            integer alpha
            
        Methods:
        
            . These methods return a new RGBA object, with an altered value for a channel:
            .   RGBA withRed(integer value)
            .   RGBA withBlue(integer value)
            .   RGBA withGreen(integer value)
            .   RGBA withAlpha(integer value)
            
            RGBA clearChannels(integer channels)
            .
            . Returns a new RGBA object, with zero as the value for all specified channels. To specify more than one channel, use their sum.
            
            RGBA setChannel(integer channel, integer value)
            .
            . Returns a new RGBA object with the specified channel altered. Cannot handle more than a single channel at once.
            . This is the only method of the RGBA struct which is not inlined by JassHelper.
            
            Static:
                RGBA create(integer r, integer g, integer b, integer a)
                RGBA alphaFirst(integer a, integer g, integer b, integer a)  -> Wrapper over BlzConvertColor. Should be marginally faster than create().
                RGBA newRGB(integer r, integer g, integer b)  -> Uses 255 as the value for the alpha channel.
                
                RGBA newRed(integer value)    -> Creates a new RGBA object with only a red channel.
                RGBA newGreen(integer value)  -> Creates a new RGBA object with only a green channel.
                RGBA newBlue(integer value)   -> Creates a new RGBA object with only a blue channel.
                RGBA newAlpha(integer value)  -> Creates a new RGBA object with only a alpha channel.
*/
//==================================================================================================
//                                       Usage Examples
//==================================================================================================
//! novjass

// Channel values must be in the range of 0 to 255. There is not protection against overflow.
RGBA yellow = RGBA.newRGB(255, 255, 0)
RGBA yellow_transparent = RGBA.create(255, 255, 0, 127)

RGBA magenta = yellow.clearChannels(RGBA.G).setChannel(RGBA.B, 255)
RGBA cyan = magenta.withRed(0).withGreen(255)

// We can add two RGBA colors, but first we must make sure that they don't share any channels to avoid overflow.
// Since we are clearing the alpha channel, we can add a new color which only has an alpha channel.
RGBA red = yellow_transparent.clearChannels(RGBA.G + RGBA.A) + RGBA.newAlpha(255)

RGBA transparent = yellow_transparent.clearChannels(RGBA.RGB)

RGBA black = RGBA.newAlpha(255) or 0xff000000
RGBA white = RGBA.newRGB(255, 255, 255) or 0xffffffff


// INVALID USAGE
RGBA invalid = magenta.setChannel(RGBA.RGB, 127)  // Cannot use RGB in setChannel, because it contains more than 1 channel.

//! endnovjass
//==================================================================================================
//                                        Source Code
//==================================================================================================

// Masks used to obtain values for each channel.
private struct Masks extends array

    static method operator RED takes nothing returns integer
        return $00FF0000
    endmethod
    
    static method operator GREEN takes nothing returns integer
        return $0000FF00
    endmethod
    
    static method operator BLUE takes nothing returns integer
        return $000000FF
    endmethod
    
    static method operator ALPHA takes nothing returns integer
        return $FF000000
    endmethod
    
    static method operator GBA takes nothing returns integer
        return $FF00FFFF
    endmethod
    
    static method operator RBA takes nothing returns integer
        return $FFFF00FF
    endmethod
    
    static method operator RGA takes nothing returns integer
        return $FFFFFF00
    endmethod
    
    static method operator RGB takes nothing returns integer
        return $00FFFFFF
    endmethod
    
endstruct

// When setting the value for a channel, the value must first be multiplied by one of the constants below.
private struct Multipliers extends array
    static method operator ALPHA takes nothing returns integer
        return $1000000
    endmethod
    
    static method operator RED takes nothing returns integer
        return $10000
    endmethod
    
    static method operator GREEN takes nothing returns integer
        return $100
    endmethod
endstruct

struct RGBA extends array
    
    static method operator R takes nothing returns integer
        return Masks.RED
    endmethod
    
    static method operator G takes nothing returns integer
        return Masks.GREEN
    endmethod
    
    static method operator B takes nothing returns integer
        return Masks.BLUE
    endmethod
    
    static method operator A takes nothing returns integer
        return Masks.ALPHA
    endmethod
    
    static method operator RGB takes nothing returns integer
        return Masks.RGB
    endmethod


    method operator red takes nothing returns integer
        return BlzBitAnd(this, Masks.RED) / Multipliers.RED
    endmethod
    
    method operator green takes nothing returns integer
        return BlzBitAnd(this, Masks.GREEN) / Multipliers.GREEN
    endmethod
    
    method operator blue takes nothing returns integer
        return BlzBitAnd(this, Masks.BLUE)
    endmethod
    
    // This is a special case, since all integers are signed in JASS.
    method operator alpha takes nothing returns integer
        return ModuloInteger(BlzBitAnd(this, Masks.ALPHA) / Multipliers.ALPHA, 256)
        /*
        Below is a faster implementation, but it's not inlined by JassHelper
        
        if this >= 0 then
            return this / Multipliers.ALPHA
        else
            return 256 + this/Multipliers.ALPHA
        endif
        */
    endmethod
    
    
    method withRed takes integer val returns thistype
        return BlzBitAnd(this, Masks.GBA) + Multipliers.RED * val
    endmethod
    
    method withGreen takes integer val returns thistype
        return BlzBitAnd(this, Masks.RBA) + Multipliers.GREEN * val
    endmethod
    
    method withBlue takes integer val returns thistype
        return BlzBitAnd(this, Masks.RGA) + val
    endmethod
    
    method withAlpha takes integer val returns thistype
        return BlzBitAnd(this, Masks.RGB) + Multipliers.ALPHA * val
    endmethod
    
    
    method clearChannels takes integer channels returns thistype
        return BlzBitAnd(this, BlzBitXor(channels, 0xffffffff))
    endmethod
    
    method withChannel takes integer channel, integer val returns thistype
        return this.clearChannels(channel) + (channel/255 * val)
    endmethod
    
    
    static method create takes integer r, integer g, integer b, integer a returns thistype
        return Multipliers.RED * r + Multipliers.GREEN * g + b + Multipliers.ALPHA * a
    endmethod
    
    static method alphaFirst takes integer a, integer r, integer g, integer b returns thistype
        return BlzConvertColor(a, r, g, b)
    endmethod
    
    static method newRGB takes integer r, integer g, integer b returns thistype
        return alphaFirst(0, r, g, b)
    endmethod
    
    static method newRed takes integer val returns thistype
        return Multipliers.RED * val
    endmethod
    
    static method newGreen takes integer val returns thistype
        return Multipliers.GREEN * val
    endmethod
    
    static method newBlue takes integer val returns thistype
        return val
    endmethod
    
    static method newAlpha takes integer val returns thistype
        return Multipliers.ALPHA * val
    endmethod
    
endstruct


endlibrary