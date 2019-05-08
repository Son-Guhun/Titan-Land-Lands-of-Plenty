library RegionMemory requires TableStruct

private struct RegionData extends array
    private static key static_members_key

    //! runtextmacro TableStruct_NewStaticPrimitiveField("totalRegions","integer")
    
    static method get takes region r returns RegionData
        return GetHandleId(r)
    endmethod
    
    method destroy takes nothing returns nothing
    endmethod
endstruct

private function CreateRegionHook takes nothing returns nothing
    set RegionData.totalRegions = RegionData.totalRegions + 1
    call BJDebugMsg("Created a region. Total: " + I2S(RegionData.totalRegions))
endfunction

private function RemoveRegionHook takes region r returns nothing
    local RegionData rData = RegionData.get(r)

    if r == null then
        call BJDebugMsg("Attempted to destroy a null region.")
        return
    endif
    
    set RegionData.totalRegions = RegionData.totalRegions - 1

    call rData.destroy()
    call BJDebugMsg("Destroyed region " + I2S(GetHandleId(r)))
    set r = null
endfunction

hook CreateRegion CreateRegionHook
hook RemoveRegion RemoveRegionHook


endlibrary