library CustomizableAbilityList requires TableStruct, Rawcode2String, GALability

private keyword Init

private struct Tooltip2Rawcode extends array
    //! runtextmacro TableStruct_NewPrimitiveField("rawcode", "integer")
    
    method hasData takes nothing returns boolean
        return rawcodeExists()
    endmethod
endstruct

struct RemoveableAbility extends array

    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("isRegistered", "boolean")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("isHero", "boolean")
    
    static method isTooltipRegistered takes string tooltip returns boolean
        return Tooltip2Rawcode(StringHash(tooltip)).hasData()
    endmethod
    
    static method isAbilityOfRegisteredType takes ability whichAbility returns boolean
        return .isTooltipRegistered(BlzGetAbilityStringLevelField(whichAbility, ABILITY_SLF_TOOLTIP_NORMAL, 0))
    endmethod
    
    private static method registerAbility takes thistype whichAbility, boolean isHero returns nothing
        local string tooltip = BlzGetAbilityTooltip(whichAbility, 0)
        
        set whichAbility.isRegistered = true
        set whichAbility.isHero = isHero
    
        set tooltip = tooltip + " |c99999999Code: [" + ID2S(whichAbility) + "]|r"
        call BlzSetAbilityTooltip(whichAbility, tooltip, 0)
        set Tooltip2Rawcode(StringHash(tooltip)).rawcode = whichAbility
    endmethod
    
    static method fromTooltip takes string tooltip returns thistype
        return Tooltip2Rawcode(StringHash(tooltip)).rawcode
    endmethod
    
    static method fromAbility takes ability whichAbility returns thistype
        return .fromTooltip(BlzGetAbilityStringLevelField(whichAbility, ABILITY_SLF_TOOLTIP_NORMAL, 0))
    endmethod
    
    implement Init
endstruct

function UnitEnumRemoveableAbilities takes unit whichUnit returns ArrayList_ability
    local ability a
    local integer i = 0
    local ArrayList_ability result = ArrayList_ability.create()
    
    loop
        set a = BlzGetUnitAbilityByIndex(whichUnit, i)
        exitwhen a == null
        if RemoveableAbility.isAbilityOfRegisteredType(a) then
            call result.append(a)
        endif
        set i = i + 1
    endloop
    
    return result
endfunction

function IsAbilityRemoveable takes RemoveableAbility rawcode returns boolean
    return rawcode.isRegistered
endfunction

function IsAbilityAddable takes RemoveableAbility rawcode returns boolean
    return rawcode.isHero
endfunction

