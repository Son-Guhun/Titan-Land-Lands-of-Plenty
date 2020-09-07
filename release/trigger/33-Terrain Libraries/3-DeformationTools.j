library DeformationTools requires Deformations, optional DeformationToolsHooks
/*
Defines tools to create deformations in along a large area.

The optional library DeformationToolsHooks is generally used to fix unit/structure heights after applying
deformations.

API:
public function Hill takes real x0, real y0, real intensity, integer radius returns nothing

// Sets all terrain cells to the same height.
public function Plateau takes real x0, real y0, real depth, integer radius, boolean circle returns nothing

// Uses a Gaussian Blur to smooth terrain.
public function Smooth takes real x0, real y0, integer radius, boolean circle
*/

// This function should inline
private function DistanceSquared takes real x, real x0, real y, real y0 returns real
    return Pow(x - x0, 2.) + Pow(y - y0, 2.)
endfunction

// This function should inline
private function Distance takes real x, real x0, real y, real y0 returns real
    return SquareRoot(DistanceSquared(x,x0,y,y0))
endfunction

public function Hill takes real x0, real y0, real intensity, integer radius returns nothing
    local integer i = -radius
    local integer j
    
    local real x = x0 - radius*128.
    local real y
    
    local Deformation d
    
    local real maxdistance = radius*128. + 64.
    
    
    
    loop
    exitwhen i > radius
        set j = -radius
        set y = y0 - radius*128.
        loop
        exitwhen j > radius
            set d = Deformation.fromCoords(x, y)
            set d.depth = d.depth + intensity*SquareRoot(RMaxBJ(maxdistance*maxdistance - DistanceSquared(x,x0,y,y0), 0.))
            set j = j + 1
            set y = y + 128.
        endloop
        set i = i + 1
        set x = x + 128.
    endloop
    
    //! runtextmacro optional DeformationToolsHook("x0", "y0", "radius")
endfunction

public function Plateau takes real x0, real y0, real depth, integer radius, boolean circle returns nothing
    local integer i = -radius
    local integer j
    
    local real x = x0 - radius*128.
    local real y

    local real maxdistance = radius*128. + 64.
    
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
    
    //! runtextmacro optional DeformationToolsHook("x0", "y0", "radius")
endfunction

globals
    private HashTable table = 0
endglobals

private struct KERNEL extends array

    // First Row
    static constant method operator dist2x2y takes nothing returns real
        return 0.000002
    endmethod
    
    static constant method operator dist2x1y takes nothing returns real
        return 0.000212
    endmethod
    
    static constant method operator dist2x0y takes nothing returns real
        return 0.000922
    endmethod
    
    // Second Row
    static constant method operator dist1x2y takes nothing returns real
        return 	0.000212
    endmethod
    
    static constant method operator dist1x1y takes nothing returns real
        return 	0.024745
    endmethod
    
    static constant method operator dist1x0y takes nothing returns real
        return 	0.107391
    endmethod
    
    // Third (middle) row
    static constant method operator dist0x2y takes nothing returns real
        return 	0.000922
    endmethod
    
    static constant method operator dist0x1y takes nothing returns real
        return 	0.107391
    endmethod
    
    static constant method operator dist0x0y takes nothing returns real
        return 	0.466066
    endmethod

endstruct

public function Smooth takes real x0, real y0, integer radius, boolean circle returns nothing
    local integer i = -radius-2
    local integer j
    local real depth
    
    local real x = x0 - (radius+2)*128.
    local real y

    local real maxdistance = radius*128. + 64.
    
    if table == 0 then
        set table = HashTable.create()
    endif
    
    loop
    exitwhen i > radius+2
        set j = -radius-2
        set y = y0 - (radius+2)*128.
        loop
        exitwhen j > radius+2
            set table[i].real[j] = Deformation.fromCoords(x, y).depth
            set j = j + 1
            set y = y + 128.
        endloop
        set i = i + 1
        set x = x + 128.
    endloop
    
    set i = -radius
    set x = x0 - radius*128
    
    loop
    exitwhen i > radius
        set j = -radius
        set y = y0 - radius*128.
        loop
        exitwhen j > radius
            set depth = 0
            if circle and Distance(x,x0,y,y0) < maxdistance then
                set Deformation.fromCoords(x, y).depth = depth
            else
                
                set depth = depth + KERNEL.dist2x2y*table[i-2].real[j-2]
                set depth = depth + KERNEL.dist2x1y*table[i-2].real[j-1]
                set depth = depth + KERNEL.dist2x0y*table[i-2].real[j]
                set depth = depth + KERNEL.dist2x1y*table[i-2].real[j+1]
                set depth = depth + KERNEL.dist2x2y*table[i-2].real[j+2]
            
                set depth = depth + KERNEL.dist1x2y*table[i-1].real[j-2]
                set depth = depth + KERNEL.dist1x1y*table[i-1].real[j-1]
                set depth = depth + KERNEL.dist1x0y*table[i-1].real[j]
                set depth = depth + KERNEL.dist1x1y*table[i-1].real[j+1]
                set depth = depth + KERNEL.dist1x2y*table[i-1].real[j+2]
                
                set depth = depth + KERNEL.dist0x2y*table[i].real[j-2]
                set depth = depth + KERNEL.dist0x1y*table[i].real[j-1]
                set depth = depth + KERNEL.dist0x0y*table[i].real[j]
                set depth = depth + KERNEL.dist0x1y*table[i].real[j+1]
                set depth = depth + KERNEL.dist0x2y*table[i].real[j+2]
                
                set depth = depth + KERNEL.dist1x2y*table[i+1].real[j-2]
                set depth = depth + KERNEL.dist1x1y*table[i+1].real[j-1]
                set depth = depth + KERNEL.dist1x0y*table[i+1].real[j]
                set depth = depth + KERNEL.dist1x1y*table[i+1].real[j+1]
                set depth = depth + KERNEL.dist1x2y*table[i+1].real[j+2]
                
                set depth = depth + KERNEL.dist2x2y*table[i+2].real[j-2]
                set depth = depth + KERNEL.dist2x1y*table[i+2].real[j-1]
                set depth = depth + KERNEL.dist2x0y*table[i+2].real[j]
                set depth = depth + KERNEL.dist2x1y*table[i+2].real[j+1]
                set depth = depth + KERNEL.dist2x2y*table[i+2].real[j+2]
                
                set Deformation.fromCoords(x, y).depth = depth
            endif
            set j = j + 1
            set y = y + 128.
        endloop
        set i = i + 1
        set x = x + 128.
    endloop
    
    //! runtextmacro optional DeformationToolsHook("x0", "y0", "radius")
endfunction



endlibrary