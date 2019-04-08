library FilterTransformations initializer onInit requires TableStruct

public struct Globals extends array

    //! runtextmacro TableStruct_NewConstTableField("", "data")

endstruct

function IsOrderMorph takes integer orderId returns boolean
    return Globals.data.boolean.has(orderId)
endfunction


private function onInit takes nothing returns nothing
       set Globals.data.boolean[OrderId("burrow")]          = true
       set Globals.data.boolean[OrderId("unburrow")]        = true
       set Globals.data.boolean[OrderId("sphinxform")]      = true
       set Globals.data.boolean[OrderId("unsphinxform")]    = true
       set Globals.data.boolean[OrderId("bearform")]        = true
       set Globals.data.boolean[OrderId("unbearform")]      = true
       set Globals.data.boolean[OrderId("ravenform")]       = true
       set Globals.data.boolean[OrderId("unravenform")]     = true
       set Globals.data.boolean[OrderId("root")]            = true
       set Globals.data.boolean[OrderId("unroot")]          = true
       set Globals.data.boolean[OrderId("etherealform")]    = true
       set Globals.data.boolean[OrderId("unetherealform")]  = true
       set Globals.data.boolean[OrderId("corporealform")]   = true
       set Globals.data.boolean[OrderId("uncorporealform")] = true
       set Globals.data.boolean[OrderId("submerge")]        = true
       set Globals.data.boolean[OrderId("unsubmerge")]      = true
       set Globals.data.boolean[OrderId("robogoblin")]      = true
       set Globals.data.boolean[OrderId("unrobogoblin")]    = true
       set Globals.data.boolean[OrderId("metamorphosis")]   = true
endfunction

endlibrary