private module Init

    private static method onInit takes nothing returns nothing
        // Default hero abilities
        call .registerAbility('AHbz', true)  // Blizzard
        call .registerAbility('AHds', true)  // Divine Shield
        call .registerAbility('AHfs', true)  // Flamestrike
        call .registerAbility('AHhb', true)  // Holy Light
        call .registerAbility('AHwe', true)  // Water Elemental
        call .registerAbility('AHpx', true)  // Phoenix
        call .registerAbility('AHre', true)  // Ressurection
        call .registerAbility('AHdr', true)  // Siphon Mana
        
        call .registerAbility('AOww', true)  // Bladestorm
        call .registerAbility('AOcl', true)  // Chain Lightning
        call .registerAbility('AOcr', true)  // Critical Strike
        call .registerAbility('AOsf', true)  // Feral Spirit
        call .registerAbility('AOmi', true)  // Mirror Image
        call .registerAbility('Arsw', true)  // Serpent Ward
        call .registerAbility('AOwk', true)  // Wind Walk
        
        call .registerAbility('AUdd', true)  // Death and Decay
        call .registerAbility('AUfn', true)  // Frost Nova
        call .registerAbility('AUin', true)  // Inferno
        call .registerAbility('AUls', true)  // Locust Swarm
        
        call .registerAbility('AEbl', true)  // Blink
        call .registerAbility('AEev', true)  // Evasion
        call .registerAbility('AEfk', true)  // Fan of Knives
        call .registerAbility('AEmb', true)  // Mana Burn
        call .registerAbility('AEsh', true)  // Shadow Strike
        call .registerAbility('AEtq', true)  // Tranquility
        call .registerAbility('AHfa', true)  // Searing Arrows
        call .registerAbility('AEsf', true)  // Starfall
        call .registerAbility('AEsv', true)  // Vengeance
        
        call .registerAbility('ANba', true)  // Black Arrow
        call .registerAbility('ANch', true)  // Charm
        call .registerAbility('ANca', true)  // Cleaving Attack
        call .registerAbility('ANc3', true)  // Cluster Rockets
        call .registerAbility('ANdr', true)  // Drain Life
        call .registerAbility('ANdb', true)  // Drunken Brawler
        call .registerAbility('ANfl', true)  // Forked Lightning
        call .registerAbility('ANfa', true)  // Frost Arrows
        call .registerAbility('ANhs', true)  // Healing Spray
        call .registerAbility('ANht', true)  // Howl of Terror
        call .registerAbility('ANms', true)  // Mana Shield
        call .registerAbility('Acef', true)  // Storm, Earth and Fire
        call .registerAbility('ANto', true)  // Tornado
        
        // Aura Abilities
        call .registerAbility('A04L', true)  // Brilliance
        call .registerAbility('A03P', true)  // Command
        call .registerAbility('A03I', true)  // Devotion
        call .registerAbility('A03Q', true)  // Endurance
        call .registerAbility('A04D', true)  // Thorns
        call .registerAbility('A040', true)  // Trueshot
        call .registerAbility('A03S', true)  // Unholy
        call .registerAbility('A046', true)  // Vampiric
        
        // Custom hero abilities
        call .registerAbility('A041', true)  // Arcane Clone
        call .registerAbility('A05P', true)  // Battle Jump
        call .registerAbility('A03F', true)  // Bladespin
        call .registerAbility('AOOI', true)  // Breath of Fire
        call .registerAbility('A02A', true)  // Burst of Despair
        call .registerAbility('A029', true)  // Carrion Burst
        call .registerAbility('A03B', true)  // Carrion Swarm
        call .registerAbility('A04C', true)  // Chain Slow
        call .registerAbility('A059', true)  // Charge
        call .registerAbility('A01F', true)  // Comet
        call .registerAbility('A03C', true)  // Death Coil
        call .registerAbility('A051', true)  // Disarming Blow
        call .registerAbility('A01M', true)  // Divine Shell
        call .registerAbility('A02P', true)  // Energy Surge
        call .registerAbility('A05S', true)  // Ethereal Jaunt
        call .registerAbility('A00W', true)  // Greater Bloodlust
        call .registerAbility('A03G', true)  // Greater Frost Armor
        call .registerAbility('A02R', true)  // Greater Shockwave
        call .registerAbility('A04Y', true)  // Healing Ward
        call .registerAbility('A043', true)  // Healing Wave
        call .registerAbility('A035', true)  // Heroic Strike
        call .registerAbility('A01Q', true)  // Holy Inspiration
        call .registerAbility('A04N', true)  // Holystrike
        call .registerAbility('A026', true)  // Innervate
        call .registerAbility('A044', true)  // Ironbound Fortitude
        call .registerAbility('A03J', true)  // Mass Banish
        call .registerAbility('A03H', true)  // Mass Death Coil
        call .registerAbility('A042', true)  // Mass Rejuvenation
        call .registerAbility('A036', true)  // Monsoon
        call .registerAbility('A050', true)  // Power Surge
        call .registerAbility('A03Y', true)  // Rain of Fire
        call .registerAbility('A03X', true)  // Rejuvenation
        call .registerAbility('A02G', true)  // Royal Hammer
        call .registerAbility('A03Z', true)  // Royal Inspiartion
        call .registerAbility('A02E', true)  // Scatter Shot
        call .registerAbility('A054', true)  // Scatter Shot
        call .registerAbility('A022', true)  // Shockwave
        call .registerAbility('A025', true)  // Silence
        call .registerAbility('A053', true)  // Slow Posion
        call .registerAbility('A034', true)  // Solid Fog
        call .registerAbility('A039', true)  // Spell Disjunction
        call .registerAbility('A02N', true)  // Star Rain
        call .registerAbility('A03E', true)  // Stormbolt
        call .registerAbility('A04P', true)  // Stormstrike
        call .registerAbility('A02D', true)  // Sword Throw
        call .registerAbility('A020', true)  // Thunderclap
        call .registerAbility('A05A', true)  // Thunderstrike
        call .registerAbility('A058', true)  // War Stomp
        call .registerAbility('A05B', true)  // Waterspout
        
        // Custom Unit abilities
        call .registerAbility('A05N', false)  // Animate Dead
        call .registerAbility('A02Q', false)  // Arrow Defense
        call .registerAbility('A05F', false)  // Avatar
        call .registerAbility('A05T', false)  // Gift of the Naaru
        call .registerAbility('A05R', false)  // Hardened Plating
        call .registerAbility('A05E', false)  // Hardened Skin
        call .registerAbility('A03R', false)  // Holy Light
        call .registerAbility('A05D', false)  // Wind Walk
        
        // call .registerAbility('A02S', false)  // Defend (must figure out a good way to do it)
        
        
        // Default Unit abilities
        call .registerAbility('ACac', false)  //"Command Aura"
        call .registerAbility('ACad', false)  //"Animate Dead"
        call .registerAbility('ACah', false)  //"Thorns Aura"
        call .registerAbility('ACam', false)  //"Anti-magic Shell"
        call .registerAbility('ACat', false)  //"Trueshot Aura"
        call .registerAbility('ACav', false)  //"Devotion Aura"
        call .registerAbility('ACba', false)  //"Brilliance Aura"
        call .registerAbility('ACbb', false)  //"Bloodlust"
        call .registerAbility('ACbc', false)  //"Breath of Fire"
        call .registerAbility('ACbf', false)  //"Breath of Frost"
        call .registerAbility('ACbh', false)  //"Bash"
        call .registerAbility('ACbk', false)  //"Black Arrow"
        call .registerAbility('ACbl', false)  //"Bloodlust"
        call .registerAbility('ACbn', false)  //"Banish"
        call .registerAbility('ACbz', false)  //"Blizzard"
        call .registerAbility('ACc2', false)  //"Crushing Wave"
        call .registerAbility('ACc3', false)  //"Crushing Wave"
        call .registerAbility('ACca', false)  //"Carrion Swarm"
        call .registerAbility('ACcb', false)  //"Frost Bolt"
        call .registerAbility('ACce', false)  //"Cleaving Attack"
        call .registerAbility('ACch', false)  //"Charm"
        call .registerAbility('ACcl', false)  //"Chain Lightning"
        call .registerAbility('ACcn', false)  //"Cannibalize"
        call .registerAbility('ACcr', false)  //"Cripple"
        call .registerAbility('ACcs', false)  //"Curse"
        call .registerAbility('ACct', false)  //"Critical Strike"
        call .registerAbility('ACcv', false)  //"Crushing Wave"
        call .registerAbility('ACcw', false)  //"Cold Arrows"
        call .registerAbility('ACcy', false)  //"Cyclone"
        call .registerAbility('ACd2', false)  //"Abolish Magic"
        call .registerAbility('ACdc', false)  //"Death Coil"
        call .registerAbility('ACde', false)  //"Devour Magic"
        call .registerAbility('ACdm', false)  //"Abolish Magic"
        call .registerAbility('ACdr', false)  //"Life Drain"
        call .registerAbility('ACds', false)  //"Divine Shield"
        call .registerAbility('ACdv', false)  //"Devour"
        call .registerAbility('ACen', false)  //"Ensnare"
        call .registerAbility('ACes', false)  //"Evasion"
        call .registerAbility('ACev', false)  //"Evasion"
        call .registerAbility('ACf2', false)  //"Frost Armor"
        call .registerAbility('ACf3', false)  //"Finger of Pain"
        call .registerAbility('ACfa', false)  //"Frost Armor"
        call .registerAbility('ACfb', false)  //"Firebolt"
        call .registerAbility('ACfd', false)  //"Finger of Pain"
        call .registerAbility('ACff', false)  //"Faerie Fire"
        call .registerAbility('ACfl', false)  //"Forked Lightning"
        call .registerAbility('ACfn', false)  //"Frost Nova"
        call .registerAbility('ACfr', false)  //"Force of Nature"
        call .registerAbility('ACfs', false)  //"Flame Strike"
        call .registerAbility('ACfu', false)  //"Frost Armor"
        call .registerAbility('AChv', false)  //"Healing Wave"
        call .registerAbility('AChw', false)  //"Healing Ward"
        call .registerAbility('AChx', false)  //"Hex"
        call .registerAbility('ACif', false)  //"Inner Fire"
        call .registerAbility('ACim', false)  //"Immolation"
        call .registerAbility('ACls', false)  //"Lightning Shield"
        call .registerAbility('ACm2', false)  //"Spell Immunity"
        call .registerAbility('ACm3', false)  //"Spell Immunity"
        call .registerAbility('ACmf', false)  //"Mana Shield"
        call .registerAbility('ACmi', false)  //"Spell Immunity"
        call .registerAbility('ACmo', false)  //"Monsoon"
        call .registerAbility('ACmp', false)  //"Impale"
        call .registerAbility('ACpa', false)  //"Parasite"
        call .registerAbility('ACps', false)  //"Possession"
        call .registerAbility('ACpu', false)  //"Purge"
        call .registerAbility('ACpv', false)  //"Pulverize"
        call .registerAbility('ACpy', false)  //"Polymorph"
        call .registerAbility('ACr1', false)  //"Roar"
        call .registerAbility('ACr2', false)  //"Rejuvenation"
        call .registerAbility('ACrd', false)  //"Raise Dead"
        call .registerAbility('ACrf', false)  //"Rain of Fire"
        call .registerAbility('ACrg', false)  //"Rain of Fire"
        call .registerAbility('ACrj', false)  //"Rejuvenation"
        call .registerAbility('ACrk', false)  //"Resistant Skin"
        call .registerAbility('ACrn', false)  //"Reincarnation"
        call .registerAbility('ACro', false)  //"Roar"
        call .registerAbility('ACs9', false)  //"Feral Spirit"
        call .registerAbility('ACsa', false)  //"Searing Arrows"
        call .registerAbility('ACsf', false)  //"Feral Spirit"
        call .registerAbility('ACsh', false)  //"Shockwave"
        call .registerAbility('ACsi', false)  //"Silence"
        call .registerAbility('ACsk', false)  //"Resistant Skin"
        call .registerAbility('ACsl', false)  //"Sleep"
        call .registerAbility('ACsm', false)  //"Siphon Mana"
        call .registerAbility('ACsp', false)  //"Sleep"
        call .registerAbility('ACst', false)  //"Shockwave"
        call .registerAbility('ACsw', false)  //"Slow"
        call .registerAbility('ACt2', false)  //"Slam"
        call .registerAbility('ACtb', false)  //"Hurl Boulder"
        call .registerAbility('ACtc', false)  //"Slam"
        call .registerAbility('ACtn', false)  //"Spawn Tentacle"
        call .registerAbility('ACua', false)  //"Unholy Aura"
        call .registerAbility('ACuf', false)  //"Unholy Frenzy"
        call .registerAbility('ACvp', false)  //"Vampiric Aura"
        call .registerAbility('ACvs', false)  //"Envenomed Weapons"
        call .registerAbility('ACwb', false)  //"Web"
        call .registerAbility('ACwe', false)  //"Summon Sea Elemental"
        call .registerAbility('AHta', false)  //"Reveal"
        call .registerAbility('ANak', false)  //"Quill Spray"
        call .registerAbility('ANb2', false)  //"Maul"
        call .registerAbility('ANbh', false)  //"Bash"
        call .registerAbility('ANen', false)  //"Ensnare"
        call .registerAbility('ANfs', false)  //"Flame Strike"
        call .registerAbility('ANfy', false)  //"Factory"
        call .registerAbility('ANha', false)  //"Harvest"
        call .registerAbility('ANmr', false)  //"Mind Rot"
        call .registerAbility('ANpa', false)  //"Parasite"
        call .registerAbility('ANpi', false)  //"Permanent Immolation"
        call .registerAbility('ANt2', false)  //"Spiked Shell"
        call .registerAbility('ANta', false)  //"Taunt"
        call .registerAbility('ANth', false)  //"Spiked Shell"
        call .registerAbility('ANtr', false)  //"True Sight"
        call .registerAbility('Aabr', false)  //"Aura of Blight"
        call .registerAbility('Aabs', false)  //"Absorb Mana"
        call .registerAbility('Aadm', false)  //"Abolish Magic"
        call .registerAbility('Aakb', false)  //"War Drums"
        call .registerAbility('Aam2', false)  //"Anti-magic Shell"
        call .registerAbility('Aams', false)  //"Anti-magic Shell"
        call .registerAbility('Aap1', false)  //"Disease Cloud"
        call .registerAbility('Aap2', false)  //"Disease Cloud"
        call .registerAbility('Aap3', false)  //"Disease Cloud"
        call .registerAbility('Aap4', false)  //"Disease Cloud"
        call .registerAbility('Aast', false)  //"Ancestral Spirit"
        call .registerAbility('Aave', false)  //"Destroyer Form "
        call .registerAbility('Ablo', false)  //"Bloodlust"
        call .registerAbility('Abof', false)  //"Burning Oil"
        call .registerAbility('Abrf', false)  //"Bear Form"
        call .registerAbility('Absk', false)  //"Berserk"
        call .registerAbility('Abtl', false)  //"Battle Stations"
        call .registerAbility('Acan', false)  //"Cannibalize"
        call .registerAbility('Ache', false)  //"Ray of Disruption"
        call .registerAbility('Acht', false)  //"Howl of Terror"
        call .registerAbility('Aclf', false)  //"Cloud"
        call .registerAbility('Acmg', false)  //"Control Magic"
        call .registerAbility('Acn2', false)  //"Cannibalize"
        call .registerAbility('Acny', false)  //"Cyclone"
        call .registerAbility('Acor', false)  //"Corrosive Breath"
        call .registerAbility('Acpf', false)  //"Corporeal Form"
        call .registerAbility('Acri', false)  //"Cripple"
        call .registerAbility('Acrs', false)  //"Curse"
        call .registerAbility('Acyc', false)  //"Cyclone"
        call .registerAbility('Adch', false)  //"Disenchant"
        call .registerAbility('Adcn', false)  //"Disenchant"
        call .registerAbility('Adef', false)  //"Defend"
        call .registerAbility('Adev', false)  //"Devour"
        call .registerAbility('Adis', false)  //"Dispel Magic"
        call .registerAbility('Adsm', false)  //"Dispel Magic"
        call .registerAbility('Adt1', false)  //"Detector"
        call .registerAbility('Adtg', false)  //"True Sight"
        call .registerAbility('Adtn', false)  //"Detonate"
        call .registerAbility('Adts', false)  //"Magic Sentry"
        call .registerAbility('Aeat', false)  //"Eat Tree"
        call .registerAbility('Aegr', false)  //"Elune's Grace"
        call .registerAbility('Aenr', false)  //"Entangling Roots"
        call .registerAbility('Aens', false)  //"Ensnare"
        call .registerAbility('Aenw', false)  //"Entangling Roots"
        call .registerAbility('Aesn', false)  //"Sentinel"
        call .registerAbility('Aesr', false)  //"Sentinel"
        call .registerAbility('Aexh', false)  //"Exhume Corpses"
        call .registerAbility('Aeye', false)  //"Sentry Ward"
        call .registerAbility('Afa2', false)  //"Faerie Fire"
        call .registerAbility('Afae', false)  //"Faerie Fire"
        call .registerAbility('Afak', false)  //"Orb of Annihilation"
        call .registerAbility('Afbb', false)  //"Feedback"
        call .registerAbility('Afbk', false)  //"Feedback"
        call .registerAbility('Afbt', false)  //"Feedback"
        call .registerAbility('Afla', false)  //"Flare"
        call .registerAbility('Aflk', false)  //"Flak Cannons"
        call .registerAbility('Afod', false)  //"Finger of Death"
        call .registerAbility('Afr2', false)  //"Frost Attack"
        call .registerAbility('Afra', false)  //"Frost Attack"
        call .registerAbility('Afrb', false)  //"Frost Breath"
        call .registerAbility('Afrz', false)  //"Freezing Breath"
        call .registerAbility('Afsh', false)  //"Fragmentation Shards"
        call .registerAbility('Afzy', false)  //"Frenzy"
        call .registerAbility('Agra', false)  //"War Club"
        call .registerAbility('Agyb', false)  //"Flying Machine Bombs"
        call .registerAbility('Agyv', false)  //"True Sight"
        call .registerAbility('Ahar', false)  //"Harvest"
        call .registerAbility('Ahea', false)  //"Heal"
        call .registerAbility('Ahid', false)  //"Shadow Meld"
        call .registerAbility('Ahnl', false)  //"Summoning Ritual"
        call .registerAbility('Ahwd', false)  //"Healing Ward"
        call .registerAbility('Aimp', false)  //"Vorpal Blades"
        call .registerAbility('Ainf', false)  //"Inner Fire"
        call .registerAbility('Aivs', false)  //"Invisibility"
        call .registerAbility('Alam', false)  //"Sacrifice"
        call .registerAbility('Aliq', false)  //"Liquid Fire"
        call .registerAbility('Alsh', false)  //"Lightning Shield"
        call .registerAbility('Amb2', false)  //"Replenish Mana"
        call .registerAbility('Ambb', false)  //"Mana Burn"
        call .registerAbility('Ambd', false)  //"Mana Burn"
        call .registerAbility('Ambt', false)  //"Replenish Mana and Life"
        call .registerAbility('Amdf', false)  //"Magic Defense"
        call .registerAbility('Amfl', false)  //"Mana Flare"
        call .registerAbility('Amgl', false)  //"Moon Glaive"
        call .registerAbility('Amgr', false)  //"Moon Glaive"
        call .registerAbility('Amic', false)  //"Call To Arms"
        call .registerAbility('Amil', false)  //"Call to Arms"
        call .registerAbility('Amim', false)  //"Spell Immunity"
        call .registerAbility('Amls', false)  //"Aerial Shackles"
        call .registerAbility('Amnb', false)  //"Mana Burn"
        call .registerAbility('Andm', false)  //"Abolish Magic"
        call .registerAbility('Andt', false)  //"Reveal"
        call .registerAbility('Anh1', false)  //"Heal"
        call .registerAbility('Anh2', false)  //"Heal"
        call .registerAbility('Anhe', false)  //"Heal"
        call .registerAbility('Ansk', false)  //"Hardened Skin"
        call .registerAbility('Apg2', false)  //"Purge"
        call .registerAbility('Apig', false)  //"Permanent Immolation"
        call .registerAbility('Apiv', false)  //"Permanent Invisibility"
        call .registerAbility('Aply', false)  //"Polymorph"
        call .registerAbility('Apmf', false)  //"Phoenix Fire"
        call .registerAbility('Apoi', false)  //"Poison Sting"
        call .registerAbility('Apos', false)  //"Possession"
        call .registerAbility('Aprg', false)  //"Purge"
        call .registerAbility('Aps2', false)  //"Possession"
        call .registerAbility('Apsh', false)  //"Phase Shift"
        call .registerAbility('Apts', false)  //"Disease Cloud"
        call .registerAbility('Apxf', false)  //"Phoenix Fire"
        call .registerAbility('Ara2', false)  //"Roar"
        call .registerAbility('Arai', false)  //"Raise Dead"
        call .registerAbility('Arej', false)  //"Rejuvenation"
        call .registerAbility('Aroa', false)  //"Roar"
        call .registerAbility('Aroc', false)  //"Barrage"
        call .registerAbility('Arpb', false)  //"Replenish"
        call .registerAbility('Arpl', false)  //"Essence of Blight"
        call .registerAbility('Arpm', false)  //"Spirit Touch"
        call .registerAbility('Arsk', false)  //"Resistant Skin"
        call .registerAbility('Asac', false)  //"Sacrifice"
        call .registerAbility('Asal', false)  //"Pillage"
        call .registerAbility('Asd2', false)  //"Kaboom!"
        call .registerAbility('Asd3', false)  //"Kaboom!"
        call .registerAbility('Asdg', false)  //"Kaboom!"
        call .registerAbility('Asds', false)  //"Kaboom!"
        call .registerAbility('Ashm', false)  //"Shadow Meld"
        call .registerAbility('Aslo', false)  //"Slow"
        call .registerAbility('Asph', false)  //"Sphere"
        call .registerAbility('Aspi', false)  //"Spiked Barricades"
        call .registerAbility('Aspl', false)  //"Spirit Link"
        call .registerAbility('Aspo', false)  //"Slow Poison"
        call .registerAbility('Asps', false)  //"Spell Steal"
        call .registerAbility('Assk', false)  //"Hardened Skin"
        call .registerAbility('Asta', false)  //"Stasis Trap"
        call .registerAbility('Asth', false)  //"Storm Hammers"
        call .registerAbility('Atau', false)  //"Taunt"
        call .registerAbility('Atru', false)  //"True Sight"
        call .registerAbility('Auco', false)  //"Unstable Concoction"
        call .registerAbility('Auhf', false)  //"Unholy Frenzy"
        call .registerAbility('Ault', false)  //"Ultravision"
        call .registerAbility('Aven', false)  //"Envenomed Spears"
        call .registerAbility('Avng', false)  //"Spirit of Vengeance"
        call .registerAbility('Awar', false)  //"Pulverize"
        call .registerAbility('Aweb', false)  //"Web"
        call .registerAbility('Awfb', false)  //"Firebolt"
        call .registerAbility('Awrg', false)  //"War Stomp"
        call .registerAbility('Awrh', false)  //"War Stomp"
        call .registerAbility('Awrs', false)  //"War Stomp"
        call .registerAbility('SCae', false)  //"Endurance Aura"
        call .registerAbility('SCc1', false)  //"Cyclone"
        call .registerAbility('SCva', false)  //"Life Steal"
        call .registerAbility('Scri', false)  //"Cripple"
        call .registerAbility('Sshm', false)  //"Shadow Meld"
        call .registerAbility('Suhf', false)  //"Unholy Frenzy"
    endmethod

endmodule


endlibrary
