function K2DItemCheckXY takes real x, real y returns boolean
    local real newX
    local real newY
    call SetItemPosition(udg_K2DItem, x, y)
    set newX = GetWidgetX(udg_K2DItem)
    set newY = GetWidgetY(udg_K2DItem)
    return (newX >= x-0.05 and newX <= x+0.05) and (newY >= y-0.05 and newY <= y+0.05)
endfunction

function K2DItemCheckAxis takes real x, real y returns boolean
    local real x2 = x*udg_K2DRadius[udg_UDex]
    local real y2 = y*udg_K2DRadius[udg_UDex]
    set x = udg_K2DX + x2
    set y = udg_K2DY + y2
    if K2DItemCheckXY(x, y) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
        set x = udg_K2DX - x2
        set y = udg_K2DY - y2
        return K2DItemCheckXY(x, y) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
    endif
    return false
endfunction

function K2DItemCheck takes nothing returns boolean
    local boolean result = K2DItemCheckXY(udg_K2DX, udg_K2DY)
    
    //Only perform additional pathing checks if the unit has a larger collision.
    if result and udg_Knockback2DRobustPathing > 0 and udg_K2DRadius[udg_UDex] > 0 then

        //Check horizontal axis of unit to make sure nothing is going to collide
        set result = K2DItemCheckAxis(udg_K2DCosH[udg_UDex], udg_K2DSinH[udg_UDex])
        
        //Check vertical axis of unit to ensure nothing will collide
        set result = result and K2DItemCheckAxis(udg_K2DCos[udg_UDex], udg_K2DSin[udg_UDex])
        
        if result and udg_Knockback2DRobustPathing == 2 and udg_K2DRadius[udg_UDex] > 16 then

            //Check diagonal axis of unit if more thorough pathing is desired
            set result = K2DItemCheckAxis(udg_K2DCosD1[udg_UDex], udg_K2DSinD1[udg_UDex])
            set result = result and K2DItemCheckAxis(udg_K2DCosD2[udg_UDex], udg_K2DSinD2[udg_UDex])
        endif
    endif
    
    //Reset item so it won't interfere with the map
    call SetItemPosition(udg_K2DItem, udg_K2DMaxX, udg_K2DMaxY)
    call SetItemVisible(udg_K2DItem, false)
    
    return result
endfunction

function K2DItemFilter takes nothing returns boolean
    //Check for visible items, temporarily hide them and add them to the filter.
    if IsItemVisible(GetFilterItem()) then
        call SetItemVisible(GetFilterItem(), false)
        return true
    endif
    return false
endfunction
function K2DItemCode takes nothing returns nothing
    //Perform the item-pathing check only once, then unhide those filtered items
    if not udg_K2DItemsFound then
        set udg_K2DItemsFound = true
        set udg_K2DItemOffset = K2DItemCheck()
    endif
    call SetItemVisible(GetEnumItem(), true)
endfunction

function K2DKillDest takes nothing returns nothing
    local real x
    local real y
    //Handle destruction of debris
    set bj_destRandomCurrentPick = GetEnumDestructable()
    if GetWidgetLife(bj_destRandomCurrentPick) > 0.405 and IssueTargetOrder(udg_K2DDebrisKiller, udg_Knockback2DTreeOrDebris, bj_destRandomCurrentPick) then
        set x = GetWidgetX(bj_destRandomCurrentPick) - udg_K2DX
        set y = GetWidgetY(bj_destRandomCurrentPick) - udg_K2DY
        if x*x + y*y <= udg_K2DDestRadius[udg_UDex] then
            call KillDestructable(bj_destRandomCurrentPick)
        endif
    endif
endfunction

function K2DEnumDests takes nothing returns nothing
    call MoveRectTo(udg_K2DRegion, udg_K2DX, udg_K2DY)
    if udg_K2DKillTrees[udg_UDex] then
        call SetUnitX(udg_K2DDebrisKiller, udg_K2DX)
        call SetUnitY(udg_K2DDebrisKiller, udg_K2DY)
        call EnumDestructablesInRect(udg_K2DRegion, null, function K2DKillDest)
    endif
endfunction

