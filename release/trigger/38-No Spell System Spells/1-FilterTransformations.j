library FilterTransformations initializer onInit requires TableStruct

struct Order extends array

    //! runtextmacro TableStruct_NewConstTableField("", "morphOrders")
    //! runtextmacro TableStruct_NewConstTableField("", "generalOrders")
    //! runtextmacro TableStruct_NewConstTableField("", "necroticOrders")

    method isMorph takes nothing returns boolean
        return .morphOrders.boolean.has(this)
    endmethod
    
    method isNecrotic takes nothing returns boolean
        return .necroticOrders.boolean.has(this)
    endmethod
    
    method isGeneral takes nothing returns boolean
        return .generalOrders.boolean.has(this)
    endmethod
endstruct

function IsOrderMorph takes integer orderId returns boolean
    return Order(orderId).isMorph()
endfunction

function IsOrderNecrotic takes integer orderId returns boolean
    return Order(orderId).isNecrotic()
endfunction

function IsOrderGeneral takes integer orderId returns boolean
    return Order(orderId).isGeneral()
endfunction


private function onInit takes nothing returns nothing
    
    // Morph Orders
    set Order.morphOrders.boolean[OrderId("burrow")]          = true
    set Order.morphOrders.boolean[OrderId("unburrow")]        = true
    set Order.morphOrders.boolean[OrderId("sphinxform")]      = true
    set Order.morphOrders.boolean[OrderId("unsphinxform")]    = true
    set Order.morphOrders.boolean[OrderId("bearform")]        = true
    set Order.morphOrders.boolean[OrderId("unbearform")]      = true
    set Order.morphOrders.boolean[OrderId("ravenform")]       = true
    set Order.morphOrders.boolean[OrderId("unravenform")]     = true
    set Order.morphOrders.boolean[OrderId("root")]            = true
    set Order.morphOrders.boolean[OrderId("unroot")]          = true
    set Order.morphOrders.boolean[OrderId("etherealform")]    = true
    set Order.morphOrders.boolean[OrderId("unetherealform")]  = true
    set Order.morphOrders.boolean[OrderId("corporealform")]   = true
    set Order.morphOrders.boolean[OrderId("uncorporealform")] = true
    set Order.morphOrders.boolean[OrderId("submerge")]        = true
    set Order.morphOrders.boolean[OrderId("unsubmerge")]      = true
    set Order.morphOrders.boolean[OrderId("robogoblin")]      = true
    set Order.morphOrders.boolean[OrderId("unrobogoblin")]    = true
    set Order.morphOrders.boolean[OrderId("metamorphosis")]   = true
    set Order.morphOrders.boolean[OrderId("stoneform")]       = true
    set Order.morphOrders.boolean[OrderId("unstoneform")]     = true
    set Order.morphOrders.boolean[OrderId("chemicalrage")]    = true
    set Order.morphOrders.boolean[OrderId("elementalfury")]    = true

    // Necrotic Orders
    set Order.necroticOrders.boolean[OrderId("raisedead")]             = true
    set Order.necroticOrders.boolean[OrderId("instant")]               = true
    set Order.necroticOrders.boolean[OrderId("vengeance")]             = true
    set Order.necroticOrders.boolean[OrderId("vengeanceinstant")]      = true
    set Order.necroticOrders.boolean[OrderId("carrionscarabs")]        = true
    set Order.necroticOrders.boolean[OrderId("carrionscarabsinstant")] = true

    // General Orders
    set Order.generalOrders.boolean[OrderId("smart")]        = true
    set Order.generalOrders.boolean[OrderId("attack")]       = true
    set Order.generalOrders.boolean[OrderId("patrol")]       = true
    set Order.generalOrders.boolean[OrderId("holdposition")] = true
endfunction

endlibrary