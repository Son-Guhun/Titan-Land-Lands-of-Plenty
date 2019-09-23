/* Functions that are not defined here will not have any hooks attached. To see which functions can be
hooked to, check the FuncHooks library.*/
//! textmacro FuncHooks_Definitions

private function SetUnitPosition takes unit u, real x, real y returns nothing
    call OrglSetUnitPosition(u, x, y)
    
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onSetPosition(u, x, y)
    endif
endfunction

private function SetUnitTimeScale takes unit u, real scale returns nothing
    call OrglSetUnitTimeScale(u,scale)
    
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onSetTimeScale(u, scale)
    endif
endfunction

private function SetUnitScale takes unit u, real x, real y, real z returns nothing
    call OrglSetUnitScale(u,x,y,z)
    
    // Here
endfunction

private function SetUnitFlyHeight takes unit u, real h, real r returns nothing
    call OrglSetUnitFlyHeight(u,h,r)
    
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onSetHeight(u, h, r)
    endif
endfunction

private function AddUnitAnimationProperties takes unit u, string p, boolean a returns nothing
    call OrglAddUnitAnimationProperties(u,p,a)
    
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onAddAnimationProperties(u, p, a)
    endif
endfunction

private function SetUnitColor takes unit u, playercolor c returns nothing
    call OrglSetUnitColor(u,c)
    
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onSetColor(u, c)
    endif
endfunction

private function SetUnitVertexColor takes unit u, integer r, integer g, integer b, integer a returns nothing
    if UnitHasAttachedEffect(u) then
        call AttachedSFX_onSetVertexColor(u, r, g, b, a)
    else
        call OrglSetUnitVertexColor(u,r,g,b,a)
    endif
endfunction


//! endtextmacro