function Knockback2DCheckXY takes real x, real y returns boolean
    set udg_K2DX = x + udg_K2DVelocity[udg_UDex]*udg_K2DCos[udg_UDex]
    set udg_K2DY = y + udg_K2DVelocity[udg_UDex]*udg_K2DSin[udg_UDex]
    if udg_K2DSimple[udg_UDex] then
        //A "pull" effect or a missile system does not require complex pathing.
        if udg_K2DX <= udg_K2DMaxX and udg_K2DX >= udg_K2DMinX and udg_K2DY <= udg_K2DMaxY and udg_K2DY >= udg_K2DMinY then
            call K2DEnumDests()
            return true
        endif
        return false
    elseif udg_K2DFlying[udg_UDex] then
        return not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_FLYABILITY)
    elseif not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_WALKABILITY) then
        call K2DEnumDests()
        set udg_K2DItemOffset = false
        call EnumItemsInRect(udg_K2DRegion, Filter(function K2DItemFilter), function K2DItemCode)
        if udg_K2DItemsFound then
            //If items were found, the check was already performed.
            set udg_K2DItemsFound = false
        else
            //Otherwise, perform the check right now.
            set udg_K2DItemOffset = K2DItemCheck()
        endif
        return udg_K2DItemOffset
    endif
    return udg_K2DAmphibious[udg_UDex] and not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_FLOATABILITY)
endfunction

function Knockback2DApplyAngle takes real angle returns nothing
    set angle = ModuloReal(angle, udg_Radians_Turn)
    set udg_K2DCos[udg_UDex] = Cos(angle)
    set udg_K2DSin[udg_UDex] = Sin(angle)
    set udg_K2DAngle[udg_UDex] = angle
    if udg_Knockback2DRobustPathing > 0 then
        set angle = ModuloReal(angle + udg_Radians_QuarterTurn, udg_Radians_Turn)
        set udg_K2DCosH[udg_UDex] = Cos(angle)
        set udg_K2DSinH[udg_UDex] = Sin(angle)
        if udg_Knockback2DRobustPathing == 2 and udg_K2DRadius[udg_UDex] > 16 then
            set angle = ModuloReal(angle + udg_Radians_QuarterPi, udg_Radians_Turn)
            set udg_K2DCosD1[udg_UDex] = Cos(angle)
            set udg_K2DSinD1[udg_UDex] = Sin(angle)
            set angle = ModuloReal(angle + udg_Radians_QuarterTurn, udg_Radians_Turn)
            set udg_K2DCosD2[udg_UDex] = Cos(angle)
            set udg_K2DSinD2[udg_UDex] = Sin(angle)
        endif
    endif
endfunction

function Knockback2DLooperLoop takes nothing returns nothing
    local integer i = udg_UDex
    local unit u
    local real x
    local real y
    
