function Vtrack_SOURCE takes nothing returns integer
    return 0
endfunction

function Vtrack_ABILITY takes nothing returns integer
    return 1
endfunction

// These functions are used to keep track of which units have been affected by a certain spell!

//TODO: Create a trigger that fires when the unit is removed from the game. This way, you can clear
// tracker data specifically for each unit!!
// trigger is saved on negative handleId of source?
// trigger uses agent system to save unit
function Vtrack_Initialize takes unit source, integer abilityId returns group
    local integer unitId = GetHandleId(source)
    local trigger trig = CreateTrigger()
    local integer trigKey = CreateAgentKey(trig)
    
    call AgentSaveAgent(  trigKey, Vtrack_SOURCE(),  source)
    call AgentSaveInteger(trigKey, Vtrack_ABILITY(), abilityId)
    
    
    
    
    return null
endfunction

function Vtrack_Destroy takes unit source, integer abilityId returns nothing
    // destroy gruup
    // remove saved handle
    // destroy trigger
endfunction



function Vtrack_GetVictims takes unit source, integer abilityId returns group
    return LoadGroupHandle(udg_Hashtable_2, abilityId, GetHandleId(source))
endfunction

function Vtrack_AddVictim takes unit source, integer abilityId, unit victim returns nothing
    call GroupAddUnit(Vtrack_GetVictims(source, abilityId), victim)
endfunction

function Vtrack_RemoveVictom takes unit source, integer abilityId, unit victim returns nothing
    call GroupRemoveUnit(Vtrack_GetVictims(source, abilityId), victim)
endfunction

//===========================================================================
//! novjass
function InitTrig_Victim_Tracker takes nothing returns nothing
endfunction
//! endnovjass
