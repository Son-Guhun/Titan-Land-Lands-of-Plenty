library DecorationSFX requires SpecialEffect
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


private struct DecorationEffectBlock extends array

    static constant integer BLOCK_SIZE = 2048

    //! runtextmacro TableStruct_NewStructField("effects","LinkedHashSet")
    
    static method get takes real x, real y returns DecorationEffectBlock
        return GetCustomTileId(.BLOCK_SIZE, x, y)
    endmethod

endstruct

struct DecorationEffect extends array
    method operator effect takes nothing returns effect
        return SpecialEffect(this).effect
    endmethod
    
    method operator unitType takes nothing returns integer
        return SpecialEffect(this).unitType
    endmethod
    
    //! runtextmacro HashStruct_SetHashtableWrapper("SpecialEffect_hT")
    //! runtextmacro HashStruct_NewPrimitiveGetterSetter("Owner","player")

    method operator x takes nothing returns real
        return BlzGetLocalSpecialEffectX(.effect)
    endmethod
    
    method operator x= takes real value returns nothing
        local effect decoration = .effect
        local real y = BlzGetLocalSpecialEffectY(decoration)
    
        call DecorationEffectBlock.get(BlzGetLocalSpecialEffectX(decoration), y).effects.remove(this)
        call DecorationEffectBlock.get(value, y).effects.append(this)
        call BlzSetSpecialEffectX(decoration, value)
        
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
        
        set decoration = null
    endmethod
    
    method operator height takes nothing returns real
        return SpecialEffect(this).height
    endmethod
    
    method operator height= takes real value returns nothing
        set SpecialEffect(this).height = value
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
        set SpecialEffect(this).color = value
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
    
    static method create takes player playerid, integer unitType, real x, real y returns DecorationEffect
        local integer this = SpecialEffect.create(unitType, x, y)
        call .setOwner(playerid)
        call DecorationEffectBlock.get(x, y).effects.append(this)
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        local effect e = .effect
        call DecorationEffectBlock.get(BlzGetLocalSpecialEffectX(e), BlzGetLocalSpecialEffectY(e)).effects.remove(this)
        
        call SpecialEffect(this).destroy()
        set e = null
    endmethod

endstruct

//! runtextmacro GenerateStructLHS("DecorationEffect")

function AreCoordsInRectangle takes real x, real y, real minX, real minY, real maxX, real maxY returns boolean
    return x >= minX and x <= maxX and y >= minY and y <= maxY
endfunction

// The Sets returned by this fucntion are not meant to persists, they are meant solely for iteration.
// The structs are not reference-counted, and they may be replaced by other effects after removed.
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

// The Sets returned by this fucntion are not meant to persists, they are meant solely for iteration.
// The structs are not reference-counted, and they may be replaced by other effects after removed.
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

function EnumDecorationsOfPlayer takes player whichPlayer returns LinkedHashSet_DecorationEffect
    local integer lastId = DecorationEffectBlock.get(WorldBounds.maxX, WorldBounds.maxY)
    local integer i = 0
    local LinkedHashSet decorations
    local DecorationEffect decoration
    local LinkedHashSet result = LinkedHashSet.create()
    
    loop
    exitwhen i > lastId
        set decorations = DecorationEffectBlock(i).effects
        set decoration = decorations.begin()
        loop
            exitwhen decoration == decorations.end()
            if decoration.getOwner() == whichPlayer then
                call result.append(decoration)
            endif
            set decoration = decorations.next(decoration)
        endloop
        set i = i + 1
    endloop
    
    return result
endfunction

function Test takes nothing returns nothing
    local LinkedHashSet test = EnumDecorationsOfPlayer(Player(0))
    local integer  i = test.begin()

    loop
    exitwhen i == test.end()
        call BJDebugMsg(I2S(i))
        set i = test.next(i)
    endloop
    
    call test.destroy()
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
        
        call Test()
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary