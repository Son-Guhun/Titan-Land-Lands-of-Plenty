library MathParser /* v 1.1.0.0
**********************************************************************************
*
*   MathParser
*   ¯¯¯¯¯¯¯¯¯¯
*   By looking_for_help aka eey
*
*   This system provides methods for parsing mathematically string expressions,
*   represented as strings. Also methods for formating string expressions are
*   provided, making it possible to implement an ingame calculator to the game.
*
***********************************************************************************
*
*   Requirements
*   ¯¯¯¯¯¯¯¯¯¯¯¯
*   */  uses Maths   /*  hiveworkshop.com/forums/spells-569/advanced-maths-ingame-calculator-234024/?prev=r%3D20%26page%3D5
*
***********************************************************************************
*
*   Implementation
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*   To use this system, you need the library Math. Once you implemented it, just
*   copy this script to your trigger editor, then you can use it straight away. To
*   see how the evaluation function works, compare the example IngameCalculator
*   trigger for an example usage.
*
***********************************************************************************
*
*   System API
*   ¯¯¯¯¯¯¯¯¯¯
*   readonly static real ans
*       - Stores the last result of the evaluation method. Initialized as 0.
*
*   static method calculate takes string expression returns real
*       - Use this method to calculate a mathematic expression presented as
*         a string. Allowed values are numbers, the decimal seperator, basic
*         arithmetic operators like +, -, *, / and ^ as well as parenthesis.
*         You can also put "ans" into the expression to refer to the last
*         calculation result. Error messages on math and syntax errors will
*         be displayed if specified so in the configurable globals. The
*         syntax parsing strictly follows Matlab conventions.
*
*   static method formatExpression takes string expression returns string
*       - Use this method to format an user defined expression so that it
*         looks nice. Compare the IngameCalculator trigger for an example
*         usage.
*
*********************************************************************************/

    globals
        /*************************************************************************
        *   Customizable globals
        *************************************************************************/
       
        // Do you want the system to display error messages on math errors?
        private constant boolean DISPLAY_MATH_ERRORS = false
       
        // Do you want the system to display error messages on syntax errors?
        private constant boolean DISPLAY_SYNTAX_ERRORS = false
           
        /*************************************************************************
        *   End of customizable globals
        *************************************************************************/
    endglobals

    private module Init
        private static method onInit takes nothing returns nothing
            call init()
        endmethod
    endmodule
    
    private function SubStrSafe takes string str, integer start, integer end returns string
        if start < end then
            return SubString(str, start, end)
        else
            return null
        endif
    endfunction
   
    private function SubStrSafeSize takes string str, integer start, integer end, integer size returns string
        if start < end and end < size then
            return SubString(str, start, end)
        else
            return null
        endif
    endfunction
   
    struct MathParser extends array
        readonly static real ans = 0.0
        private static constant integer ADDITION = 1
        private static constant integer SUBSTRACTION = 2
        private static constant integer MULTIPLICATION = 3
        private static constant integer DIVISION = 4
        private static constant integer EXPONENTIATION = 5
        private static constant integer MODULO = 6
       
        private static method getPriority takes string op returns integer
            return LoadInteger(Maths_h, StringHash(op), 0)
        endmethod
   
        static constant method operator SUCCESS takes nothing returns integer
            return 0
        endmethod
        
        static constant method operator SYNTAX_ERROR takes nothing returns integer
            return 1
        endmethod
        
        static constant method operator MATH_ERROR takes nothing returns integer
            return 2
        endmethod
        
        static constant method operator UNARY_P takes nothing returns string
            return "["
        endmethod
        
        static constant method operator UNARY_M takes nothing returns string
            return "]"
        endmethod
        
        static constant method operator UNARY_p takes nothing returns string
            return "{"
        endmethod
        
        static constant method operator UNARY_m takes nothing returns string
            return "}"
        endmethod
            
   
        static integer wasError = 0
        static string errorString = ""
        private static method error takes string s, integer flag returns nothing
            local real crashThread
            if flag == 0 then
                set errorString = "|cffff0000Math Error!|r "+s
                static if DISPLAY_MATH_ERRORS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 60.0, errorString)
                endif
                set wasError = 2
            else
                set errorString = "|cffff0000Syntax Error!|r "+s
                static if DISPLAY_SYNTAX_ERRORS then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 60.0, errorString)
                endif
                set wasError = 1
            endif
            set crashThread = 0/0
        endmethod
   
        private static method convertExpression takes string expression returns string
            local integer stringLen = StringLength(expression)
            local integer i = 0
            local integer stackCounter = -1
            local string postfix = ""
            local string array stack
            local string actualChar
            local string prevChar = null
            local boolean decimalDetected = false
            local boolean numberDetected = false
            local boolean numberOnceDetected = false
            local boolean unaryOperator = false
            local integer openBraces = 0

            loop
                exitwhen i > stringLen
                set actualChar = SubString(expression, i, i + 1)
                set unaryOperator = not (prevChar == ")" or Math.isDigit(prevChar))

                if actualChar == ")" and openBraces < 1 then
                    call thistype.error("Unbalanced parenthesis!", 1)
                endif
               
                if actualChar == thistype.UNARY_m or actualChar == thistype.UNARY_p or actualChar == thistype.UNARY_M or actualChar == thistype.UNARY_P then
                    call thistype.error("Undefined symbols used!", 1)
                endif
                if actualChar == "+" and unaryOperator and prevChar != "^"  then
                    set actualChar = thistype.UNARY_p
                elseif actualChar == "-" and unaryOperator and prevChar != "^" then
                    set actualChar = thistype.UNARY_m
                elseif actualChar == "-" and unaryOperator and prevChar == "^" then
                    set actualChar = thistype.UNARY_M
                elseif actualChar == "+" and unaryOperator and prevChar == "^" then
                    set actualChar = thistype.UNARY_P
                endif
                if Math.isDigit(actualChar) then
                    set postfix = postfix+actualChar
                    set numberDetected = true
                    set numberOnceDetected = true
                elseif actualChar == "." then
                    if decimalDetected == false and Math.isDigit(prevChar) and Math.isDigit(SubString(expression, i + 1, i + 2)) then
                       set postfix = postfix+actualChar
                       set decimalDetected = true
                    else
                        call thistype.error("Incorrect use of decimal point!", 1)
                    endif
                elseif thistype.isOperator(actualChar) or actualChar == "(" or actualChar == ")" then
                    set decimalDetected = false
                    if numberDetected then
                        set numberDetected = false
                        set postfix = postfix+" "
                    endif

                    if thistype.getPriority(actualChar) > thistype.getPriority(stack[stackCounter]) or actualChar == "("  then
                        set stackCounter = stackCounter + 1
                        set stack[stackCounter] = actualChar
                        if actualChar == "(" then
                            set openBraces = openBraces + 1
                        endif
                    elseif openBraces > 0 and actualChar != ")" and actualChar != "("  and thistype.getPriority(actualChar) <= thistype.getPriority(stack[stackCounter]) then
                        loop
                            exitwhen stack[stackCounter] == "("
                            set postfix = postfix+stack[stackCounter]+" "
                            set stackCounter = stackCounter - 1
                        endloop
                        set stackCounter = stackCounter + 1
                        set stack[stackCounter] = actualChar
                    else
                        if actualChar == ")" then
                            set openBraces = openBraces - 1
                            loop
                                exitwhen stack[stackCounter] == "("
                                set postfix = postfix+stack[stackCounter]+" "
                                set stackCounter = stackCounter - 1
                            endloop

                            set stack[stackCounter] = ""
                            set stackCounter = stackCounter - 1
                        else
                            loop
                                exitwhen stackCounter < 0
                                set postfix = postfix+stack[stackCounter]+" "
                                set stackCounter = stackCounter - 1
                            endloop
                            set stackCounter = stackCounter + 1
                            set stack[stackCounter] = actualChar
                        endif
                    endif
                else
                    if i != stringLen then
                        call thistype.error("Undefined symbols used!", 1)
                    endif
                endif
                set i = i + 1
                set prevChar = SubString(expression, i - 1, i)
            endloop

            if not numberOnceDetected then
                call thistype.error("Invalid expression!", 1)
            endif
            if stackCounter >= 0 then
                if openBraces > 0 then
                    call thistype.error("Unbalanced parenthesis!", 1)
                endif
                loop
                    exitwhen stackCounter < 0
                    if stack[stackCounter] != "(" then
                        if numberDetected then
                            set postfix = postfix+" "+stack[stackCounter]+" "
                            set numberDetected = false
                        else
                            set postfix = postfix+stack[stackCounter]+" "
                        endif
                    endif
                    set  stackCounter = stackCounter - 1
                endloop
            endif
            set stringLen = StringLength(postfix)
            if Math.isDigit(SubString(postfix, stringLen - 1, stringLen)) then
                set postfix = postfix+" "
            endif

            return postfix
        endmethod
       
        private static method subCalc takes string op1, string op2, string op returns real
            local real r1 = S2R(op1)
            local real r2 = S2R(op2)
            local integer localOp
           
            if op1 == null or op2 == null then
                call thistype.error("Unbalanced operators!", 1)
            endif
            set localOp = LoadInteger(Maths_h, StringHash(op), 1)
            if localOp < MULTIPLICATION then
                if localOp == ADDITION then
                    return r1 + r2
                else
                    return r1 - r2
                endif
            else
                if localOp == MULTIPLICATION then
                    return r1*r2
                elseif localOp == DIVISION then
                    if r2 == 0 then
                        call thistype.error("Division by zero!", 0)
                    endif
                    return r1/r2
                elseif localOp == MODULO then
                    if r2 == 0 then
                        call thistype.error("Division by zero (modulo)!", 0)
                    endif
                    return Math.mod(r1, r2)
                else
                    if r1 < 0.0 and not Math.isInteger(r2) then
                        call thistype.error("(N-th) square root from negative value not defined!", 0)
                    endif
                    return Pow(r1, r2)
                endif
            endif
            call thistype.error("Undefined operators!", 1)
            return 0.0
        endmethod
       
        private static method isOperator takes string s returns boolean
            return HaveSavedInteger(Maths_h, StringHash(s), 0)
        endmethod
       
        private static method prepareExpression takes string expression returns string
            local integer stringLen = StringLength(expression)
            local integer i = 0
            local string actualChar
            local string prevChar = null
            local string nextChar
           
            loop
                exitwhen i > stringLen
                set actualChar = SubString(expression, i, i + 1)
                if actualChar == " " then
                    set expression = SubString(expression, 0, i)+SubString(expression, i + 1, stringLen)
                    set i = i - 1
                endif
                set i = i + 1
            endloop
           
            set i = 0
            set stringLen = StringLength(expression)
            loop
                exitwhen i > stringLen
                
                if i+3 < stringLen then
                    if SubString(expression, i, i + 3) == "ans" then
                        set expression = SubString(expression, 0, i)+"("+R2S(ans)+")"+SubString(expression, i + 3, stringLen)
                        set stringLen = StringLength(expression)
                    endif
                endif
               
                set actualChar = SubString(expression, i, i + 1)
                set nextChar = SubString(expression, i + 1, i + 2)
               
                if actualChar == "+" then
                    if nextChar == "+" then
                        if Math.isDigit(prevChar) then
                            set expression = SubString(expression, 0, i)+"+"+SubStrSafe(expression, i + 2, stringLen)
                        else
                            set expression = SubString(expression, 0, i)+SubStrSafe(expression, i + 2, stringLen)
                        endif
                        set i = i - 1
                    elseif nextChar == "-" then
                        set expression = SubString(expression, 0, i)+"-"+SubStrSafe(expression, i + 2, stringLen)
                        set i = i - 1
                    endif
                elseif actualChar == "-" then
                    if nextChar == "+" then
                        set expression = SubString(expression, 0, i)+"-"+SubStrSafe(expression, i + 2, stringLen)
                        set i = i - 1
                    elseif nextChar == "-" then
                        if Math.isDigit(prevChar) then
                            set expression = SubString(expression, 0, i)+"+"+SubStrSafe(expression, i + 2, stringLen)
                        else
                            set expression = SubString(expression, 0, i)+SubStrSafe(expression, i + 2, stringLen)
                        endif
                        set i = i - 1
                    endif
                elseif actualChar == "(" and (Math.isDigit(prevChar) or prevChar == ")") then
                    set expression = SubString(expression, 0, i)+"*"+SubString(expression, i, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                elseif actualChar == ")" and Math.isDigit(nextChar) then
                    set expression = SubString(expression, 0, i + 1)+"*"+SubString(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                endif
                set i = i + 1
                set prevChar = SubString(expression, i - 1, i)
            endloop
           
            return expression
        endmethod
       
        private static method evaluateExpression takes string postfix returns real
            local integer stringLen = StringLength(postfix)
            local integer i = 0
            local integer position = 0
            local integer counter = 0
            local integer stackCounter = -1
            local string actualToken
            local string array stack
            local real result = 0.0

            loop
                exitwhen i == stringLen
                if SubString(postfix, i, i + 1) == " " then
                    set actualToken = SubString(postfix, position, position + counter)
                    if Math.isDigit(SubString(actualToken, 0, 1)) then
                        set stackCounter = stackCounter + 1
                        set stack[stackCounter] = actualToken
                    else
                        if not (actualToken == "m " or actualToken == "p " or actualToken == "M " or actualToken == "P ") then
                            set result = thistype.subCalc(stack[stackCounter - 1], stack[stackCounter], actualToken)
                            set stack[stackCounter] = ""
                            set stack[stackCounter - 1] = R2S(result)
                            set stackCounter = stackCounter - 1
                        else
                            if actualToken == "m " or actualToken == "M " then
                                if S2R(stack[stackCounter]) > 0 then
                                    set stack[stackCounter] = "-"+stack[stackCounter]
                                else
                                    set stack[stackCounter] = SubString(stack[stackCounter], 1, StringLength(stack[stackCounter]))
                                endif
                            endif
                        endif
                    endif
                    set position = i + 1
                    set counter = 0
                endif
                set i = i + 1
                set counter = counter + 1
            endloop

            set thistype.wasError = thistype.SUCCESS
            return S2R(stack[0])
        endmethod
        
        static method calculateUnsafe takes string expression returns real
            set ans = thistype.evaluateExpression(thistype.convertExpression(thistype.prepareExpression(expression)))
            return ans
        endmethod
        
        private static method calculate_impl takes nothing returns nothing
            set ans = thistype.evaluateExpression.evaluate(thistype.convertExpression(thistype.prepareExpression(thistype.errorString)))
        endmethod
   
        static method calculate takes string expression returns real
            if StringLength(expression) == 0 then
                set ans = 0.
                return 0.
            endif
        
            set thistype.errorString = expression
            call ForForce(bj_FORCE_PLAYER[0], function thistype.calculate_impl)
            if wasError != thistype.SUCCESS then
                call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "("+expression+"): " + errorString)
                set ans = 0
            // else
                // call DisplayTextToPlayer(GetTriggerPlayer(), 0.7, 0.5, "("+expression+")= " + R2S(ans))
            endif
            return ans
        endmethod
       
        static method formatExpression takes string expression returns string
            local integer i = 0
            local integer stringLen = StringLength(expression)
            local string prevChar
            local string nextChar
            local string actualChar
            local string prevAnsToken
            local string nextAnsToken
            local boolean unaryOperator = false
           
            loop
                exitwhen i > stringLen
                if SubString(expression, i, i + 1) == " " then
                    set expression = SubString(expression, 0, i)+SubString(expression, i + 1, stringLen)
                    set i = i - 1
                endif
                set i = i + 1
            endloop
           
            set i = 0
            set stringLen = StringLength(expression)
            loop
                exitwhen i > stringLen
                set actualChar = SubString(expression, i, i + 1)
                if actualChar == "+" then
                    if SubString(expression, i + 1, i + 2) == "+" then
                        if Math.isDigit(SubString(expression, i - 1, i)) then
                            set expression = SubString(expression, 0, i)+"+"+SubStrSafe(expression, i + 2, stringLen)
                        else
                            set expression = SubString(expression, 0, i)+SubStrSafe(expression, i + 2, stringLen)
                        endif
                        set i = i - 1
                    elseif SubString(expression, i + 1, i + 2) == "-" then
                        set expression = SubString(expression, 0, i)+"-"+SubStrSafe(expression, i + 2, stringLen)
                        set i = i - 1
                    endif
                elseif actualChar == "-" then
                    if SubString(expression, i + 1, i + 2) == "+" then
                        set expression = SubString(expression, 0, i)+"-"+SubStrSafe(expression, i + 2, stringLen)
                        set i = i - 1
                    elseif SubString(expression, i + 1, i + 2) == "-" then
                        if Math.isDigit(SubString(expression, i - 1, i)) then
                            set expression = SubString(expression, 0, i)+"+"+SubStrSafe(expression, i + 2, stringLen)
                        else
                            set expression = SubString(expression, 0, i)+SubStrSafe(expression, i + 2, stringLen)
                        endif
                        set i = i - 1
                    endif
                endif
                set i = i + 1
            endloop
           
            set i = 0
            set stringLen = StringLength(expression)
            loop
                exitwhen i > stringLen
                set actualChar = SubString(expression, i, i + 1)
                set prevChar = SubString(expression, i - 1, i)
                set nextChar = SubString(expression, i + 1, i + 2)
                set prevAnsToken = SubString(expression, i - 3, i)
                set nextAnsToken = SubString(expression, i + 1, i + 4)
               
                set unaryOperator = not (prevChar == ")" or Math.isDigit(prevChar) or prevAnsToken == "ans")
                if actualChar == "+" and not unaryOperator then
                    set expression = SubString(expression, 0, i)+" + "+SubStrSafe(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i + 1
                elseif actualChar == "+" and unaryOperator then
                    set expression = SubString(expression, 0, i)+SubStrSafe(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                elseif actualChar == "-" and not unaryOperator then
                    set expression = SubString(expression, 0, i)+" - "+SubStrSafe(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i + 1
                elseif actualChar == "(" and (Math.isDigit(prevChar) or prevChar == ")") then
                    set expression = SubString(expression, 0, i)+"*"+SubString(expression, i, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                elseif actualChar == ")" and Math.isDigit(nextChar) then
                    set expression = SubString(expression, 0, i + 1)+"*"+SubStrSafe(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                endif
                if prevAnsToken == "ans" and (Math.isDigit(actualChar) or actualChar == "(" or SubStrSafeSize(expression, i, i + 3, stringLen) == "ans") then
                    set expression = SubString(expression, 0, i)+"*"+SubString(expression, i, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                elseif nextAnsToken == "ans" and (Math.isDigit(actualChar) or actualChar == ")") then
                    set expression = SubString(expression, 0, i + 1)+"*"+SubStrSafe(expression, i + 1, stringLen)
                    set stringLen = StringLength(expression)
                    set i = i - 1
                endif
               
                set i = i + 1
            endloop
           
            return expression
        endmethod
       
        private static method init takes nothing returns nothing
            call SaveInteger(Maths_h, StringHash("+"), 0, 1)
            call SaveInteger(Maths_h, StringHash("-"), 0, 1)
            call SaveInteger(Maths_h, StringHash("*"), 0, 2)
            call SaveInteger(Maths_h, StringHash("/"), 0, 2)
            call SaveInteger(Maths_h, StringHash("%"), 0, 2)
            call SaveInteger(Maths_h, StringHash(thistype.UNARY_m), 0, 3)
            call SaveInteger(Maths_h, StringHash(thistype.UNARY_p), 0, 3)
            call SaveInteger(Maths_h, StringHash("^"), 0, 4)
            call SaveInteger(Maths_h, StringHash(thistype.UNARY_M), 0, 5)
            call SaveInteger(Maths_h, StringHash(thistype.UNARY_P), 0, 5)
            call SaveInteger(Maths_h, StringHash("("), 0, 6)
            call SaveInteger(Maths_h, StringHash("+ "), 1, ADDITION)
            call SaveInteger(Maths_h, StringHash("- "), 1, SUBSTRACTION)
            call SaveInteger(Maths_h, StringHash("* "), 1, MULTIPLICATION)
            call SaveInteger(Maths_h, StringHash("/ "), 1, DIVISION)
            call SaveInteger(Maths_h, StringHash("^ "), 1, EXPONENTIATION)
            call SaveInteger(Maths_h, StringHash("% "), 1, MODULO)
        endmethod
       
        implement Init
    endstruct
endlibrary