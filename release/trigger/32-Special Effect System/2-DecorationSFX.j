library DecorationSFX requires SpecialEffect, TableStruct, OOP

///////////////////////////////////////////////////////////////
// Configuration
///////////////////////////////////////////////////////////////

// Allows you to specify that a player's decorations should use another player's color, using DecorationSFX_SetPlayerColor.
globals
    public constant boolean USE_CUSTOM_PLAYER_COLORS = true
    public constant integer BLOCK_SIZE = 2048
endglobals

//! novjass
'                                        Documentation                                             '

// This function only works if USE_CUSTOM_PLAYER_COLORS is true
public function SetPlayerColor takes player whichPlayer, integer color returns nothing

/*Doc:
    A struct that extends SpecialEffect. These effects are tracked on the map and can be enumerated
    using the functions provided by this library's API.
*/
struct DecorationEffect extends array

    real x // The setter is redefined from SpecialEffect. You should not use the SpecialEffect setter for DecorationEffect objects.
    real y // The setter is redefined from SpecialEffect. You should not use the SpecialEffect setter for DecorationEffect objects.
    integer color // The setter is redefined from SpecialEffect. You should not use the SpecialEffect setter for DecorationEffect objects.

    method getOwner takes nothing returns player
    
    method setOwner takes player newOwner returns nothing
    
    /* Creates a SpecialEffect and converts it using convertSpecialEffect */
    static method convertSpecialEffect takes player playerid, SpecialEffect sfx, boolean useCustomColor returns DecorationEffect
    
    /* If a player's color for this system is changed, this method must be called to update values for all of their existing effects */
    static method updateColorsForPlayer takes player whichPlayer returns nothing
    
    /* Destroys all DecorationSFX data, effectively turning the object into a SpecialEffect */
    method convertToSpecialEffect takes nothing returns SpecialEffect
    
    static method create takes player id, integer unitType, real x, real y returns DecorationEffect
    
    method destroy takes nothing returns nothing
    
endstruct

// Struct defined using LinkedHashSet generics
struct LinkedHashSet_DecorationEffect extends array

// Enumeration functions

// The Sets returned by these fucntions are not meant to persist, they are meant solely for iteration.
// DecorationEffects are not reference-counted, and they may be replaced by other effects after removed.
function EnumDecorationsOfPlayer takes player whichPlayer returns LinkedHashSet
function EnumDecorationsInRect takes real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
function EnumDecorationsOfPlayerInRect takes player whichPlayer, real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
function EnumDecorationsInRange takes real centerX, real centerY, real radius returns LinkedHashSet_DecorationEffect
function EnumDecorationsOfPlayerInRange takes player whichPlayer, real centerX, real centerY, real radius returns LinkedHashSet_DecorationEffect

'                                         Source Code                                              '
//! endnovjass

private struct PlayerData extends array

    implement DebugPlayerStruct
    
    static if USE_CUSTOM_PLAYER_COLORS then
        //! runtextmacro TableStruct_NewReadonlyPrimitiveField("color_impl", "integer")
    endif
    
    method operator color takes nothing returns integer
        static if USE_CUSTOM_PLAYER_COLORS then
            return .color_impl
        else
            return GetHandleId(GetPlayerColor(Player(this)))
        endif
    endmethod
    
    method operator color= takes integer color returns nothing
        static if USE_CUSTOM_PLAYER_COLORS then
            set .color_impl = color
        endif
    endmethod
    
    static method get takes player whichPlayer returns thistype
        return GetPlayerId(whichPlayer)
    endmethod
    
endstruct


private struct DecorationEffectBlock extends array

    implement DebugNegativeIsNull

    //! runtextmacro TableStruct_NewStructField("effects","LinkedHashSet")
    
    static method get takes real x, real y returns DecorationEffectBlock
        return GetCustomTileId(BLOCK_SIZE, x, y)
    endmethod

endstruct

