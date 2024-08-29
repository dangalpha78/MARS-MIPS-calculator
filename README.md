

I.Introduction
A calculator is typically a portable electronic device used to perform calculations, ranging from basic arithmetic to complex mathematics.

The calculator idea starts from long ago where people would use items in their possession to count. After some time, when civilization became more and more advanced, mechanical calculators emerged and came to be one of the fundamental tools for a person. At the time, such tools can only offer very few functionalities, including addition and subtraction. After the invention of the first solid-state electronic calculator in the 1960s, calculators began to have memory storing capabilities. Therefore, complex instructions can be calculated. Nowadays, calculators are inseparable from the modern society. From elementary schools to university and marketplaces, these pocket-size devices can be found supporting people daily calculations anywhere in the world.
A simple modern calculator should be able to solve basic arithmetic such as addition, subtraction, multiplication, division, and utilizing memory. Some other frequently used functions include factorization, finding Lowest Common Multiple (LCM), Greatest Common Divisor (GCD), square roots, exponents, and converting bases.

II.Idea and Algorithm
	In designing a calculator, one fundamental consideration is the method by which mathematical expressions are evaluated. Traditional infix notation, where operators are placed between operands (e.g., 3 + 4 * 5), can introduce complexity due to operator precedence and the need for parentheses to clarify the order of operations. However, an alternative approach known as postfix notation offers a more streamlined solution. In postfix notation, also called Reverse Polish Notation (RPN), operators follow their operands, eliminating ambiguity and simplifying the evaluation process.
	Converting expressions from infix to postfix offers several advantages in implementing a calculator. In infix notation, operators are placed between operands, leading to complexity in evaluating expressions. However, by converting to postfix notation, we can completely eliminate this ambiguity. Postfix notation ensures that the order of operations is unambiguous, as each operator follows its operands. This simplifies the evaluation process and allows for more efficient parsing and calculation in the calculator implementation. Additionally, postfix notation removes the need for parentheses to indicate precedence, further streamlining the evaluation algorithm. Overall, converting infix to postfix notation facilitates a clearer and more straightforward approach to expression evaluation in a calculator.
	In simpler terms, here's how we convert an infix expression to a postfix expression:
1.We go through the infix expression from left to right.
2.If we encounter an operand (a number), we immediately add it to the postfix expression.
3.If we encounter an operator:
If the operator stack is empty, or if the precedence and associativity of the scanned operator are greater than those of the operator at the top of the stack, we push it onto the stack.
If the operator at the top of the stack has the same precedence as the scanned operator, or if the scanned operator is right-associative (^), we push it onto the stack.
Otherwise, we pop all operators from the stack that have greater or equal precedence compared to the scanned operator, and then push the scanned operator onto the stack.
4.If we encounter an open parenthesis '(', we push it onto the stack.
5.If we encounter a closing parenthesis ')', we pop operators from the stack and add them to the postfix expression until we reach an open parenthesis '('.
6.We repeat steps 2-5 until we have scanned the entire infix expression.
7.After scanning, we pop any remaining operators from the stack and add them to the postfix expression.
8.Finally, we have the postfix expression ready to be used in evaluation or further processing.

