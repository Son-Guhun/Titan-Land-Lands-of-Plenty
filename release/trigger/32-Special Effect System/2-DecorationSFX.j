library DecorationSFX requires SpecialEffect, TableStruct

globals
    public constant boolean USE_CUSTOM_PLAYER_COLORS = true
endglobals

//! novjass
/*Doc:
    A struct that extends SpecialEffect. These effects are tracked on the map and can be enumerated
    using the functions provided by this library's API.
*/
struct DecorationEffect extends array

    real x
    real y

    method getOwner takes nothing returns player
    
    method setOwner takes player newOwner returns nothing
    
    static method create takes player id, integer unitType, real x, real y returns DecorationEffect
    
    method destroy takes nothing returns nothing
    
endstruct

// Struct defined using LinkedHashSet generics
struct LinkedHashSet_DecorationEffect extends array


// The Sets returned by these fucntions are not meant to persist, they are meant solely for iteration.
// DecorationEffects are not reference-counted, and they may be replaced by other effects after removed.
function EnumDecorationsInRect takes real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
function EnumDecorationsOfPlayerInRect takes player whichPlayer, real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect

'                                         Source Code                                              '
//! endnovjass

private struct PlayerData extends array
    
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

    static constant integer BLOCK_SIZE = 2048

    //! runtextmacro TableStruct_NewStructField("effects","LinkedHashSet")
    
    static method get takes real x, real y returns DecorationEffectBlock
        return GetCustomTileId(.BLOCK_SIZE, x, y)
    endmethod

endstruct

struct DecorationEffect extends array
 
    
    //! runtextmacro HashStruct_SetHashtableWrapper("SpecialEffect_hT")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("owner","integer")
    //! runtextmacro HashStruct_NewReadonlyBooleanFieldWithDefault("hasCustomColor","false")
    
    method operator effect takes nothing returns effect
        return SpecialEffect(this).effect
    endmethod
    
    method operator unitType takes nothing returns integer
        return SpecialEffect(this).unitType
    endmethod
    
    method operator height takes nothing returns real
        return SpecialEffect(this).height
    endmethod
    
    method operator height= takes real value returns nothing
        set SpecialEffect(this).height = value
    endmethod

    method operator x takes nothing returns real
        return BlzGetLocalSpecialEffectX(.effect)
    endmethod
    
    method operator x= takes real value returns nothing
        local effect decoration = .effect
        local real y = BlzGetLocalSpecialEffectY(decoration)
    
        call DecorationEffectBlock.get(BlzGetLocalSpecialEffectX(decoration), y).effects.remove(this)
        call DecorationEffectBlock.get(value, y).effects.append(this)
        call BlzSetSpecialEffectX(decoration, value)
        call BlzSetSpecialEffectHeight(.effect, .height)
        
        
        set decoration = null
    endmethod
    
    method operator y takes nothing returns real
        return BlzGetLocalSpecialEffectY(.effect)
    endmethod
    
    method operator y= takes real value returns nothing
        local effect decoration = .effect
        local real x = BlzGetLocalSpecialEffectX(decoration)
    
        call DecorationEffectBlock.get(x, BlzGetLocalSpecialEffectY(decoration)).effects.remove(this)
        call DecorationEffectBlock.get(x, value).effects.append(this)
        call BlzSetSpecialEffectY(decoration, value)
        call BlzSetSpecialEffectHeight(.effect, .height)
        
        set decoration = null
    endmethod
    
    method operator yaw takes nothing returns real
        return SpecialEffect(this).yaw
    endmethod
    
    method operator yaw= takes real value returns nothing
        set SpecialEffect(this).yaw = value
    endmethod
    
    method operator pitch takes nothing returns real
        return SpecialEffect(this).pitch
    endmethod
    
    method operator pitch= takes real value returns nothing
        set SpecialEffect(this).pitch = value
    endmethod
    
    method operator roll takes nothing returns real
        return SpecialEffect(this).roll
    endmethod
    
    method operator roll= takes real value returns nothing
        set SpecialEffect(this).roll = value
    endmethod
    
    method setOrientation takes real yaw, real pitch, real roll returns nothing
        call SpecialEffect(this).setOrientation(yaw, pitch, roll)
    endmethod
    
    method operator color takes nothing returns integer
        return SpecialEffect(this).color
    endmethod
    
    method operator color= takes integer value returns nothing
        set .hasCustomColor = true
        set SpecialEffect(this).color = value
    endmethod
    
    method resetColor takes nothing returns nothing
        set .hasCustomColor = false
        set SpecialEffect(this).color = PlayerData(.owner).color
    endmethod
    
    method operator scaleX takes nothing returns real
        return SpecialEffect(this).scaleX
    endmethod
    
    method operator scaleY takes nothing returns real
        return SpecialEffect(this).scaleY
    endmethod
    
    method operator scaleZ takes nothing returns real
        return SpecialEffect(this).scaleZ
    endmethod
    
    method setScale takes real scaleX, real scaleY, real scaleZ returns nothing
        call SpecialEffect(this).setScale(scaleX, scaleY, scaleZ)
    endmethod
    
    method operator red takes nothing returns integer
        return SpecialEffect(this).red
    endmethod
    
    method operator green takes nothing returns integer
        return SpecialEffect(this).green
    endmethod
    
    method operator blue takes nothing returns integer
        return SpecialEffect(this).blue
    endmethod
    
    method setVertexColor takes integer red, integer green, integer blue returns nothing
        call SpecialEffect(this).setVertexColor(red, green, blue)
    endmethod
    
    method operator alpha takes nothing returns integer
        return SpecialEffect(this).alpha
    endmethod
    
    method operator alpha= takes integer alpha returns nothing
        set SpecialEffect(this).alpha = alpha
    endmethod
    
    method operator animationSpeed takes nothing returns real
        return SpecialEffect(this).animationSpeed
    endmethod
    
    method operator animationSpeed= takes real value returns nothing
        set SpecialEffect(this).animationSpeed = value
    endmethod
    
    method operator subanimations takes nothing returns LinkedHashSet
        return SpecialEffect(this).subanimations
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
    
    static method convertSpecialEffect takes player playerid, SpecialEffect sfx, boolean useCustomColor returns DecorationEffect
        if useCustomColor then
            set DecorationEffect(sfx).owner = GetHandleId(playerid)
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