set udg_UDex = i
    set udg_K2DTimeLeft[i] = udg_K2DTimeLeft[i] - udg_K2DTimeout
    set udg_K2DDistanceLeft[i] = udg_K2DDistanceLeft[i] - udg_K2DVelocity[i]
    set u = udg_UDexUnits[i]
    
    if udg_K2DTimeLeft[i] > 0.00 then
        if udg_K2DTimeLeft[i] < udg_K2DHeightThreshold[i] and udg_K2DHeightThreshold[i] != 0.00 then
            call SetUnitFlyHeight(u, GetUnitDefaultFlyHeight(u), GetUnitFlyHeight(u) - GetUnitDefaultFlyHeight(u)/udg_K2DHeightThreshold[i])
            set udg_K2DHeightThreshold[i] = 0.00
        endif
        if udg_K2DPause[i] then
            set x = udg_K2DLastX[i]
            set y = udg_K2DLastY[i]
        else
            set x = GetUnitX(u)
            set y = GetUnitY(u)
        endif
    
        if not Knockback2DCheckXY(x, y) then
            if not udg_K2DFreeze[i] and IsTriggerEnabled(udg_K2DImpact[i]) and TriggerEvaluate(udg_K2DImpact[i]) then
                call TriggerExecute(udg_K2DImpact[i])
            endif
            if udg_K2DBounce[i] then
                call Knockback2DApplyAngle(udg_Radians_Turn - udg_K2DAngle[i])
                if not Knockback2DCheckXY(x, y) then
                    call Knockback2DApplyAngle(udg_K2DAngle[i] + bj_PI)
                    if not Knockback2DCheckXY(x, y) then
                        call Knockback2DApplyAngle(udg_Radians_Turn - udg_K2DAngle[i])
                        set udg_K2DX = x
                        set udg_K2DY = y
                    endif
                endif
            else
                set udg_K2DX = x
                set udg_K2DY = y
                set udg_K2DFreeze[i] = true
            endif
        endif
        call SetUnitX(u, udg_K2DX)
        call SetUnitY(u, udg_K2DY)
        set udg_K2DLastX[i] = udg_K2DX
        set udg_K2DLastY[i] = udg_K2DY
        if udg_K2DFXModel[i] != "" then
            set udg_K2DFXTimeLeft[i] = udg_K2DFXTimeLeft[i] - udg_K2DTimeout
            if udg_K2DFXTimeLeft[i] <= 0.00 then
                set udg_K2DFXTimeLeft[i] = udg_K2DFXRate[i]
                if udg_K2DFlying[i] then
                    call DestroyEffect(AddSpecialEffectTarget(udg_K2DFXModel[i], u, "origin"))
                else
                    call DestroyEffect(AddSpecialEffect(udg_K2DFXModel[i], udg_K2DX, udg_K2DY))
                endif
            endif
        endif
        if udg_K2DCollision[i] >= 0.00 then
            set udg_Knockback2DSource = u
            call GroupEnumUnitsInRange(bj_lastCreatedGroup, udg_K2DX, udg_K2DY, 200.00, null)
            call GroupRemoveUnit(bj_lastCreatedGroup, u)
            loop
                set udg_Knockback2DUnit = FirstOfGroup(bj_lastCreatedGroup)
                exitwhen udg_Knockback2DUnit == null
                call GroupRemoveUnit(bj_lastCreatedGroup, udg_Knockback2DUnit)
                
                if IsUnitInRange(udg_Knockback2DUnit, u, udg_K2DCollision[i]) and udg_K2DFlying[i] == IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_FLYING) and (not IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_STRUCTURE)) and not IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_DEAD) and (udg_K2DUnbiasedCollision[i] or IsUnitAlly(udg_Knockback2DUnit, GetOwningPlayer(u))) and TriggerEvaluate(gg_trg_Knockback_2D) then
                    set udg_Knockback2DAngle = bj_RADTODEG * Atan2(GetUnitY(udg_Knockback2DUnit) - udg_K2DY, GetUnitX(udg_Knockback2DUnit) - udg_K2DX)
                    set udg_Knockback2DDistance = udg_K2DDistanceLeft[i]
                    set udg_Knockback2DBounces = udg_K2DBounce[i]
                    set udg_Knockback2DCollision = udg_K2DCollision[i]
                    if udg_K2DHeight[i] != 0.00 then
                        set udg_Knockback2DHeight = GetUnitFlyHeight(u) - GetUnitDefaultFlyHeight(u)
                    endif
                    set udg_Knockback2DLoopFX = udg_K2DFXModel[i]
                    set udg_Knockback2DTime = udg_K2DTimeLeft[i]
                    set udg_Knockback2DUnbiasedCollision = udg_K2DUnbiasedCollision[i]
                    
                    if udg_K2DCollide[i] != null then
                        call TriggerExecute(udg_K2DCollide[i])
                    endif
                    
                    //call BJDebugMsg(R2S(udg_Knockback2DDistance))

                    call TriggerExecute(gg_trg_Knockback_2D)
                    set udg_Knockback2DSource = u //in case of a recursive knockback
                endif
            endloop
        endif
        set udg_K2DVelocity[i] = udg_K2DVelocity[i] - udg_K2DFriction[i]
    else
        if udg_K2DEnd[i] != null then
            set udg_Knockback2DUnit = u
            call TriggerExecute(udg_K2DEnd[i])
        endif
        call TriggerExecute(gg_trg_Knockback_2D_Destroy)
    endif
    
    set u = null
endfunction

function Knockback2DLooper takes nothing returns nothing
    local integer i = 0
    
    call PauseUnit(udg_K2DDebrisKiller, false)
    
    loop
        set i = udg_K2DNext[i]
        exitwhen i == 0
        set udg_UDex = i
        call ForForce(udg_FORCES_PLAYER[1], function Knockback2DLooperLoop)
    endloop
    
    //Disable dummy after the loop finishes so it doesn't interfere with the map
    call PauseUnit(udg_K2DDebrisKiller, true)
endfunction

//===========================================================================
function StartKnockback2DTimer takes nothing returns nothing
    call TimerStart(udg_K2DTimer, udg_K2DTimeout, true, function Knockback2DLooper)
endfunction