// Missing Facing hook
library FuncHooks requires AttachedSFX, PathingMaps

//! runtextmacro FuncHooks("Orgl", "SetUnitX", "unit u, real x", "u,x")
//! runtextmacro FuncHooks("Orgl", "SetUnitY", "unit u, real y", "u,y")
//! runtextmacro FuncHooks("Orgl", "SetUnitPosition", "unit u, real x, real y", "u,x,y")
//! runtextmacro FuncHooks("Orgl", "SetUnitFacing", "unit u, real a", "u,a")
//! runtextmacro FuncHooks("Orgl", "SetUnitFacingTimed", "unit u, real a, real t", "u,a,t")
//! runtextmacro FuncHooks("Orgl", "SetUnitTimeScale", "unit u, real scale", "u,scale")
//! runtextmacro FuncHooks("Orgl", "SetUnitScale", "unit u, real x, real y, real z", "u,x,y,z")
//! runtextmacro FuncHooks("Orgl", "SetUnitFlyHeight", "unit u, real h, real r", "u,h,r")
//! runtextmacro FuncHooks("Orgl", "AddUnitAnimationProperties", "unit u, string p, boolean a", "u,p,a")
//! runtextmacro FuncHooks("Orgl", "SetUnitColor", "unit u, playercolor c", "u,c")
//! runtextmacro FuncHooks("Orgl", "SetUnitVertexColor", "unit u, integer r, integer g, integer b, integer a", "u,r,g,b,a")

//! runtextmacro optional FuncHooks_Definitions()

//! runtextmacro FuncHooks("Hkd", "SetUnitX", "unit u, real x", "u,x")
//! runtextmacro FuncHooks("Hkd", "SetUnitY", "unit u, real y", "u,y")
//! runtextmacro FuncHooks("Hkd", "SetUnitPosition", "unit u, real x, real y", "u,x,y")
//! runtextmacro FuncHooks("Hkd", "SetUnitFacing", "unit u, real a", "u,a")
//! runtextmacro FuncHooks("Hkd", "SetUnitFacingTimed", "unit u, real a, real t", "u,a,t")
//! runtextmacro FuncHooks("Hkd", "SetUnitTimeScale", "unit u, real scale", "u,scale")
//! runtextmacro FuncHooks("Hkd", "SetUnitScale", "unit u, real x, real y, real z", "u,x,y,z")
//! runtextmacro FuncHooks("Hkd", "SetUnitFlyHeight", "unit u, real h, real r", "u,h,r")
//! runtextmacro FuncHooks("Hkd", "AddUnitAnimationProperties", "unit u, string p, boolean a", "u,p,a")
//! runtextmacro FuncHooks("Hkd", "SetUnitColor", "unit u, playercolor c", "u,c")
//! runtextmacro FuncHooks("Hkd", "SetUnitVertexColor", "unit u, integer r, integer g, integer b, integer a", "u,r,g,b,a")

endlibrary

//! textmacro FuncHooks takes prefix, name, typedArgs, args
    function $prefix$$name$ takes $typedArgs$ returns nothing
        call $name$($args$)
    endfunction
//! endtextmacro

//! textmacro DefineHooks
private function SetUnitX takes unit u, real x returns nothing
    call HkdSetUnitX(u, x)
endfunction

private function SetUnitY takes unit u, real y returns nothing
    call HkdSetUnitY(u, y)
endfunction

private function SetUnitPosition takes unit u, real x, real y returns nothing
    call HkdSetUnitPosition(u, x, y)
endfunction

private function SetUnitFacing takes unit u, real a returns nothing
    call HkdSetUnitFacing(u, a)
endfunction

private function SetUnitFacingTimed takes unit u, real a, real t returns nothing
    call HkdSetUnitFacingTimed(u, a, t)
endfunction

private function SetUnitTimeScale takes unit u, real scale returns nothing
    call HkdSetUnitTimeScale(u,scale)
endfunction

private function SetUnitScale takes unit u, real x, real y, real z returns nothing
    call HkdSetUnitScale(u,x,y,z)
endfunction

private function SetUnitFlyHeight takes unit u, real h, real r returns nothing
    call HkdSetUnitFlyHeight(u,h,r)
endfunction

private function AddUnitAnimationProperties takes unit u, string p, boolean a returns nothing
    call HkdAddUnitAnimationProperties(u,p,a)
endfunction

private function SetUnitColor takes unit u, playercolor c returns nothing
    call HkdSetUnitColor(u,c)
endfunction

private function SetUnitVertexColor takes unit u, integer r, integer g, integer b, integer a returns nothing
    call HkdSetUnitVertexColor(u,r,g,b,a)
endfunction

//! endtextmacro