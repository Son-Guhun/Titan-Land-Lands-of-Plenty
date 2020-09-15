
library Matrices /* v 1.4.0.0
**********************************************************************************
*
*   Matrices
*   ¯¯¯¯¯¯¯¯
*   By looking_for_help aka eey
*
*   This system provides advanced methods for handling Matrices in Warcraft 3.
*   Features like Matrix multiplication, calculation of norms or trace as well as
*   solving a system of linear equations with Gauss-Elimination are implemented.
*   The system also provides a big variety of functions to initialize, copy or
*   reshape Matrices.
*
*   Credits go to Magtheridon for helping with the Systems API.
*  
**********************************************************************************
*
*   Requirements
*   ¯¯¯¯¯¯¯¯¯¯¯¯
*   */  uses Maths   /*  hiveworkshop.com/forums/spells-569/advanced-maths-ingame-calculator-234024/?prev=r%3D20%26page%3D5
*
**********************************************************************************
*
*   Implementation
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*   To use this system just copy it into an empty trigger in your map. As this
*   system uses the Math library you should install it first to get the system
*   to work. The Math library can be found under the link above.
*
**********************************************************************************
*
*   System API
*   ¯¯¯¯¯¯¯¯¯¯
*
*   Struct usage
*   -----------------------------
*
*       struct Matrix
*           - This struct provides the methods and logic to use Matrices in
*             Warcraft 3 with this system. Use the create method to allocate a
*             new instance of a Matrix of your desired size. The Matrix can then
*             be used like a 2D-Array (example displayed above) and provides  
*             various methods to perform advanced Matrix operations.
*                            
*                                                          0  1  2    
*                                                       0 [0][0][0]
*             local Matrix mat = Matrix.create(3, 3) =  1 [0][0][0]
*                                                       2 [0][0][0]
*
*
*   Operators
*   -----------------------------
*
*       [] operators
*           - Use the [] operators to access directly to the values of a given
*             Matrix. For example mat[2][1] will return the element in the third
*             row, second column. Note that the indices are, like Wc3 arrays,
*             zero-based.
*
*
*   Fields
*   -----------------------------
*
*       readonly integer n
*           - Specifies the number of rows of a given Matrix.
*
*       readonly integer m
*           - Specifies the number of columns of a given Matrix.
*
*       readonly static Matrix Invalid_Matrix
*           - An invalid Matrix of the size 0 x 0. You can't create such a Matrix,
*             so if you need one, use this field. Some algorithms, such as solveSLE
*             return such a Matrix if no solution for a given System of Linear
*             Equations could be found. You can use the method isValid() to
*             determine wether a Matrix is valid or not.      
*
*       static constant integer ONE_NORM
*           - Use this as a parameter for the norm method to specify that the method
*             should calculate the one norm (maximum of column sum absolute values).
*
*       static constant integer EUCLIDEAN_NORM
*           - Use this as a parameter for the norm method to specify that the method
*             should calculate the euclidean norm (square root of sum of squares).
*
*       static constant integer INFINITY_NORM
*           - Use this as a parameter for the norm method to specify that the method
*             should calculate the infinity norm (maximum of row sum absolute values).
*
*       static constant integer METHOD_ROW_WISE
*           - Use this as a parameter for methods like initStepWise or reShape to
*             specify whether the method should be applied row-wise.
*
*       static constant integer METHOD_COL_WISE
*           - Use this as a parameter for methods like initStepWise or reShape to
*             specify whether the method should be applied col-wise.
*
*
*   Methods
*   -----------------------------
*
*       static method create takes integer nDim, integer mDim returns Matrix
*           - Creates a new n x m Matrix with the maximum size of MAX_MATRIX_SIZE
*             (specified in the globals block). The Matrix is initialized with
*             zeros.
*
*       method destroy takes nothing returns nothing
*           - Destroys a given Matrix to free its memory usage.
*  
*       method display takes nothing returns nothing
*           - Use this method to display a Matrix ingame. This is especially
*             meant for debugging issues.
*
*       method isValid takes nothing returns boolean
*           - Checks whether a given Matrix is valid (means: not empty) or not.
*
*       method isEqual takes Matrix mat returns boolean
*           - Checks whether two Matrices are equal or not. If A == B then
*             A.isEqual(B) returns true.
*
*       method init takes real value returns nothing
*           - Use this method to initialize a Matrix with a desired real value.
*             Note that this method does not create a new instance of the Matrix
*             object, as well as all methods that only initialize the values of a
*             Matrix.
*
*       method eye takes nothing returns nothing
*           - Use this method to initialize an Identity Matrix.
*
*       method diag takes real value, integer whichDiagonal returns nothing
*           - Use this method to initialize a Diagonal Matrix with a desired real
*             value. Use the second argument to specify which diagonal you want
*             to set (zero is the main diagonal, negative values address the
*             upper, positive values the lower diagonals).
*
*       method rand takes real lowerBound, real upperBound returns nothing
*           - Use this method to initialize a Matrix with random real values.
*
*       method initStepWise takes real startValue, real steps returns nothing
*           - Use this method to initialize a matrix from a given start value in
*             ascending or descending order specified by the steps parameter.
*
*       method assign takes nothing returns Matrix
*           - Use this method to assign a Matrix to another Matrix. For example
*             set B = A.assign() will copy A to B. Note that A and B must be of
*             equal size for this operation to work.
*
*       method addScalar takes real value returns Matrix
*           - This method performs a element-wise addition of a given real value
*             and returns the new Matrix. Example: A.addScalar(2.0) will add the
*             value 2.0 to all elements of the Matrix A.
*
*       method subScalar takes real value returns Matrix
*           - This method performs a element-wise subtraction of a given real
*             value.
*
*       method multScalar takes real value returns Matrix
*           - This method performs a element-wise multiplication by a given real
*             value.
*
*       method divScalar takes real value returns Matrix
*           - This method performs a element-wise division by a given real value.
*
*       method abs takes nothing returns Matrix
*           - This method performs the abs function on all Matrix elements.
*
*       method add takes Matrix whichMatrix returns Matrix
*           - Matrix addition. The expression A.add(B) where both A and B are
*             Matrices returns the resulting Matrix A + B. Note that the Matrices
*             must follow common Matrix calculation rules, like here that A and B
*             have the same size.
*
*       method sub takes Matrix whichMatrix returns Matrix
*           - Matrix substraction. Same as the add method, A.sub(B) performs
*             A - B.
*
*       method multiply takes Matrix whichMatrix returns Matrix
*           - Matrix multiplication. The expression A.multiply(B) performs the
*             operation A*B. Note that A's number of columns must equal B's
*             number of rows for this operation to be well-defined.
*
*       method transpose takes nothing returns Matrix
*           - Matrix transposition. The expression A.transpose() computes A^T.
*
*       method invert takes nothing returns Matrix
*           - Matrix inversion. Use A.invert() to calculate A^-1, the inverse
*             of the Matrix A. Be aware of the fact that not every Matrix is
*             invertable.
*
*       method gauss takes nothing returns Matrix
*           - Use this method to perform a Gauss-Elimination with pivotising.
*             The result is a upper triangular Matrix.
*
*       method solveSLE takes Matrix b returns Matrix
*           - Use this method to solve a System of Linear Equations following
*             the common notation A*x = b. To calculate x use A.solveSLE(b)
*             where A is the system Matrix and b is the solution vector. If the
*             SLE has no unique solution, an invalid vector of size 0 x 0 is
*             returned.
*
*       method dotProduct takes Matrix b returns real
*           - Use this method to calculate the dot product of two Vectors. Use
*             it like a.dotProduct(b), which results in a^T*b. Calling this
*             method is faster than performing the transposition manualy and
*             should therefore be used if possible. To check whether two Vectors
*             are orthogonal, the dot product must be zero.
*
*       method crossProduct takes Matrix b returns Matrix
*           - Use this method to calculate the cross product of two Vectors.
*             This implementation only supports calculation of cross products
*             for Vectors in R^3.
*
*       method trace takes nothing returns real
*           - Returns the trace of a given Matrix. Which is defined as the sum
*             over its diagonal elements.
*
*       method det takes nothing returns real
*           - Returns the determinant of a given Matrix. From A.det() == 0
*             follows for example that A is not invertable.
*
*       method rank takes nothing returns integer
*           - Returns the rank of a given Matrix. A square Matrix must have full
*             rank to be invertable, which means that A.rank() == A.n must return
*             true.
*
*       method norm takes integer whichNorm returns real
*           - Computes the norm of a given Matrix. You can choose between different
*             norms by using the constants defined in the Matrix struct. Valid
*             values for the whichNorm parameter are ONE_NORM, EUCLIDEAN_NORM
*             and the INFINITY_NORM.
*
*       method cond takes integer whichNorm returns real
*           - Computes the condition of a Matrix. You can specify which Norm you
*             want to use for that purpose by the parameter whichNorm (see method
*             norm). Note that the Matrix must be invertable otherwise the
*             condition will be infinity.
*
*       method kron takes Matrix mat returns Matrix
*           - Computes the Kronecker Product of two Matrices. The result of for
*             example A.kron(B) where A is a n x m and B is a p x q Matrix is
*             a n*p x m*q Matrix. As you see this operation potentially produces
*             very big Matrices so use it with care.
*
*       method subMatrix takes integer startRow, integer startCol, integer endRow,
*                        integer endCol returns Matrix
*           - This method can be used to get a sub Matrix out of another Matrix.
*             With the parameters startRow and startCol you can specify where
*             the submatrix should begin and the parameters endRow as well as
*             endCol define where to end the sub Matrix. If A is for example
*             a 3 x 3 Matrix, A.subMatrix(0, 0, 2, 0) will return the first
*             column Vector of A, while A.subMatrix(0, 0, 1, 1) will return
*             the first 2 x 2 sub Matrix of A and so on.
*
*       method embed takes Matrix subMat, integer startRow, integer startCol
*                    returns Matrix
*           - This method embeds one Matrix into another. If you have for example
*             the 3 x 3 Matrix A and the 2 x 2 Matrix B then A.embed(B, 0, 0)
*             will assign the upper left sub matrix of A to the values of B. The
*             parameters startRow and startCol specify where the embeding should
*             start. Of course the sub matrix must fit into the Matrix you want to
*             embed it into, otherwise an error will be thrown.
*
*       method concatH takes Matrix mat returns Matrix
*           - Use this method to concatenate two Matrices. The Matrices must
*             have the same amount of rows for this operation to work. The Matrices
*             will get concatenated horizontal, resulting for  two n x m
*             Matrices in a n x 2*m Matrix. Example: A.concatH(B) will concate-
*             nate A to B (from the left side).
*
*       method concatV takes Matrix mat returns Matrix
*           - Use this method to concatenate two Matrices. The Matrices must
*             have the same amount of columns for this operation to work. The
*             Matrices will get concatenated vertically, resulting for two n x m
*             Matrices in a 2*n x m Matrix. Example: A.concatV(B) will stack
*             the Matrix B on A.
*
*       method reShape takes integer newN, integer newM, integer whichMethod
*                      returns Matrix
*           - Use this method to reshape a Matrix. If you have for example a
*             3 x 2 Matrix A, by performing A.reShape(2, 3, METHOD_ROW_WISE)
*             the Matrix will get a 2 x 3 Matrix. The third parameter whichMethod
*             determines whether the operation should be done row-wise or
*             column-wise. METHOD_ROW_WISE and METHOD_COL_WISE are valid
*             parameters. This can also be used to make a Vektor of a Matrix
*             (or vice versa): A.reShape(6, 1, METHOD_COL_WISE) will stack
*             all column Vektors of A to one 6 x 1 Vektor.
*
*       method switchRow takes integer whichRow, integer newRow returns Matrix
*           - Use this method to switch two different rows of a Matrix. The  
*             expression A.switchRow(0, 2) will switch the first with the third
*             row. Note that both parameters whichRow and newRow must not exceed
*             Matrix dimensions.
*
*       method switchCol takes integer whichCol, integer newCol returns Matrix
*           - Use this method to switch two different columns of a Matrix. Same
*             rules as for switchRow apply here.
*  
*********************************************************************************/

    globals
        /*************************************************************************
        *   Configurable globals
        *************************************************************************/
   
        // Accuracy for considering a Matrix too close to singularity
        private constant real EPSILON = 0.01
   
        // Biggest possible n x n-Matrix
        private constant integer MAX_MATRIX_SIZE = 2147483647
       
        /*************************************************************************
        *   End of configurable globals
        *************************************************************************/
    endglobals
    
    

    private struct MatrixRow extends array
        debug integer maxCols
   
        method operator [] takes integer column returns real
            debug call ThrowError(this == 0, "Matrices", "[]", "MatrixRow", this, "Attempt to access null reference!")
            return Table(this).real[column]
        endmethod

        method operator []= takes integer column, real value returns nothing
            debug call ThrowError(this == 0, "Matrices", "[]=", "MatrixRow", this, "Attempt to access null reference!")
            debug call ThrowError(column < 0 or column >= maxCols, "Matrices", "[]=", "MatrixRow", this, "Can't access Matrix! Column index "+I2S(column)+" exceeds Matrix dimensions!")
            set Table(this).real[column] = value
        endmethod
       
        static method create takes integer cols returns thistype
            local thistype this = Table.create()
            debug set this.maxCols = cols
            return this
        endmethod
    endstruct

    private module Inits
        private static method onInit takes nothing returns nothing
            set Matrix.Invalid_Matrix = Matrix.createInvalid()
        endmethod
    endmodule
   
    private module GETTER_MODULE
       
        method operator n takes nothing returns integer
            debug call ThrowError(this == 0, "Matrices", "n", "Matrix", this, "Attempt to access null reference!")
            return Table(this)[-1]
        endmethod
        method operator n= takes integer value returns nothing
            debug call ThrowError(this == 0, "Matrices", "n=", "Matrix", this, "Attempt to access null reference!")
            set Table(this)[-1] = value
        endmethod
       
        method operator m takes nothing returns integer
            debug call ThrowError(this == 0, "Matrices", "m", "Matrix", this, "Attempt to access null reference!")
            return Table(this)[-2]
        endmethod
        method operator m= takes integer value returns nothing
            debug call ThrowError(this == 0, "Matrices", "m=", "Matrix", this, "Attempt to access null reference!")
            set Table(this)[-2] = value
        endmethod
    endmodule
   
    struct Matrix extends array
        static constant integer ONE_NORM = 1
        static constant integer EUCLIDEAN_NORM = 2
        static constant integer INFINITY_NORM = 3
       
        static constant integer METHOD_ROW_WISE = 0
        static constant integer METHOD_COL_WISE = 1
       
        readonly static Matrix Invalid_Matrix
        implement GETTER_MODULE

        method operator [] takes integer row returns MatrixRow
            debug call ThrowError(this == 0, "Matrices", "[]", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(row < 0 or row >= n, "Matrices", "[]", "Matrix", this, "Can't access Matrix! Row index "+I2S(row)+" exceeds Matrix dimensions!")
            return Table(this)[row]
        endmethod
        
        method destroy takes nothing returns nothing
            call Table(this).destroy()
        endmethod
       
        static method create takes integer nDim, integer mDim returns thistype
            local integer i = 0
            local thistype this
           
            debug call ThrowError(nDim < 1, "Matrices", "create", "Matrix", 0, "Can't create Matrix with "+I2S(nDim)+" rows! Number of rows must be larger than zero!")
            debug call ThrowError(mDim < 1, "Matrices", "create", "Matrix", 0, "Can't create Matrix with "+I2S(mDim)+" columns! Number of columns must be larger than zero!")
            debug call ThrowError(nDim > MAX_MATRIX_SIZE, "Matrices", "create", "Matrix", 0, "Can't create Matrix with "+I2S(nDim)+" rows! Number of rows exceeds maximum row count of "+I2S(MAX_MATRIX_SIZE)+"!")
            debug call ThrowError(mDim > MAX_MATRIX_SIZE, "Matrices", "create", "Matrix", 0, "Can't create Matrix with "+I2S(mDim)+" columns! Number of columns exceeds maximum column count "+I2S(MAX_MATRIX_SIZE)+"!")
           
            set this = Table.create()
            loop
                exitwhen i > nDim - 1
                set Table(this)[i] = MatrixRow.create(mDim)
                set i = i + 1
            endloop
            set this.n = nDim
            set this.m = mDim
           
            return this
        endmethod
       
        private static method createInvalid takes nothing returns thistype
            local thistype this = Table.create()

            set this.n = 0
            set this.m = 0
           
            return this
        endmethod
       
        method isValid takes nothing returns boolean
            debug call ThrowError(this == 0, "Matrices", "isValid", "Matrix", this, "Attempt to access null reference!")
            return this.n == 0
        endmethod
       
        method isEqual takes Matrix mat returns boolean
            local integer i = 0
            local integer j = 0
       
            debug call ThrowError(this == 0, "Matrices", "isEqual", "Matrix", this, "Attempt to access null reference!")
       
            if this.n != mat.n or this.m != mat.m then
                return false
            endif
           
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    if this[i][j] != mat[i][j] then
                        return false
                    endif
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return true
        endmethod
       
        method addScalar takes real value returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat

            debug call ThrowError(this == 0, "Matrices", "addScalar", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "addScalar", "Matrix", this, "Cannot add "+R2S(value)+" to Matrix elements of and Invalid Matrix!")
           
            set mat = Matrix.create(n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set mat[i][j] = this[i][j] + value
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
       
        method subScalar takes real value returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat
           
            debug call ThrowError(this == 0, "Matrices", "subScalar", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "subScalar", "Matrix", this, "Cannot subtract "+R2S(value)+" to Matrix elements of and Invalid Matrix!")
           
            set mat = Matrix.create(n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set mat[i][j] = this[i][j] - value
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
       
        method multScalar takes real value returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat
           
            debug call ThrowError(this == 0, "Matrices", "multScalar", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "multScalar", "Matrix", this, "Cannot multiply "+R2S(value)+" to Matrix elements of and Invalid Matrix!")
           
            set mat = Matrix.create(n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set mat[i][j] = this[i][j]*value
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
       
        method divScalar takes real value returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat
           
            debug call ThrowError(this == 0, "Matrices", "divScalar", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "divScalar", "Matrix", this, "Cannot divide Matrix elements of Invalid Matrix by "+R2S(value)+"!")
           
            set mat = Matrix.create(n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set mat[i][j] = this[i][j]/value
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
       
        method abs takes nothing returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat
           
            debug call ThrowError(this == 0, "Matrices", "abs", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "abs", "Matrix", this, "Cannot perform absolute value to Matrix elements of and Invalid Matrix!")
           
            set mat = Matrix.create(n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    if this[i][j] >= 0 then
                        set mat[i][j] = this[i][j]
                    else
                        set mat[i][j] = -this[i][j]
                    endif
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
       
        method eye takes real value returns nothing
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "eye", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "eye", "Matrix", this, "Invalid Matrix!")
           
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    if i != j then
                        set this[j][i] = 0.0
                    else
                        set this[j][i] = 1.0
                    endif
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
        endmethod
       
        method diag takes real value, integer whichDiagonal returns nothing
            local integer i = 0
            local integer j = 0
            local integer minDim
           
            debug call ThrowError(this == 0, "Matrices", "diag", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "diag", "Matrix", this, "Invalid Matrix!")
           
            if n <= m then
                set minDim = n - 1
            else
                set minDim = m - 1
            endif
           
            debug call ThrowError(whichDiagonal > minDim, "Matrices", "diag", "Matrix", this, "Diagonal Index "+I2S(whichDiagonal)+" exceeds Matrix dimensions!")
           
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    if i != j - whichDiagonal then
                        set this[j][i] = 0.0
                    else
                        set this[j][i] = value
                    endif
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
        endmethod
       
        method init takes real value returns nothing
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "init", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "init", "Matrix", this, "Invalid Matrix!")
           
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    set this[j][i] = value
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
        endmethod
       
        method rand takes real lowerBound, real upperBound returns nothing
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "rand", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "rand", "Matrix", this, "Invalid Matrix!")
           
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    set this[j][i] = GetRandomReal(lowerBound, upperBound)
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
        endmethod
       
        method initStepWise takes real startValue, real step, integer whichMethod returns nothing
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "initStepWise", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "initStepWise", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(whichMethod != METHOD_ROW_WISE and whichMethod != METHOD_COL_WISE, "Matrices", "initStepWise", "Matrix", this, "Invalid method of number "+I2S(whichMethod)+" for initializing!")
           
            if whichMethod == METHOD_ROW_WISE then
                loop
                    exitwhen j >= n
                    loop
                        exitwhen i >= m
                        set this[j][i] = startValue
                        set startValue = startValue + step
                        set i = i + 1
                    endloop
                    set i = 0
                    set j = j + 1
                endloop
            elseif whichMethod == METHOD_COL_WISE then
                loop
                    exitwhen j >= m
                    loop
                        exitwhen i >= n
                        set this[i][j] = startValue
                        set startValue = startValue + step
                        set i = i + 1
                    endloop
                    set i = 0
                    set j = j + 1
                endloop
            endif
        endmethod
 
        method add takes Matrix mat returns Matrix
            local Matrix result
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "add", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "add", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(mat.n != this.n or mat.m != this.m, "Matrices", "add", "Matrix", this, "Cannot perform addition of a "+I2S(n)+" x "+I2S(m)+" with a "+I2S(mat.n)+" x "+I2S(mat.m)+" Matrix!")
           
            set result = Matrix.create(n, m)
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    set result[j][i] = this[j][i] + mat[j][i]
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
           
            return result
        endmethod
       
        method sub takes Matrix mat returns Matrix
            local Matrix result
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "sub", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "sub", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(mat.n != this.n or mat.m != this.m, "Matrices", "sub", "Matrix", this, "Cannot perform subtraction of a "+I2S(n)+" x "+I2S(m)+" with a "+I2S(mat.n)+" x "+I2S(mat.m)+" Matrix!")
           
            set result = Matrix.create(n, m)
            loop
                exitwhen j >= n
                loop
                    exitwhen i >= m
                    set result[j][i] = this[j][i] - mat[j][i]
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
           
            return result
        endmethod
 
        method multiply takes Matrix mat returns Matrix
            local Matrix result
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local real temp = 0.0
           
            debug call ThrowError(this == 0, "Matrices", "multiply", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "multiply", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(this.m != mat.n, "Matrices", "multiply", "Matrix", this, "Cannot perform multiplication of a "+I2S(n)+" x "+I2S(m)+" with a "+I2S(mat.n)+" x "+I2S(mat.m)+" Matrix!")
           
            set result = Matrix.create(n, mat.m)
            loop
                exitwhen j >= result.n
                loop
                    exitwhen k >= result.m
                    loop
                        exitwhen i >= this.m
                        set temp = temp + this[j][i]*mat[i][k]
                        set i = i + 1
                    endloop
                    set result[j][k] = temp
                    set i = 0
                    set temp = 0.0
                    set k = k + 1
                endloop
                set k = 0
                set j = j + 1
            endloop
           
            return result
        endmethod
 
        method transpose takes nothing returns Matrix
            local Matrix mat = Matrix.create(m, n)
            local integer i = 0
            local integer j = 0

            debug call ThrowError(this == 0, "Matrices", "transpose", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "transpose", "Matrix", this, "Invalid Matrix!")
           
            loop
                exitwhen j >= m
                loop
                    exitwhen i >= n
                    set mat[j][i] = this[i][j]
                    set i = i + 1
                endloop
                set i = 0
                set j = j + 1
            endloop
           
            return mat
        endmethod
        
        method assign takes nothing returns Matrix
            local integer i = 0
            local integer j = 0
            local Matrix mat = Matrix.create(n, m)
           
            debug call ThrowError(this == 0, "Matrices", "assign", "Matrix", this, "Attempt to access null reference!")
   
            if n < 1 then
                set mat = Invalid_Matrix
                return mat
            endif
           
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set mat[i][j] = this[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod

        method gauss takes nothing returns Matrix
            local Matrix mat
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer row
            local real maxVal = -Math.Inf
            local real pivot
           
            debug call ThrowError(this == 0, "Matrices", "gauss", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "gauss", "Matrix", this, "Invalid Matrix!")
           
            set mat = this.assign()
            loop
                exitwhen i >= n - 1
                set j = i
                set row = i
                loop
                    exitwhen j >= m
                    set pivot = Math.abs(mat[j][i])
                    if pivot > maxVal then
                        set maxVal = pivot
                        set row = j
                    endif
                    set j = j + 1
                endloop
               
                if Math.abs(pivot) < EPSILON then
                    debug call ThrowWarning(true, "Matrices", "gauss", "Matrix", this, "Can't perform Gauss Elimination, Matrix too close to singularity!")
                endif

                if row != i then
                    set j = 0
                    loop
                        exitwhen j >= m
                        set pivot = mat[i][j]
                        set mat[i][j] = mat[row][j]
                        set mat[row][j] = pivot
                        set j = j + 1
                    endloop
                endif

                if mat[i][i] >= EPSILON then
                    set j = i + 1
                    loop
                        exitwhen j >= n
                        set pivot = mat[j][i]/mat[i][i]
                        set k = i
                        loop
                            exitwhen k >= n
                            set mat[j][k] = mat[j][k] - pivot*mat[i][k]
                            set k = k + 1
                        endloop
                        set j = j + 1
                    endloop
                endif
                set i = i + 1
            endloop
       
            return mat
        endmethod
 
        method invert takes nothing returns Matrix
            local Matrix mat
            local Matrix inv
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer row
            local real maxVal = -Math.Inf
            local real pivot
            local real temp_inv
           
            debug call ThrowError(this == 0, "Matrices", "invert", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "invert", "Matrix", this, "Invalid Matrix!")
           
            set mat = this.assign()
            set inv = Matrix.create(n, n)
            call inv.eye(n)
            loop
                exitwhen i >= n - 1
                set j = i + 1
                set row = i
                loop
                    exitwhen j >= n
                    set pivot = Math.abs(mat[j][i])
                    if pivot > maxVal then
                        set maxVal = pivot
                        set row = j
                    endif
                    set j = j + 1
                endloop
               
                if Math.abs(pivot) < EPSILON then
                    debug call ThrowWarning(true, "Matrices", "invert", "Matrix", this, "Can't invert Matrix, too close to singularity!")
                    return Matrix.Invalid_Matrix
                endif
               
                if row != i then
                    set j = 0
                    loop
                        exitwhen j >= m
                        set pivot = mat[i][j]
                        set mat[i][j] = mat[row][j]
                        set mat[row][j] = pivot
                        set temp_inv = inv[i][j]
                        set inv[i][j] = inv[row][j]
                        set inv[row][j] = temp_inv
                        set j = j + 1
                    endloop
                endif
               
                set j = i + 1
                loop
                    exitwhen j >= n
                    set pivot = mat[j][i]/mat[i][i]
                    set k = 0
                    loop
                        exitwhen k >= n
                        set mat[j][k] = mat[j][k] - pivot*mat[i][k]
                        set inv[j][k] = inv[j][k] - pivot*inv[i][k]
                        set k = k + 1
                    endloop
                    set j = j + 1
                endloop
                set i = i + 1
            endloop
           
            set i = n - 1
            loop
                exitwhen i < 0
                set j = i - 1
                loop
                    exitwhen j < 0
                    set pivot = mat[j][i]/mat[i][i]
                    set mat[j][i] = mat[j][i] - pivot*mat[i][i]
                    set k = 0
                    loop
                        exitwhen k >= m
                        set inv[j][k] = inv[j][k] - pivot*inv[i][k]
                        set k = k + 1
                    endloop
                    set j = j - 1
                endloop
                set i = i - 1
            endloop
           
            set i = 0
            loop
                exitwhen i >= n
                set j = 0
                loop
                    exitwhen j >= m
                    set inv[i][j] = inv[i][j]/mat[i][i]
                    set j = j + 1
                endloop
                set i = i + 1
            endloop
            call mat.destroy()
           
            return inv
        endmethod
 
        method trace takes nothing returns real
            local integer i = 0
            local integer minDim
            local real result = 0.0
           
            debug call ThrowError(this == 0, "Matrices", "trace", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "trace", "Matrix", this, "Invalid Matrix!")
           
            if n <= m then
                set minDim = n - 1
            else
                set minDim = m - 1
            endif
           
            loop
                exitwhen i > minDim
                set result = result + this[i][i]
                set i = i + 1
            endloop
       
            return result
        endmethod
       
        method rank takes nothing returns integer
            local Matrix mat = this.assign()
            local integer minDim
            local integer i
            local integer rank
           
            debug call ThrowError(this == 0, "Matrices", "rank", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "rank", "Matrix", this, "Invalid Matrix!")
           
            if n <= m then
                set minDim = n - 1
            else
                set minDim = m - 1
            endif
           
            set i = minDim
            set rank = minDim + 1
            set mat = this.gauss()
           
            loop
                exitwhen i < 1
                if Math.abs(mat[i][i]) < EPSILON then
                    set rank = rank - 1
                endif
                set i = i - 1
            endloop
           
            return rank
        endmethod
        
        method norm takes integer whichNorm returns real
            local integer i = 0
            local integer j = 0
            local real result
            local real maxVal = -Math.Inf
           
            debug call ThrowError(this == 0, "Matrices", "norm", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "norm", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(whichNorm != ONE_NORM and whichNorm != EUCLIDEAN_NORM and whichNorm != INFINITY_NORM, "Matrices", "[]", "Matrix", this, "Invalid Norm with number "+I2S(whichNorm)+" used!")
           
            if whichNorm == ONE_NORM then
                set result = 0.0
                loop
                    exitwhen i >= m
                    loop
                        exitwhen j >= n
                        set result = result + Math.abs(this[j][i])
                        set j = j + 1
                    endloop
                    if result > maxVal then
                        set maxVal = result
                    endif
                    set result = 0.0
                    set j = 0
                    set i = i + 1
                endloop
                return maxVal
            elseif whichNorm == EUCLIDEAN_NORM then
                set result = 0.0
                loop
                    exitwhen i >= n
                    loop
                        exitwhen j >= m
                        set result = result + this[i][j]*this[i][j]
                        set j = j + 1
                    endloop
                    set j = 0
                    set i = i + 1
                endloop
                return SquareRoot(result)
            else
                set result = 0.0
                loop
                    exitwhen i >= n
                    loop
                        exitwhen j >= m
                        set result = result + Math.abs(this[i][j])
                        set j = j + 1
                    endloop
                    if result > maxVal then
                        set maxVal = result
                    endif
                    set result = 0.0
                    set j = 0
                    set i = i + 1
                endloop
                return maxVal
            endif
        endmethod
       
        method cond takes integer whichNorm returns real
            local Matrix mat
            local real result

            debug call ThrowError(this == 0, "Matrices", "cond", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "cond", "Matrix", this, "Invalid Matrix!")
           
            set mat = this.assign()
            set mat = mat.invert()
           
            if not mat.isValid() then
                debug call ThrowError(true, "Matrices", "cond", "Matrix", this, "Matrix has infinite condition!")
                return Math.Inf
            endif
           
            set mat = this.multiply(mat)
            set result = mat.norm(whichNorm)
            call mat.destroy()
            return result
        endmethod
       
        method det takes nothing returns real
            local Matrix mat
            local integer i = 0
            local real result = 1.0
           
            debug call ThrowError(this == 0, "Matrices", "det", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "det", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(n != m, "Matrices", "det", "Matrix", this, "Matrix "+I2S(n)+" x "+I2S(m)+" isn't square! Matrix must be square!")
           
            set mat = this.assign()
            set mat = mat.gauss()
           
            loop
                exitwhen i >= n
                set result = result*mat[i][i]
                set i = i + 1
            endloop
            if Math.abs(result) < EPSILON then
                set result = 0.0
            endif
           
            call mat.destroy()
            return result
        endmethod
   
        method solveSLE takes Matrix b returns Matrix
            local Matrix mat
            local Matrix sol
            local Matrix x
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer row
            local real maxVal = -Math.Inf
            local real pivot
           
            debug call ThrowError(this == 0, "Matrices", "solveSLE", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "solveSLE", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(this.n != this.m or b.n != this.n or b.m > 1, "Matrices", "solveSLE", "Matrix", this, "Invalid Matrices used! Can't solve SLE!")
           
            set mat = this.assign()
            set sol = b.assign()
            set x = Matrix.create(b.n, 1)
            loop
                exitwhen i >= n - 1
                set j = i + 1
                set row = i
                loop
                    exitwhen j >= n
                    set pivot = Math.abs(mat[j][i])
                    if pivot > maxVal then
                        set maxVal = pivot
                        set row = j
                    endif
                    set j = j + 1
                endloop
                set pivot = maxVal
               
                if Math.abs(pivot) < EPSILON then
                    return Matrix.Invalid_Matrix
                endif
               
                if row != i then
                    set j = 0
                    loop
                        exitwhen j >= m
                        set pivot = mat[i][j]
                        set mat[i][j] = mat[row][j]
                        set mat[row][j] = pivot
                        set j = j + 1
                    endloop
                    set pivot = sol[i][0]
                    set sol[i][0] = sol[row][0]
                    set sol[row][0] = pivot
                endif
               
                set j = i + 1
                loop
                    exitwhen j >= n
                    set pivot = mat[j][i]/mat[i][i]
                    set k = i
                    loop
                        exitwhen k >= n
                        set mat[j][k] = mat[j][k] - pivot*mat[i][k]
                        set k = k + 1
                    endloop
                    set sol[j][0] = sol[j][0] - pivot*sol[i][0]
                    set j = j + 1
                endloop
                set i = i + 1
            endloop
           
            set x[x.n - 1][0] = sol[x.n - 1][0]/mat[n - 1][n - 1]
            set i = x.n - 2
            loop
                exitwhen i < 0
                set pivot = sol[i][0]
                set j = i + 1
                loop
                    exitwhen j >= n
                    set pivot = pivot - mat[i][j]*x[j][0]
                    set j = j + 1
                endloop
                set x[i][0] = pivot/mat[i][i]
                set i = i - 1
            endloop
            call sol.destroy()
            call mat.destroy()
           
            return x
        endmethod
 
        method kron takes Matrix mat returns Matrix
            local Matrix result = Matrix.create(n*mat.n, m*mat.m)
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer l = 0
           
            debug call ThrowError(this == 0, "Matrices", "kron", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1 or mat.n < 1, "Matrices", "kron", "Matrix", this, "Can't compute Kronecker Product of Invalid Matrix!")
           
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= mat.n
                    loop
                        exitwhen k >= m
                        loop
                            exitwhen l >= mat.m
                            set result[i*n + k][j*m + l] = this[i][j]*mat[k][l]
                            set l = l + 1
                        endloop
                        set l = 0
                        set k = k + 1
                    endloop
                    set k = 0
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return result
        endmethod
 
        method dotProduct takes Matrix mat returns real
            local real temp = 0.0
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "dotProduct", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1 or mat.n < 1, "Matrices", "dotProduct", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(mat.m != 1 or this.m != 1, "Matrices", "dotProduct", "Matrix", this, "Dot-Product is only defined for Vectors!")
            debug call ThrowError(mat.n != this.n, "Matrices", "dotProduct", "Matrix", this, "Dot-Product is only defined for Vectors of same length!")
           
            loop
                exitwhen i > n
                set temp = temp + this[i][1]*mat[i][1]
                set i = i + 1
            endloop
           
            return temp
        endmethod
 
        method crossProduct takes Matrix mat returns Matrix
            local Matrix result
       
            debug call ThrowError(this == 0, "Matrices", "crossProduct", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1 or mat.n < 1, "Matrices", "crossProduct", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(mat.m != 1 or this.m != 1, "Matrices", "crossProduct", "Matrix", this, "Cross-Product is only defined for Vectors!")
            debug call ThrowError(mat.n != this.n, "Matrices", "crossProduct", "Matrix", this, "Cross-Product is only defined for Vectors of same length!")
            debug call ThrowError(mat.n != 3 or this.n != 3, "Matrices", "crossProduct", "Matrix", this, "This implementation only supports Cross-Products for Vectors in R^3")
           
            set result = Matrix.create(3, 1)
            set result[0][0] = this[1][0]*mat[2][0] - this[2][0]*mat[1][0]
            set result[1][0] = this[2][0]*mat[0][0] - this[0][0]*mat[2][0]
            set result[2][0] = this[0][0]*mat[1][0] - this[1][0]*mat[0][0]
           
            return result
        endmethod
 
        method reShape takes integer newN, integer newM, integer whichMethod returns Matrix
            local Matrix mat
            local integer i = 0
            local integer j = 0
            local integer row = 0
            local integer col = 0
           
            debug call ThrowError(this == 0, "Matrices", "reShape", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "reShape", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(newN*newM != n*m, "Matrices", "reShape", "Matrix", this, "Can't reshape a "+I2S(n)+" x "+I2S(m)+" Matrix to a "+I2S(newN)+" x "+I2S(newM)+" Matrix! Dimension missmatch!")
            debug call ThrowError(newN < 1 or newM < 1, "Matrices", "reShape", "Matrix", this, "Reshape not possible! Index must be greater than zero!")
            debug call ThrowError(whichMethod != METHOD_ROW_WISE and whichMethod != METHOD_COL_WISE, "Matrices", "reShape", "Matrix", this, "Invalid method with number "+I2S(whichMethod)+" for reshaping!")
           
            set mat = Matrix.create(newN, newM)
           
            if whichMethod == METHOD_ROW_WISE then
                loop
                    exitwhen i >= n
                    loop
                        exitwhen j >= m
                        set mat[row][col] = this[i][j]
                        set col = col + 1
                        if col >= mat.m then
                            set row = row + 1
                            set col = 0
                        endif
                        set j = j + 1
                    endloop
                    set j = 0
                    set i = i + 1
                endloop
            elseif whichMethod == METHOD_COL_WISE then
                loop
                    exitwhen i >= m
                    loop
                        exitwhen j >= n
                        set mat[row][col] = this[j][i]
                        set col = col + 1
                        if col >= mat.m then
                            set row = row + 1
                            set col = 0
                        endif
                        set j = j + 1
                    endloop
                    set j = 0
                    set i = i + 1
                endloop
            endif
           
            return mat
        endmethod
 
        method embed takes Matrix subMat, integer startRow, integer startCol returns Matrix
            local Matrix mat
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "embed", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n == 0 or subMat.n == 0, "Matrices", "embed", "Matrix", this, "Can't embed sub Matrix! This is an invalid Matrix!")
            debug call ThrowError(startRow < 0 or startCol < 0, "Matrices", "embed", "Matrix", this, "Can't merge Matrices to start row "+I2S(startRow)+" and start column "+I2S(startCol)+"! Index must be greater than 0!")
            debug call ThrowError(startRow + subMat.n - 1 > n or startCol + subMat.m - 1 > m, "Matrices", "embed", "Matrix", this, "Can't merge Matrices to start row "+I2S(startRow)+" and start column "+I2S(startCol)+"! Matrices don't fit!")
           
            set mat = this.assign()
            loop
                exitwhen i >= subMat.n
                loop
                    exitwhen j >= subMat.m
                    set mat[i + startRow][j + startCol] = subMat[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
 
        method subMatrix takes integer startRow, integer startCol, integer endRow, integer endCol returns Matrix
            local Matrix mat
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "subMatrix", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n == 0, "Matrices", "subMatrix", "Matrix", this, "Can't determine sub Matrix! This is an invalid Matrix!")
            debug call ThrowError(endRow < startRow or endCol < startCol, "Matrices", "subMatrix", "Matrix", this, "Can't determine sub Matrix! Size of sub Matrix smaller 1 x 1!")
            debug call ThrowError(endRow > n - 1 or endCol > m - 1, "Matrices", "subMatrix", "Matrix", this, "Sub Matrix of size "+I2S(endRow - startRow + 1)+" x "+I2S(endCol - startCol + 1)+" exceeds Matrix dimensions!")
           
            set mat = Matrix.create(endRow - startRow + 1, endCol - startCol + 1)
            loop
                exitwhen i >= mat.n
                loop
                    exitwhen j >= mat.m
                    set mat[i][j] = this[i + startRow][j + startCol]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return mat
        endmethod
   
        method concatV takes Matrix mat returns Matrix
            local Matrix result
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "concatV", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n == 0 or m == 0, "Matrices", "concatV", "Matrix", this, "Can't concat Invalid Matrices!")
            debug call ThrowError(m != mat.m, "Matrices", "concatV", "Matrix", this, "Can't concat Matrices! Matrix column dimensions must be equal!")
   
            set result = Matrix.create(n + mat.n, m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set result[i][j] = mat[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
            set i = 0
            set j = 0
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set result[i + n][j] = this[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
           
            return result
        endmethod
   
        method concatH takes Matrix mat returns Matrix
            local Matrix result
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "concatH", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n == 0 or m == 0, "Matrices", "concatH", "Matrix", this, "Can't concat Invalid Matrices!")
            debug call ThrowError(n != mat.n, "Matrices", "concatH", "Matrix", this, "Can't concat Matrices! Matrix row dimensions must be equal!")
           
            set result = Matrix.create(n, m + mat.m)
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set result[i][j] = this[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
            set i = 0
            set j = 0
            loop
                exitwhen i >= n
                loop
                    exitwhen j >= m
                    set result[i][j + m] = mat[i][j]
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop

            return result
        endmethod
 
        method switchRow takes integer whichRow, integer newRow returns nothing
            local real temp
            local integer i = 0
           
            debug call ThrowError(this == 0, "Matrices", "switchRow", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "switchRow", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(whichRow < 0 or whichRow >= n or newRow < 0 or newRow >= n, "Matrices", "switchRow", "Matrix", this, "Can't switch row "+I2S(whichRow)+" with "+I2S(newRow)+". Index exceeds Matrix dimensions!")
           
            loop
                exitwhen i >= this.m
                set temp = this[newRow][i]
                set this[newRow][i] = this[whichRow][i]
                set this[whichRow][i] = temp
                set i = i + 1
            endloop
        endmethod
 
        method switchCol takes integer whichCol, integer newCol returns nothing
            local real temp
            local integer i = 0
           
            debug call ThrowError(this == 0, "Matrices", "switchCol", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowError(n < 1, "Matrices", "switchCol", "Matrix", this, "Invalid Matrix!")
            debug call ThrowError(whichCol < 0 or whichCol >= n or newCol < 0 or newCol >= n, "Matrices", "switchCol", "Matrix", this, "Can't switch column "+I2S(whichCol)+" with "+I2S(newCol)+". Index exceeds Matrix dimensions!")
           
            loop
                exitwhen i >= this.n
                set temp = this[i][newCol]
                set this[i][newCol] = this[i][whichCol]
                set this[i][whichCol] = temp
                set i = i + 1
            endloop
        endmethod
 
        method display takes nothing returns nothing
            local string s = ""
            local integer i = 0
            local integer j = 0
           
            debug call ThrowError(this == 0, "Matrices", "display", "Matrix", this, "Attempt to access null reference!")
            debug call ThrowWarning(n < 1, "Matrices", "display", "Matrix", this, "Invalid Matrix can't be displayed!")
           
            loop
                exitwhen j >= this.n
                loop
                    exitwhen i >= this.m
                    set s = s + " " + R2S(this[j][i])
                    set i = i + 1
                endloop
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 60.0, s)
                set s = ""
                set i = 0
                set j = j + 1
            endloop
        endmethod
       
        implement Inits
    endstruct
endlibrary