private keyword InheritedFromSpecialEffect
struct DecorationEffect extends array
 
    implement InheritedFromSpecialEffect
    
    //! runtextmacro HashStruct_SetHashtableWrapper("SpecialEffect_hT")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("owner","integer")
    //! runtextmacro HashStruct_NewReadonlyBooleanFieldWithDefault("hasCustomColor","false")
    
    method operator x= takes real value returns nothing
        local effect decoration = .effect
        local real y = BlzGetLocalSpecialEffectY(decoration)
        implement assertNotNull
    
        call DecorationEffectBlock.get(BlzGetLocalSpecialEffectX(decoration), y).effects.remove(this)
        call DecorationEffectBlock.get(value, y).effects.append(this)
        call BlzSetSpecialEffectX(decoration, value)
        call BlzSetSpecialEffectHeight(.effect, .height)
        
        
        set decoration = null
    endmethod
    
    method operator y= takes real value returns nothing
        local effect decoration = .effect
        local real x = BlzGetLocalSpecialEffectX(decoration)
        implement assertNotNull
    
        call DecorationEffectBlock.get(x, BlzGetLocalSpecialEffectY(decoration)).effects.remove(this)
        call DecorationEffectBlock.get(x, value).effects.append(this)
        call BlzSetSpecialEffectY(decoration, value)
        call BlzSetSpecialEffectHeight(.effect, .height)
        
        set decoration = null
    endmethod

    method operator color= takes integer value returns nothing
        set .hasCustomColor = true
        set SpecialEffect(this).color = value
    endmethod
    
    method resetColor takes nothing returns nothing
        set .hasCustomColor = false
        set SpecialEffect(this).color = PlayerData(.owner).color
    endmethod
    
    method getOwner takes nothing returns player
        return Player(.owner)
    endmethod
    
    method setOwner takes player newOwner returns nothing
        local PlayerData owner
        if newOwner != null then
            set owner = GetPlayerId(newOwner)
        
            set .owner = owner
            if not .hasCustomColor then
                set SpecialEffect(this).color = owner.color
            endif
        endif
    endmethod
    
    // Factory method, converts a SpecialEffect to a DecorationEffect
    static method convertSpecialEffect takes player playerid, SpecialEffect sfx, boolean useCustomColor returns DecorationEffect
        if useCustomColor then
            set DecorationEffect(sfx).owner = GetPlayerId(playerid)
            set DecorationEffect(sfx).hasCustomColor = true
        else
            call DecorationEffect(sfx).setOwner(playerid)
        endif
        call DecorationEffectBlock.get(sfx.x, sfx.y).effects.append(sfx) 
        return sfx
    endmethod
    

    static method create takes player playerid, integer unitType, real x, real y returns DecorationEffect
        return thistype.convertSpecialEffect(playerid, SpecialEffect.create(unitType, x, y), false)
    endmethod
    
    method destroy takes nothing returns nothing
        local effect e = .effect
        call DecorationEffectBlock.get(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e)).effects.remove(this)
        
        call SpecialEffect(this).destroy()
        set e = null
    endmethod
    
    method convertToSpecialEffect takes nothing returns SpecialEffect
        call .owner_clear()
        set .hasCustomColor = false  // this clears it, since it is a boolean field with default "false"
        call DecorationEffectBlock.get(.x, .y).effects.remove(this)
        return this
    endmethod
    
    static method enumDecorationsOfPlayer takes player whichPlayer returns LinkedHashSet
        local integer lastId = DecorationEffectBlock.get(WorldBounds.maxX, WorldBounds.maxY)
        local integer i = 0
        local LinkedHashSet decorations
        local DecorationEffect decoration
        local LinkedHashSet result = LinkedHashSet.create()
        
        loop
        exitwhen i > lastId
            set decorations = DecorationEffectBlock(i).effects
            
            if not decorations.isEmpty() then
                set decoration = decorations.begin()
                loop
                    exitwhen decoration == decorations.end()
                    if decoration.getOwner() == whichPlayer then
                        call result.append(decoration)
                    endif
                    set decoration = decorations.next(decoration)
                endloop  
            endif

            set i = i + 1
        endloop
        
        return result
    endmethod
    
    static method updateColorsForPlayer takes player whichPlayer returns nothing
        local integer color
        local LinkedHashSet decorations
        local DecorationEffect deco
        
        if whichPlayer != null then
            set color = PlayerData.get(whichPlayer).color
            
            set decorations = .enumDecorationsOfPlayer(whichPlayer)
            set deco = decorations.begin()
            loop
            exitwhen deco == decorations.end()
                if not deco.hasCustomColor then
                    set SpecialEffect(deco).color = color
                endif
                
                set deco = decorations.next(deco)
            endloop
            call decorations.destroy()
        endif
    endmethod