III.Calculator Implementation
1.Program Preview
Initially, the user inputs an infix expression, which the program then evaluates.
![image](https://github.com/user-attachments/assets/aa148b15-178c-4b52-8f75-dea1e7e5672c)
![image](https://github.com/user-attachments/assets/848ce67b-4b78-4d5b-8eab-55a26836c005)


Subsequently, the program furnishes the result and prompts the user to input another expression. 

After obtaining the expected calculation result, the user can input another operation to continue or stop the program by entering "quit".
![image](https://github.com/user-attachments/assets/d11bae70-5f5d-4b1a-855a-61e1380e3d47)


The program records both the user input and the outcomes of all expressions within a single session into a file named "calc_log.txt".
![image](https://github.com/user-attachments/assets/f0f1eb9f-f61e-4a32-9561-c035f5ddb10c)

2.Set Up Data Decleration
a)Array:
numPostfix: Space for storing numbers in postfix notation.
operatorStack: Space for a stack to hold operators during postfix evaluation.
postfixString: Space for storing the postfix expression string.
postfixOps: Space for storing operators in the postfix expression.
stack: General-purpose space for a stack.
resultString: Space for storing the result of the expression evaluation.
inputString, inputPostfix: Space for storing input strings, possibly for expression input and postfix conversion.
b)Constants
const0, const1, const10: Constants for numerical values.
constOp: Constant for representing an operation.
beginFac: Constant for initializing a factorial operation.
constPlus, constMinus, constMul, constDiv, constExp, constFac, constM: Constants representing mathematical operations.
c)Variables
converter, wordToConvert: Variables related to conversion or processing.
d)Strings and prompts
inputPrompt: Prompt asking the user to insert an expression.
invalidInput: Message indicating invalid characters in the expression.
quit: String indicating the user's intention to quit.
stars: Separator or divider string.
bluhbluh: Additional separator string.
newline: Newline character for formatting.
resultPrompt: Prompt indicating the result.
thankyouPrompt: When the program ends, it will prompt "Thank you" and "Goodbye" to acknowledge the completion of the session.
postfixPrompt: Prompt “Postfix "
fout: File path for logging or output.
3.Implementation
a)Convert into postfix
Handle the input string
Initially, we read and loop through the input string (infix expression). Here's the algorithm:
![image](https://github.com/user-attachments/assets/f11d62fd-7cfa-46c6-95d0-45613b00d7e5)


Explain in simple terms, I'm reading an input string and checking if it's valid or not. Then, I perform different processing data for each character in the string. After receiving the last character, I complete the input processing step.
Handle digits
When handling a numerical character, I convert it from a char to an int and then from an int to a double. After that, I add the converted value to a variable. If there are still digits after the decimal point, I multiply the variable by 10. If the number has decimal places after the ".", after converting the digit to a double, I divide it by 10 and add it to the storage variable. This process stops only when receiving a character that is not a digit.
![image](https://github.com/user-attachments/assets/8b5c8d07-d9ee-4002-b83e-2e29b5c0b615)

Handle operators
When processing operators, I handle them based on their precedence according to the following operator table:

Operators	Precedence
( )	        4
!	          3
^	          2
* /	        1
+ -	        0
If the operator stack is empty, we simply push the operator onto the stack. Otherwise, we compare the precedence of the operator with the operator at the top of the stack. If the operator on the stack has lower precedence, we push the new operator onto the stack. If the operator on the stack has higher or equal precedence, we pop operators from the stack and add them to the postfix expression until the stack is empty or the top operator has lower precedence. After that, we push the new operator onto the stack.
Additionally, since a number or an opening parenthesis may appear before an operator, we also add them to the postfix expression.
When we encounter a closing bracket ), we take all the operators from the operator stack and add them to the postfix expression until we find the matching opening bracket (. We don't include the opening bracket in the postfix expression. This ensures that all operations within the parentheses are evaluated first.
We repeat this process for all operators, based on the priority table of each operator.
![image](https://github.com/user-attachments/assets/4913cf42-a136-4a40-b66a-6e6ec345918e)

Handle M
If "M" appears in the first operation, its value will be 0. From the second operation onwards, "M" will store the result of the previous operation (provided the operation is valid).
b)Print postfix
With the given postfix array, we sequentially read each element in the array and print them one by one.
![image](https://github.com/user-attachments/assets/f15f81d8-7edb-4d58-8e15-3b00044ec7fb)

c)Calculation
With the given postfix array, we can read each element in the array. If the element is positive, we store it in a stack array. If the element is negative, we identify it as the corresponding operator and perform the corresponding calculation.
![image](https://github.com/user-attachments/assets/4e545e0c-6ccf-4cd6-8bc7-763d1b75956e)

If we finish processing the entire postfix array, we proceed to the step of printing the result.
d)Print result processing
After completing the processing of the postfix array, we'll print the result to a log file named "calc_log.txt". This involves opening the file and writing to it. Converting the result number back to characters for printing might be the most challenging part, as I'll need to iterate through the result and perform the string because the system call can only print characters.
Handle the terminal print
In the terminal print section, besides printing the first number in the stack array, we also need to store its value in a register for later use with "M".
Handle double to string
To convert from double to string, we need two steps:
The first step is to convert the integer part. For example, if we have the number 123.456, we need to store the digits 1, 2, 3 in an array of characters. The process is to convert 123.456 into the integer 123, then repeatedly divide by 10 to get the units and the remainder until the quotient is less than 1.
The second step is to convert the decimal part. We subtract the integer part from the original number, so for the example above, we subtract 123 from 123.456 to get 0.456. Then we multiply by 10 to get the next digit after the decimal point, and repeat this process 16 times to get the 16 digits after the decimal point.
![image](https://github.com/user-attachments/assets/eb2e971f-a20d-463b-9eb0-6e9d32b4572b)

IV.Preview of test cases
![image](https://github.com/user-attachments/assets/602bc3ca-0484-47f9-a336-85f7fee98454)
![image](https://github.com/user-attachments/assets/7a1a4ee0-c8fb-4069-95f4-a2ccee8dc2b3)


V.Summary
In summary, this assignment has enabled me to utilize MAR MIPS to create a basic calculator. However, limitations persist, particularly with complex calculations and unavoidable output inaccuracies. While effective for simple arithmetic, the calculator struggles with more advanced computations. Moving forward, enhancements are needed to address these limitations, possibly through improved algorithms or code optimization. Overall, while a solid starting point, further refinement is necessary to improve accuracy and versatility.
VI.Reference
"Convert Infix Expression to Postfix Expression" on GeeksforGeeks. Available at: https://www.geeksforgeeks.org/convert-infix-expression-to-postfix-expression/

"Operator precedence." OEIS Foundation Wiki. Available at: https://oeis.org/wiki/Operator_precedence
