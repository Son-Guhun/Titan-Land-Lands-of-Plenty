library DeformationTools requires Deformations, DecorationSFX, AttachedSFX
/*
Defines tools to create deformations in along a large area.

API:
public function Hill takes real x0, real y0, real intensity, integer radius returns nothing

public function Plateau takes real x0, real y0, real depth, integer radius, boolean circle returns nothing
*/

// This function should inline
private function DistanceSquared takes real x, real x0, real y, real y0 returns real
    return Pow(x - x0, 2.) + Pow(y - y0, 2.)
endfunction

// This function should inline
private function Distance takes real x, real x0, real y, real y0 returns real
    return SquareRoot(DistanceSquared(x,x0,y,y0))
endfunction

function UpdateEffects takes LinkedHashSet_DecorationEffect decorations, group units returns nothing
    local SpecialEffect deco = decorations.begin()
    local integer i = 0
    local unit u

    loop
    exitwhen deco == decorations.end()
        set deco.height = deco.height
        call BJDebugMsg(I2S(deco))
        set deco = decorations.next(deco)
    endloop
    call decorations.destroy()
    
    loop
        set u = BlzGroupUnitAt(units, i)
        exitwhen u == null
        set deco = GetUnitAttachedEffect(u)
        if deco != 0 then
            set deco.height = deco.height
        endif
        set i = i + 1
    endloop
    call DestroyGroup(units)
endfunction

public function Hill takes real x0, real y0, real intensity, integer radius returns nothing
    local integer i = -radius
    local integer j
    
    local real x = x0 - radius*128.
    local real y
    
    local Deformation d
    local real step = intensity
    
    local real maxdistance = radius*128. + 64.
    local group units = CreateGroup()
    
    
    
    loop
    exitwhen i > radius
        set j = -radius
        set y = y0 - radius*128.
        loop
        exitwhen j > radius
            set d = Deformation.fromCoords(x, y)
            set d.depth = d.depth + step*SquareRoot(RMaxBJ(maxdistance*maxdistance - DistanceSquared(x,x0,y,y0), 0.))
            set j = j + 1
            set y = y + 128.
        endloop
        set i = i + 1
        set x = x + 128.
    endloop
    
    call GroupEnumUnitsInRange(units, x0, y0, maxdistance, null)
    call UpdateEffects(EnumDecorationsInRange(x0, y0, maxdistance), units)
endfunction

public function Plateau takes real x0, real y0, real depth, integer radius, boolean circle returns nothing
    local integer i = -radius
    local integer j
    
    local real x = x0 - radius*128.
    local real y

    local real maxdistance = radius*128. + 64.
    local group units = CreateGroup()
    local rect r = Rect(x0, y0, x0+radius, y0+radius)
    
    loop
    exitwhen i > radius
        set j = -radius
        set y = y0 - radius*128.
        loop
        exitwhen j > radius
            if circle and Distance(x,x0,y,y0) < maxdistance then
                set Deformation.fromCoords(x, y).depth = depth
            else
                set Deformation.fromCoords(x, y).depth = depth
            endif
            set j = j + 1
            set y = y + 128.
        endloop
        set i = i + 1
        set x = x + 128.
    endloop
    
    call GroupEnumUnitsInRect(units, r, null)
    call RemoveRect(r)
    call UpdateEffects(EnumDecorationsInRect(x0, y0, x0+radius, y0+radius), units)
endfunction



endlibrary