endstruct

public function SetPlayerColor takes player whichPlayer, integer color returns nothing
    set PlayerData(GetPlayerId(whichPlayer)).color = color
endfunction

function DecorationSFX_GetPlayerColor takes player whichPlayer returns integer
    return PlayerData(GetPlayerId(whichPlayer)).color
endfunction

// Create Linked Hash Set
//! runtextmacro GenerateStructLHS("DecorationEffect")

function AreCoordsInRectangle takes real x, real y, real minX, real minY, real maxX, real maxY returns boolean
    return x >= minX and x <= maxX and y >= minY and y <= maxY
endfunction

public function ResetHeightsInBlock takes integer block returns nothing
    local LinkedHashSet decorations = DecorationEffectBlock(block).effects
    local DecorationEffect decoration = decorations.begin()
    
    if decoration != decorations.end() then
        loop
            exitwhen decoration == decorations.end()
            set decoration.height = decoration.height
            set decoration = decorations.next(decoration)
        endloop
    endif
endfunction

function EnumDecorationsInRect takes real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
    //! runtextmacro TilesInRectLoopDeclare("block", "BLOCK_SIZE", "minX", "minY", "maxX", "maxY")
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop   
        set decorations = DecorationEffectBlock(block).effects
        set decoration = decorations.begin()
        loop
            exitwhen decoration == decorations.end()
            set e = decoration.effect
            if AreCoordsInRectangle(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e), minX, minY, maxX, maxY) then
                call result.append(decoration)
            endif
            set decoration = decorations.next(decoration)
        endloop
        
        //! runtextmacro TilesInRectLoop("block", "BLOCK_SIZE")
    endloop
    
    return result
endfunction

function EnumDecorationsOfPlayerInRect takes player whichPlayer, real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
    //! runtextmacro TilesInRectLoopDeclare("block", "BLOCK_SIZE", "minX", "minY", "maxX", "maxY")
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set decorations = DecorationEffectBlock(block).effects
        set decoration = decorations.begin()
        loop
            exitwhen decoration == decorations.end()
            set e = decoration.effect
            if AreCoordsInRectangle(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e), minX, minY, maxX, maxY) and decoration.getOwner() == whichPlayer then
                call result.append(decoration)
            endif
            set decoration = decorations.next(decoration)
        endloop
        
        //! runtextmacro TilesInRectLoop("block", "BLOCK_SIZE")
    endloop
    
    return result
endfunction

// This function should inline
private function DistanceSquared takes real x, real x0, real y, real y0 returns real
    return Pow(x - x0, 2.) + Pow(y - y0, 2.)
endfunction

// This function should inline
private function Distance takes real x, real x0, real y, real y0 returns real
    return SquareRoot(DistanceSquared(x,x0,y,y0))
endfunction

function EnumDecorationsInRange takes real centerX, real centerY, real radius returns LinkedHashSet_DecorationEffect
    //! runtextmacro TilesInRectLoopDeclare("block", "BLOCK_SIZE", "centerX - radius", "centerY - radius", "centerX + radius", "centerY + radius")

    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set decorations = DecorationEffectBlock(block).effects
        set decoration = decorations.begin()
        loop
            exitwhen decoration == decorations.end()
            set e = decoration.effect
            if Distance(BlzGetLocalSpecialEffectX(e), centerX, BlzGetLocalSpecialEffectY(e), centerY) <= radius then
                call result.append(decoration)
            endif
            set decoration = decorations.next(decoration)
        endloop
        
        //! runtextmacro TilesInRectLoop("block", "BLOCK_SIZE")
    endloop
    
    return result
endfunction

function EnumDecorationsOfPlayerInRange takes player whichPlayer, real centerX, real centerY, real radius returns LinkedHashSet_DecorationEffect
    //! runtextmacro TilesInRectLoopDeclare("block", "BLOCK_SIZE", "centerX - radius", "centerY - radius", "centerX + radius", "centerY + radius")
    
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set decorations = DecorationEffectBlock(block).effects
        set decoration = decorations.begin()
        loop
            exitwhen decoration == decorations.end()
            set e = decoration.effect
            if Distance(BlzGetLocalSpecialEffectX(e), centerX, BlzGetLocalSpecialEffectY(e), centerY) <= radius and decoration.getOwner() == whichPlayer then
                call result.append(decoration)
            endif
            set decoration = decorations.next(decoration)
        endloop
        
        //! runtextmacro TilesInRectLoop("block", "BLOCK_SIZE")
    endloop
    
    return result
endfunction

function EnumDecorationsOfPlayer takes player whichPlayer returns LinkedHashSet_DecorationEffect
    return DecorationEffect.enumDecorationsOfPlayer(whichPlayer)
endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        local integer lastId
        local integer i = 0
        
        call InitCustomTiles(BLOCK_SIZE)
        set lastId = DecorationEffectBlock.get(WorldBounds.maxX, WorldBounds.maxY)
        loop
        exitwhen i > lastId
            set DecorationEffectBlock(i).effects = LinkedHashSet.create()
            set i = i + 1
        endloop
        
        set i = 0
        loop
        exitwhen i == bj_MAX_PLAYER_SLOTS
            set PlayerData(i).color = GetHandleId(GetPlayerColor(Player(i)))
            set i = i + 1
        endloop
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

private module InheritedFromSpecialEffect
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "x", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "y", "real")
    
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "effect", "effect")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "unitType", "integer")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "skin", "integer")
    //! runtextmacro InheritField("SpecialEffect", "height", "real")
    
    //! runtextmacro InheritField("SpecialEffect", "yaw", "real")
    //! runtextmacro InheritField("SpecialEffect", "pitch", "real")
    //! runtextmacro InheritField("SpecialEffect", "roll", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "color", "integer")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "scaleX", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "scaleY", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "scaleZ", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "red", "integer")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "green", "integer")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "blue", "integer")
    //! runtextmacro InheritField("SpecialEffect", "alpha", "integer")
    //! runtextmacro InheritField("SpecialEffect", "animationSpeed", "real")
    //! runtextmacro InheritFieldReadonly("SpecialEffect", "subanimations", "LinkedHashSet")


    method setOrientation takes real yaw, real pitch, real roll returns nothing
        call SpecialEffect(this).setOrientation(yaw, pitch, roll)
    endmethod
    
    method setScale takes real scaleX, real scaleY, real scaleZ returns nothing
        call SpecialEffect(this).setScale(scaleX, scaleY, scaleZ)
    endmethod
    
    method setVertexColor takes integer red, integer green, integer blue returns nothing
        call SpecialEffect(this).setVertexColor(red, green, blue)
    endmethod
    
    method hasSubAnimations takes nothing returns boolean
        return SpecialEffect(this).hasSubAnimations()
    endmethod
    
    method addSubAnimation takes subanimtype anim returns nothing
        call SpecialEffect(this).addSubAnimation(anim)
    endmethod    
    
    method removeSubAnimation takes subanimtype anim returns nothing
        call SpecialEffect(this).removeSubAnimation(anim)
    endmethod
    
    method clearSubAnimations takes nothing returns nothing
        call SpecialEffect(this).clearSubAnimations()
    endmethod
endmodule

endlibrary