function EnumDecorationsInRect takes real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
    local real x = minX
    
    local integer i
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local integer maxI = DecorationEffectBlock.get(maxX,maxY)
    local integer maxJ
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set maxJ = DecorationEffectBlock.get(x,maxY)
        set i = DecorationEffectBlock.get(x,minY)
        exitwhen i > maxI
        loop
            exitwhen i > maxJ
            set decorations = DecorationEffectBlock(i).effects
            set decoration = decorations.begin()
            loop
                exitwhen decoration == decorations.end()
                set e = decoration.effect
                if AreCoordsInRectangle(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e), minX, minY, maxX, maxY) then
                    call result.append(decoration)
                endif
                set decoration = decorations.next(decoration)
            endloop
            set i = i + 1
        endloop
        set x = x + DecorationEffectBlock.BLOCK_SIZE
    endloop
    
    return result
endfunction

function EnumDecorationsOfPlayerInRect takes player whichPlayer, real minX, real minY, real maxX, real maxY returns LinkedHashSet_DecorationEffect
    local real x = minX
    
    local integer i
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local integer maxI = DecorationEffectBlock.get(maxX,maxY)
    local integer maxJ
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set maxJ = DecorationEffectBlock.get(x,maxY)
        set i = DecorationEffectBlock.get(x,minY)
        exitwhen i > maxI
        loop
            exitwhen i > maxJ
            set decorations = DecorationEffectBlock(i).effects
            set decoration = decorations.begin()
            loop
                exitwhen decoration == decorations.end()
                set e = decoration.effect
                if AreCoordsInRectangle(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e), minX, minY, maxX, maxY) and decoration.getOwner() == whichPlayer then
                    call result.append(decoration)
                endif
                set decoration = decorations.next(decoration)
            endloop
            set i = i + 1
        endloop
        set x = x + DecorationEffectBlock.BLOCK_SIZE
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
    local real minX = centerX - radius
    local real minY = centerY - radius
    local real maxX = centerX + radius
    local real maxY = centerY + radius
    
    local real x = minX
    
    local integer i
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local integer maxI = DecorationEffectBlock.get(maxX,maxY)
    local integer maxJ
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set maxJ = DecorationEffectBlock.get(x,maxY)
        set i = DecorationEffectBlock.get(x,minY)
        exitwhen i > maxI
        loop
            exitwhen i > maxJ
            set decorations = DecorationEffectBlock(i).effects
            set decoration = decorations.begin()
            loop
                exitwhen decoration == decorations.end()
                set e = decoration.effect
                if Distance(BlzGetLocalSpecialEffectX(e), centerX, BlzGetLocalSpecialEffectY(e), centerY) <= radius then
                    call result.append(decoration)
                endif
                set decoration = decorations.next(decoration)
            endloop
            set i = i + 1
        endloop
        set x = x + DecorationEffectBlock.BLOCK_SIZE
    endloop
    
    return result
endfunction

function EnumDecorationsOfPlayerInRange takes player whichPlayer, real centerX, real centerY, real radius returns LinkedHashSet_DecorationEffect
    local real minX = centerX - radius
    local real minY = centerY - radius
    local real maxX = centerX + radius
    local real maxY = centerY + radius
    
    local real x = minX
    
    local integer i
    local LinkedHashSet decorations
    local DecorationEffect decoration
    
    local integer maxI = DecorationEffectBlock.get(maxX,maxY)
    local integer maxJ
    
    local LinkedHashSet result = LinkedHashSet.create()
    local effect e
    
    loop
        set maxJ = DecorationEffectBlock.get(x,maxY)
        set i = DecorationEffectBlock.get(x,minY)
        exitwhen i > maxI
        loop
            exitwhen i > maxJ
            set decorations = DecorationEffectBlock(i).effects
            set decoration = decorations.begin()
            loop
                exitwhen decoration == decorations.end()
                set e = decoration.effect
                if Distance(BlzGetLocalSpecialEffectX(e), centerX, BlzGetLocalSpecialEffectY(e), centerY) <= radius and decoration.getOwner() == whichPlayer then
                    call result.append(decoration)
                endif
                set decoration = decorations.next(decoration)
            endloop
            set i = i + 1
        endloop
        set x = x + DecorationEffectBlock.BLOCK_SIZE
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
        
        call InitCustomTiles(DecorationEffectBlock.BLOCK_SIZE)
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

endlibrary