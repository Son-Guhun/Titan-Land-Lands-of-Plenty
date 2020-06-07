library Packets requires Table, optional PlayerUtils, optional GMUI
/*
Example:

function TestPacket takes nothing returns boolean
    local RealPacket packet = RealPacket.eventPacket
    
    call BJDebugMsg(R2S(packet[0]))
    call BJDebugMsg(R2S(packet[1]))

    return false
endfunction

function TestPacketActions takes nothing returns nothing
    local RealPacket packet = RealPacket.create(2, Condition(function TestPacket))
    
    if GetLocalPlayer() == GetTriggerPlayer() then
        set packet[0] = Packets_MAX_VALUE
        set packet[1] = Packets_MIN_VALUE
    endif
    
    call packet.sync(GetTriggerPlayer())
endfunction

*/

globals
    public constant real MAX_VALUE = 8388608.
    public constant real MIN_VALUE = -8388608.
endglobals

struct RealPacket extends array

    private Table localData
    public Table metaData
    private integer missingData
    private boolexpr onSync
    readonly integer size
    static trigger trig
    
    readonly static thistype eventPacket
    private static integer array nextPacket
    private static integer array lastPacket
    private static Table array playerPackets
    private static framehandle slider
    
    method isSynced takes nothing returns boolean
        return .missingData <= 0
    endmethod
    
    method operator [] takes integer index returns real
        return localData.real[index]
    endmethod
    
    method operator []= takes integer index, real value returns nothing
        set localData.real[index] = value
    endmethod
    
    static if LIBRARY_GMUI then
        implement optional GMUINewRecycleKey
        implement optional GMUIAllocatorMethods
    else
        //Generated allocator of RealPacket
        static method allocate takes nothing returns thistype
            local integer this=F
            if (this!=0) then
                set F=V[this]
            else
                set I=I+1
                set this=I
            endif
            if (this>8190) then
                return 0
            endif

            set V[this]=-1
            return this
        endmethod

        //Generated destructor of RealPacket
        method deallocate takes nothing returns nothing
            if this==null then
                return
            elseif (V[this]!=-1) then
                return
            endif
            set V[this]=F
            set F=this
        endmethod
    endif
    
    static method create takes integer size, boolexpr onSync returns thistype
        local thistype this = thistype.allocate()
        
        set .localData = Table.create()
        set .metaData = Table.create()
        set .size = size
        set .onSync = onSync
        set .missingData = size
    
        return this
    endmethod
    
    static method operator localPlayer takes nothing returns player
        static if LIBRARY_PlayerUtils then
            return User.Local
        else
            return GetLocalPlayer()
        endif
    endmethod
    
    method sync takes player whichPlayer returns nothing
        local integer pId = GetPlayerId(whichPlayer)
        
        set playerPackets[pId][lastPacket[pId]] = this
        set lastPacket[pId] = lastPacket[pId] + 1
        
        if localPlayer == whichPlayer then
            set pId = .size
            loop
                set pId = pId - 1
                call BlzFrameSetValue(slider, this[pId])
                exitwhen pId == 0
            endloop
        endif
        
    endmethod
    
    method destroy takes nothing returns nothing    
        if .isSynced() then
            call .localData.destroy()
            call .metaData.destroy()
            call .deallocate()
        endif
    endmethod
    
    private static method onReceiveData takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local thistype packet = playerPackets[pId][nextPacket[pId]]
        local triggercondition cond
        
        set packet.missingData = packet.missingData - 1
        set packet[packet.missingData] = BlzGetTriggerFrameValue()
        
        if packet.isSynced() then
            set eventPacket = packet
            set cond = TriggerAddCondition(trig, packet.onSync)
            call TriggerEvaluate(trig)
            call TriggerRemoveCondition(trig, cond)
            set eventPacket = 0
            
            call playerPackets[pId].remove(nextPacket[pId])
            set nextPacket[pId] = nextPacket[pId] + 1
        endif
    endmethod
    
    private static method onInit takes nothing returns nothing
        local trigger syncTrig = CreateTrigger()
        set trig = CreateTrigger()
        
        set slider = BlzCreateFrameByType( "SLIDER", "PacketSlider", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0), "", 0 )
        call BlzFrameSetMinMaxValue(slider, MIN_VALUE, MAX_VALUE)
        call BlzFrameSetVisible(slider, false)
        call TriggerAddAction(syncTrig, function thistype.onReceiveData)
        call BlzTriggerRegisterFrameEvent(syncTrig, slider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
    endmethod

endstruct





endlibrary