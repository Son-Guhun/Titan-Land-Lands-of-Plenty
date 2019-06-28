//! textmacro TerrainEditorUI_FirstPage takes FUNC, U
    set i = 0
    loop
    exitwhen TerrainTools_GetTexture(i) == 0 or i > 7
        call Unit$FUNC$Ability($U$, ABILITY_TEXTURES[i])
        set i = i + 1
    endloop
//! endtextmacro

//! textmacro TerrainEditorUI_SecondPage takes FUNC, U
    set i = 8
    loop
    exitwhen TerrainTools_GetTexture(i) == 0 or i > 15
        call Unit$FUNC$Ability($U$, ABILITY_TEXTURES[i])
        set i = i + 1
    endloop
//! endtextmacro

/*
TODO:
This library should define a ControlState whose parent is the TerrainEditor ControlState.
*/
library TerrainEditorUI requires TerrainEditor

    //! textmacro TerrainEditorUI_InitTextureArray

        set ABILITY_TEXTURES[0]  = 'ATE0'
        set ABILITY_TEXTURES[1]  = 'ATE1'
        set ABILITY_TEXTURES[2]  = 'ATE2'
        set ABILITY_TEXTURES[3]  = 'ATE3'
        set ABILITY_TEXTURES[4]  = 'ATE4'
        set ABILITY_TEXTURES[5]  = 'ATE5'
        set ABILITY_TEXTURES[6]  = 'ATE6'
        set ABILITY_TEXTURES[7]  = 'ATE7'
        set ABILITY_TEXTURES[8]  = 'ATE8'
        set ABILITY_TEXTURES[9]  = 'ATE9'
        set ABILITY_TEXTURES[10] = 'ATEA'
        set ABILITY_TEXTURES[11] = 'ATEB'
        set ABILITY_TEXTURES[12] = 'ATEC'
        set ABILITY_TEXTURES[13] = 'ATED'
        set ABILITY_TEXTURES[14] = 'ATEE'
        set ABILITY_TEXTURES[15] = 'ATEF'
    //! endtextmacro

    scope ABILITY
        globals
            public integer array TEXTURES
            
            public integer NEXT_PAGE = 'ATEG'
            public integer PREV_PAGE = 'ATEH'
            
            public integer BRUSH_INCREASE = 'ATEI'
            public integer BRUSH_DECREASE = 'ATEJ'
        endglobals
    endscope
    
    private function InFirstPage takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, ABILITY_TEXTURES[0]) > 0
    endfunction
    
    private struct Globals extends array
        //! runtextmacro TableStruct_NewConstTableField("","ability2id")
    endstruct
    
    function onCastAbility takes nothing returns nothing
        local unit trigU = GetTriggerUnit()
        local player owner = GetOwningPlayer(trigU)
        local integer spellId = GetSpellAbilityId()
        local integer i

        call BlzUnitDisableAbility(trigU, ABILITY_TEXTURES[TerrainTools_GetTextureId(TerrainEditor_currentTexture[GetPlayerId(owner)])], false, false)
        if Globals.ability2id.has(spellId) then
            set TerrainEditor_currentTexture[GetPlayerId(owner)] = TerrainTools_GetTexture(Globals.ability2id[spellId])
        
        elseif spellId == ABILITY_NEXT_PAGE or spellId == ABILITY_PREV_PAGE then
            if InFirstPage(trigU) then
                //! runtextmacro TerrainEditorUI_FirstPage("Remove", "trigU")
                //! runtextmacro TerrainEditorUI_SecondPage("Add", "trigU")
            else
                //! runtextmacro TerrainEditorUI_FirstPage("Add", "trigU")
                //! runtextmacro TerrainEditorUI_SecondPage("Remove", "trigU")
            endif
        elseif spellId == ABILITY_BRUSH_INCREASE then
            call TerrainEditor_SetBrushSize(owner, IMinBJ(TerrainEditor_GetBrushSize(owner) + 2, 9))
        elseif spellId == ABILITY_BRUSH_DECREASE then
            call TerrainEditor_SetBrushSize(owner, IMaxBJ(TerrainEditor_GetBrushSize(owner) - 2, 0))
        endif
        call BlzUnitDisableAbility(trigU, ABILITY_TEXTURES[TerrainTools_GetTextureId(TerrainEditor_currentTexture[GetPlayerId(owner)])], true, false)
    endfunction
    
    globals
        private unit array terrainEditors
    endglobals
    
    public function GetEditorUnit takes player whichPlayer returns unit
        return terrainEditors[GetPlayerId(whichPlayer)]
    endfunction
    
    public function Activate takes player whichPlayer returns nothing
        local unit editor = terrainEditors[GetPlayerId(whichPlayer)]
        
        call ShowUnit(editor, true)
        call TerrainEditor_controlState.activateForPlayer(whichPlayer)
        if GetLocalPlayer() == whichPlayer then
            call SelectUnit(editor, true)
        endif
    endfunction
    
    public function Deactivate takes player whichPlayer returns nothing
        call ShowUnit(terrainEditors[GetPlayerId(whichPlayer)], false)
        call ControlState.default.activateForPlayer(whichPlayer)
    endfunction

    private module InitModule
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger trig = CreateTrigger(  )
            local unit editor
            
            //! runtextmacro TerrainEditorUI_InitTextureArray()
            
            call TriggerAddAction( trig, function onCastAbility )
            loop
            exitwhen i == bj_MAX_PLAYERS
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    set editor = CreateUnit(Player(i), 'uTED', 0., 0., 270.)
                    call BlzUnitDisableAbility(editor, ABILITY_TEXTURES[TerrainTools_GetTextureId(TerrainEditor_DEFAULT_TEXTURE)], true, false)
                    
                    call TriggerRegisterUnitEvent( trig, editor, EVENT_UNIT_SPELL_EFFECT )
                    call ShowUnit(editor, false)
                    call UnitRemoveAbility(editor, 'Amov')
                    call UnitRemoveAbility(editor, 'Aatk')
                    
                    set terrainEditors[i] = editor
                    
                endif
                
                set i = i + 1
            endloop
            
            set i = 0
            loop
            exitwhen i == 16
                set Globals.ability2id[ABILITY_TEXTURES[i]] = i
                set i = i + 1
            endloop
        endmethod
    endmodule
    private struct InitStruct extends array
        implement InitModule
    endstruct

endlibrary