library FilterTransformations initializer onInit requires ConstTable

globals
    private constant key index
endglobals

private constant function data takes nothing returns ConstTable
    return index
endfunction

function IsOrderMorph takes integer orderId returns boolean
    return data().boolean.has(orderId)
endfunction


private function onInit takes nothing returns nothing
       set data().boolean[OrderId("burrow")]          = true
       set data().boolean[OrderId("unburrow")]        = true
       set data().boolean[OrderId("sphinxform")]      = true
       set data().boolean[OrderId("unsphinxform")]    = true
       set data().boolean[OrderId("bearform")]        = true
       set data().boolean[OrderId("unbearform")]      = true
       set data().boolean[OrderId("ravenform")]       = true
       set data().boolean[OrderId("unravenform")]     = true
       set data().boolean[OrderId("root")]            = true
       set data().boolean[OrderId("unroot")]          = true
       set data().boolean[OrderId("etherealform")]    = true
       set data().boolean[OrderId("unetherealform")]  = true
       set data().boolean[OrderId("corporealform")]   = true
       set data().boolean[OrderId("uncorporealform")] = true
       set data().boolean[OrderId("submerge")]        = true
       set data().boolean[OrderId("unsubmerge")]      = true
       set data().boolean[OrderId("robogoblin")]      = true
       set data().boolean[OrderId("unrobogoblin")]    = true
       set data().boolean[OrderId("metamorphosis")]   = true
endfunction

endlibrary