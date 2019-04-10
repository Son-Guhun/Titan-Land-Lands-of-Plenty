//! zinc
library HeroicUnit
{

constant integer HERO_ID = 'H0QU'; //Hero type into which the unit morphs.
constant integer SPELL_ID = 'A02B'; //Spell that morphs the unit into a hero temporarily.
constant integer ITEM_ID = 'I00R'; //Powerup that holds the morphing spell
constant integer BONUS_ID = 'AIs1'; //Stat bonus ability. Must provide exactly the same stats of the hero.
constant integer DETECTOR = 'Adef'; //Used to detect morphing. Immolation could be used too
constant integer ORDER = 852056; //Order Id for "undefend". Should be 852178 for "unimmolation"

function OnMorph() -> boolean
{
    unit u = GetTriggerUnit();
    trigger t = GetTriggeringTrigger();
    if (GetTriggerEventId() == EVENT_UNIT_STATE_LIMIT)
    {
        DisableTrigger(t);
        UnitRemoveAbility(u, SPELL_ID);
    }
    else if (GetUnitTypeId(u) != HERO_ID)
    {
        UnitAddAbility(u, SPELL_ID);
        UnitAddAbility(u, BONUS_ID);
        UnitMakeAbilityPermanent(u, true, BONUS_ID);
        TriggerRegisterUnitStateEvent(t, u, UNIT_STATE_LIFE, GREATER_THAN, GetWidgetLife(u)+1.);
        RemoveItem(UnitAddItemById(u, ITEM_ID));
    }
    else
    {
        UnitAddAbility(u, DETECTOR);
    }
    t = null;
    u = null;
    return false;
}

public function UnitMakeHeroic (unit u) -> boolean
{
    trigger t = CreateTrigger();
    real hp = GetWidgetLife(u);
    real mp = GetUnitState(u, UNIT_STATE_MANA);
    SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE));
    TriggerRegisterUnitEvent(t, u, EVENT_UNIT_ISSUED_ORDER);
    TriggerAddCondition(t, Condition(function OnMorph));
    UnitAddAbility(u, 'AInv');
    UnitAddAbility(u, DETECTOR);
    UnitAddAbility(u, BONUS_ID);
    RemoveItem(UnitAddItemById(u, ITEM_ID));
    UnitRemoveAbility(u, BONUS_ID);
    SetWidgetLife(u, hp);
    SetUnitState(u, UNIT_STATE_MANA, mp);
    SetUnitAnimation(u, "stand");
    DestroyTrigger(t);
    t = null;
    return GetUnitAbilityLevel(u, 'AHer') > 0;
}

}
//! endzinc