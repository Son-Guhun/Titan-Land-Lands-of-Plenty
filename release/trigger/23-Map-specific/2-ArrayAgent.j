library ArrayAgent
//===========================================================================
// Agent Key System
// Store data in agents as a 1-time write, 1-time read (only checks for collisions in debug mode)
// Before writing to the same agent, you must Flush the AgentKey

// How to use the system: 
// First, you must use CreateAgentKey() to get the integer used in the Save functions
// After this, you should not call CreateAgentKey() on the same agent again until you have called
// AgentFlush() on the created key.

// This system relies solely on debug messages, and is mainly to help keep code organized and readable,
// by expliciting the temporary nature of the stored data. Use it wisely, and keep this in mind.
//===========================================================================
// Debug functions

globals
    public hashtable hashTable = InitHashtable()
endglobals

function AkeyDebugCreate takes integer agentKey returns nothing
    local integer count = LoadInteger(hashTable, 0, agentKey)
    
    call SaveInteger(hashTable, 0, agentKey, count+1)
    if count > 0 then
        call BJDebugMsg("Created an Agent Key for an agent which already had one!")
    endif
endfunction

function AkeyDebugUncreated takes integer agentKey returns boolean
    if LoadInteger(hashTable, 0, agentKey) == 0 then
        call BJDebugMsg("Accessed ArrayAgent_Hashtable with an invalid Key!!")
        return true
    endif
    return false
endfunction

function AkeyDebugClear takes integer agentKey returns nothing
    if AkeyDebugUncreated(agentKey) then
        call BJDebugMsg("Flushed an Agent Key that was not created!")
    endif
    call RemoveSavedInteger(hashTable, 0, agentKey)
endfunction

function AkeyDebugSave takes integer agentKey, integer whichKey returns nothing
    if HaveSavedBoolean(hashTable, agentKey, whichKey) then
        call BJDebugMsg("Saved in key " + I2S(whichKey) + " while Boolean was stored")
    elseif HaveSavedHandle(hashTable, agentKey, whichKey) then
        call BJDebugMsg("Saved in key " + I2S(whichKey) + " while Handle was stored")
    elseif HaveSavedInteger(hashTable, agentKey, whichKey) then
        call BJDebugMsg("Saved in key " + I2S(whichKey) + " while Integer was stored")
    elseif HaveSavedReal(hashTable, agentKey, whichKey) then
        call BJDebugMsg("Saved in key " + I2S(whichKey) + " while Real was stored")
    elseif HaveSavedString(hashTable, agentKey, whichKey) then
        call BJDebugMsg("Saved in key " + I2S(whichKey) + " while String was stored")
    endif
endfunction

//===========================================================================
// Get Agent Key

function CreateAgentKey takes agent whichAgent returns integer
    debug call AkeyDebugCreate(GetHandleId(whichAgent))
    return GetHandleId(whichAgent)
endfunction

function GetAgentKey takes agent whichAgent returns integer
    debug call AkeyDebugUncreated(GetHandleId(whichAgent))
    return GetHandleId(whichAgent)
endfunction

//===========================================================================
// AgentKeySaveType
function AgentSaveAgent takes integer agentKey, integer whichKey, agent value returns nothing
    debug call AkeyDebugUncreated(agentKey)
    debug call AkeyDebugSave(agentKey, whichKey)
    call SaveAgentHandle(hashTable, agentKey, whichKey, value)
endfunction

function AgentSaveInteger takes integer agentKey, integer whichKey, integer value returns nothing
    debug call AkeyDebugUncreated(agentKey)
    debug call AkeyDebugSave(agentKey, whichKey)
    call SaveInteger(hashTable, agentKey, whichKey, value)
endfunction

function AgentSaveBoolean takes integer agentKey, integer whichKey, boolean value returns nothing
    debug call AkeyDebugUncreated(agentKey)
    debug call AkeyDebugSave(agentKey, whichKey)
    call SaveBoolean(hashTable, agentKey, whichKey, value)
endfunction

function AgentSaveReal takes integer agentKey, integer whichKey, real value returns nothing
    debug call AkeyDebugUncreated(agentKey)
    debug call AkeyDebugSave(agentKey, whichKey)
    call SaveReal(hashTable, agentKey, whichKey, value)
endfunction

function AgentSaveStr takes integer agentKey, integer whichKey, string value returns nothing
    debug call AkeyDebugUncreated(agentKey)
    debug call AkeyDebugSave(agentKey, whichKey)
    call SaveStr(hashTable, agentKey, whichKey, value)
endfunction

//===========================================================================
// AgentKeyLoadType

//Agents
function AgentLoadUnit takes integer agentKey, integer whichKey returns unit
    debug call AkeyDebugUncreated(agentKey)
    return LoadUnitHandle(hashTable, agentKey, whichKey)
endfunction

function AgentLoadItem takes integer agentKey, integer whichKey returns item
    debug call AkeyDebugUncreated(agentKey)
    return LoadItemHandle(hashTable, agentKey, whichKey)
endfunction

function AgentLoadGroup takes integer agentKey, integer whichKey returns group
    debug call AkeyDebugUncreated(agentKey)
    return LoadGroupHandle(hashTable, agentKey, whichKey)
endfunction

function AgentLoadTrigger takes integer agentKey, integer whichKey returns trigger
    debug call AkeyDebugUncreated(agentKey)
    return LoadTriggerHandle(hashTable, agentKey, whichKey)
endfunction

function AgentLoadTimer takes integer agentKey, integer whichKey returns timer
    debug call AkeyDebugUncreated(agentKey)
    return LoadTimerHandle(hashTable, agentKey, whichKey)
endfunction

//Other
function AgentLoadInteger takes integer agentKey, integer whichKey returns integer
    debug call AkeyDebugUncreated(agentKey)
    return LoadInteger(hashTable, agentKey, whichKey)
endfunction

function AgentLoadReal takes integer agentKey, integer whichKey returns real
    debug call AkeyDebugUncreated(agentKey)
    return LoadReal(hashTable, agentKey, whichKey)
endfunction

function AgentLoadBoolean takes integer agentKey, integer whichKey returns boolean
    debug call AkeyDebugUncreated(agentKey)
    return LoadBoolean(hashTable, agentKey, whichKey)
endfunction

function AgentLoadStr takes integer agentKey, integer whichKey returns string
    debug call AkeyDebugUncreated(agentKey)
    return LoadStr(hashTable, agentKey, whichKey)
endfunction

//===========================================================================
// Flush
function AgentFlush takes integer agentKey returns nothing
    debug call AkeyDebugClear(agentKey)
    call FlushChildHashtable(hashTable, agentKey)
endfunction


function AgentHaveSavedReal takes integer agentKey, integer whichKey returns boolean
    return HaveSavedReal(hashTable, agentKey, whichKey)
endfunction

//===========================================================================
// End of Agent Key system
//===========================================================================
endlibrary

