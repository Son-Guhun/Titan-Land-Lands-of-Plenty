library CircleObjectSystem
//Circle Object System v.1.1.0
//Paste this script into your map's header
function GetGCOSDefAngle takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 0)
endfunction

function GetGCOSCurAngle takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, -instance, 0)
endfunction

function GetGCOSCenterX takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 1)
endfunction

function GetGCOSCenterY takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 2)
endfunction

function GetGCOSRadiusX takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 3)
endfunction

function GetGCOSRadiusY takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 4)
endfunction

function GetGCOSNoPoints takes integer instance returns integer
    return LoadInteger(udg_GCOS_Hashtable, instance, 5)
endfunction

function GetGCOSTilt takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 6)
endfunction

function GetGCOSSpin takes integer instance returns real
    return LoadReal(udg_GCOS_Hashtable, instance, 7)
endfunction

function SetGCOSDefAngle takes integer instance, real angle returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 0, angle)
endfunction

function SetGCOSCurAngle takes integer instance, real angle returns nothing
    call SaveReal(udg_GCOS_Hashtable, -instance, 0, angle)
endfunction

function SetGCOSCenterX takes integer instance, real X returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 1, X)
endfunction

function SetGCOSCenterY takes integer instance, real Y returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 2, Y)
endfunction

function SetGCOSRadiusX takes integer instance, real X returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 3, X)
endfunction

function SetGCOSRadiusY takes integer instance, real Y returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 4, Y)
endfunction

function SetGCOSNoPoints takes integer instance, integer number returns nothing
    call SaveInteger(udg_GCOS_Hashtable, instance, 5, number)
endfunction

function SetGCOSTilt takes integer instance, real angle returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 6, angle)
endfunction

function SetGCOSSpin takes integer instance, real angle returns nothing
    call SaveReal(udg_GCOS_Hashtable, instance, 7, angle)
endfunction

function GetGCOSPointX takes integer instance, integer pointNumber returns real
    return LoadReal(udg_GCOS_Hashtable, -instance,  pointNumber )
endfunction

function GetGCOSPointY takes integer instance, integer pointNumber returns real
    return LoadReal(udg_GCOS_Hashtable, -instance, -pointNumber )
endfunction

function SetGCOSUnit takes integer instance, integer pointNumber, unit u returns nothing
    call SaveUnitHandle(udg_GCOS_Hashtable, instance, 100 + pointNumber, u )
endfunction

function GetGCOSUnit takes integer instance, integer pointNumber returns unit
    return LoadUnitHandle(udg_GCOS_Hashtable, instance, 100 + pointNumber )
endfunction

function CreateGCOS takes real angle, real centerX, real centerY, real radiusX, real radiusY, integer numPoints, real tilt, real spin returns integer
    local integer instance
    local integer count = 1
    local real step = 2*bj_PI/I2R(numPoints)

//a = radius x, b = radius y, h = center x, k = center y, R = rotation(tilt)
//x = h + acos(2pi*t)cos(R) - bsin(2pi*t)sin(R)
//y = k + acos(2pi*t)sin(R) + bsin(2pi*t)cos(R)
//https://math.stackexchange.com/questions/941490/whats-the-parametric-equation-for-the-general-form-of-an-ellipse-rotated-by-any

//This code generates an instance number for the circle object
    set instance = udg_GCOS_InstanceArray[0]
    if udg_GCOS_InstanceArray[udg_GCOS_InstanceArray[0]] == 0 then
        set udg_GCOS_InstanceArray[0] = udg_GCOS_InstanceArray[0] + 1
    else
        set udg_GCOS_InstanceArray[0] = udg_GCOS_InstanceArray[udg_GCOS_InstanceArray[0]]
        set udg_GCOS_InstanceArray[instance] = 0
    endif
    
    call SaveReal(udg_GCOS_Hashtable, instance, 0, angle)
    call SaveReal(udg_GCOS_Hashtable, -instance, 0, angle)
    call SaveReal(udg_GCOS_Hashtable, instance, 1, centerX)
    call SaveReal(udg_GCOS_Hashtable, instance, 2, centerY)
    call SaveReal(udg_GCOS_Hashtable, instance, 3, radiusX)
    call SaveReal(udg_GCOS_Hashtable, instance, 4, radiusY)
    call SaveInteger(udg_GCOS_Hashtable, instance, 5, numPoints)
    call SaveReal(udg_GCOS_Hashtable, instance, 6, tilt)
    call SaveReal(udg_GCOS_Hashtable, instance, 7, spin)
//End of instance number generation

    loop
    exitwhen count > numPoints
        call SaveReal(udg_GCOS_Hashtable, -instance,  count, centerX + radiusX*Cos(angle)*Cos(tilt) - radiusY*Sin(angle)*Sin(tilt))
        call SaveReal(udg_GCOS_Hashtable, -instance, -count, centerY + radiusX*Cos(angle)*Sin(tilt) + radiusY*Sin(angle)*Cos(tilt))
        set angle = angle + step
        set count = count + 1
    endloop
    return instance
endfunction

function DestroyGCOS takes integer instance returns nothing
    call FlushChildHashtable(udg_GCOS_Hashtable, instance)
    call FlushChildHashtable(udg_GCOS_Hashtable, -instance)
    set udg_GCOS_InstanceArray[instance] = udg_GCOS_InstanceArray[0]
    set udg_GCOS_InstanceArray[0] = instance
endfunction

function UpdateGCOS takes integer instance returns nothing
    local integer numPoints = LoadInteger(udg_GCOS_Hashtable, instance, 5)
    local integer count = 1

    local real centerX = LoadReal(udg_GCOS_Hashtable, instance, 1)
    local real centerY = LoadReal(udg_GCOS_Hashtable, instance, 2)
    local real radiusX = LoadReal(udg_GCOS_Hashtable, instance, 3)
    local real radiusY = LoadReal(udg_GCOS_Hashtable, instance, 4)
    local real tilt = LoadReal(udg_GCOS_Hashtable,instance,6)
    local real angle = LoadReal(udg_GCOS_Hashtable, -instance, 0)
    
    local real step = 2*bj_PI/I2R(numPoints)
    
    set angle = angle + LoadReal(udg_GCOS_Hashtable,instance,7) //The real being added is the rotation/spin step
    call SaveReal(udg_GCOS_Hashtable, -instance, 0, angle)

    loop
    exitwhen count > numPoints
        set angle = angle + step
        call SaveReal(udg_GCOS_Hashtable, -instance,  count, centerX + radiusX*Cos(angle)*Cos(tilt) - radiusY*Sin(angle)*Sin(tilt))
        call SaveReal(udg_GCOS_Hashtable, -instance, -count, centerY + radiusX*Cos(angle)*Sin(tilt) + radiusY*Sin(angle)*Cos(tilt))
        call SetUnitPosition (LoadUnitHandle(udg_GCOS_Hashtable, instance, 100 + count ), LoadReal(udg_GCOS_Hashtable, -instance,  count), LoadReal(udg_GCOS_Hashtable, -instance,  -count))
        set count = count + 1
    endloop
endfunction
endlibrary