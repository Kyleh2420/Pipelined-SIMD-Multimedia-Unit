#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>



void removeChar(char *str, char c) {
    int i, j;
    int len = strlen(str);
    for (i = j = 0; i < len; i++) {
        if (str[i] != c) {
            str[j++] = str[i];
        }
    }
    str[j] = '\0';
}

void slice(const char* str, char* result, size_t start, size_t end) {
    strncpy(result, str + start, end - start);
}
//This function will convert a long to a character array of a binary equivalent
char* long_to_binary(unsigned long k)

{
        static char c[65];
        c[0] = '\0';

        unsigned long val;
        for (val = 1UL << (sizeof(unsigned long)*8-1); val > 0; val >>= 1) {   
            strcat(c, ((k & val) == val) ? "1" : "0");
        }
        return c;
    }

//This function will take a base m character string and return a n bit binary value
//Ex: Input 7 --> 00111
//Ex: Input 31 --> 11111
//Ex: Input FFFF --> 1111111111111111
//Ex: Input 0000 --> 0000000000000000
char* char2Bin(char* charInput, int n, int m) {
    char* pEnd;

    //Technically I malloc here but never free.. I don't know where to, since it'll return the address and immedeately get used.
    char* binaryValue = malloc (sizeof(char)*n);

    //Convert the given string to a long
    long int li1 = strtol(charInput, &pEnd, m);

    //A little checksum - if the long li1 is greater than the bits that 2**n can hold, throw a warning in the console.
    if (li1 > pow(2, n) - 1) {
        printf("Error: %li cannot fit within a %d-bit binary", li1, n);
        printf("\nExiting with error");
        exit(1);
    }

    //Convert the long to a binary encoded string
    pEnd = long_to_binary(li1);

    //Limit to n bits
    //For some reason, when I copy-paste strlen(pEnd)-5 directly into the slice parameter, I get a segmentation fault
    int tmp = strlen(pEnd)-n;
    slice(pEnd, binaryValue, tmp, strlen(pEnd));
    binaryValue[n] = '\0';

    return binaryValue;
}

int main() {
    //Open a inputFile called "input.txt" in read only mode
    FILE* inputFile = fopen("assembly.txt", "r"); 

    //Open an outputFile called "output.txt" in write only mode
    FILE* outputFile = fopen("machineCode.txt", "w"); 
    char line[100];
    int lineIndex = 0;

    //Go line by line (Or until we hit 64 lines, our limit for the instruction buffer)
    while (fgets(line, sizeof(line), inputFile) && lineIndex < 64) {
        //There can be up to 5 arguements per line, each limited to 7 characters long + 1 null terminating character
        char args[5][7+1] = { '\0' };

        //The OPCode to be printed to the outputfile. Is 25 characters long + 1 null terminating character
        char opcodeOut[25+1] = { '\0' };
        int spaceIndex = 0;
        int currentArg = 0;

        printf("\n\n%s", line);
        //Remove the commas and the rs (which stand for registers)
        removeChar(line, ',');

        //Going char by char in the line, we will also parse out the arguements to put in the 2d array args
        for (int i = 0; line[i]; i++) {
            //First, make sure that everything is lowercase
            line[i] = tolower(line[i]);

            //If we detect a space or a newline char, we are at the end of the word
            //spaceIndex identifies the last space, while i represents the current space.
            //Between these is the arguement to be parsed. Copy that over to the args array
            if (line[i] == ' ' || line[i] == '\n') {
                //Copy the string to the args array, starting from the spaceIndex character and for i-spaceIndex characters
                strncpy(args[currentArg], line+spaceIndex, i-spaceIndex);
                //strncpy does not add a null terminator. We must do that (Even though the whole array is already initialized to \0, this is just good practice)
                args[currentArg][i-spaceIndex] = '\0';
                spaceIndex = i+1;
                currentArg++;
            }
        }
        //Arguments have been seperated by spaces

        //Remove the r (Which stands for registers) from every arguement beyond arg[0]
        for (int i = 1; i < 5; i++) {
            removeChar(args[i], 'r');
        }
        //There's probably a better way to do this. I can think of one: A hashmap and a switch statement.
        //However, since this is a simple instructionset with minimal instructions, I have elected to use a if-else ladder
        //If this was a more complicated assembler, the smarter way would be a hashmap
        if(strcmp(args[0], "li") == 0) {
            //For some reason, without this printf statement, the program segfaults. THIS IS IMPORTANT
            strcat(opcodeOut, "0");
            strcat(opcodeOut, char2Bin(args[2], 3, 10));
            strcat(opcodeOut, char2Bin(args[3], 16, 16));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "simal") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "000");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "simah") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "001");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "simsl") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "010");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "simsh") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "011");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "slmal") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "100");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "slmah") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "101");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "slmsl") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "110");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "slmsh") == 0){
            //Do Something
            strcat(opcodeOut, "10");
            strcat(opcodeOut, "111");
            strcat(opcodeOut, char2Bin(args[4], 5, 10));
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "nop") == 0){
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000000");
            strcat(opcodeOut, "00000");
            strcat(opcodeOut, "00000");
            strcat(opcodeOut, "00000");
        } else if (strcmp(args[0], "shrhi") == 0){
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000001");
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "au") == 0){
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000010");
            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "cnt1h") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000011");

//cnt1h doesn't have 3 registers - only 2. Therefore, replace rs2 with all 0s
            strcat(opcodeOut, "00000");
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "ahs") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000100");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "or") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000101");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "bcw") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000110");

            //bcw doesn't have 3 registers - only 2. Therefore, replace rs2 with all 0s
            strcat(opcodeOut, "00000");
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "maxws") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00000111");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "minws") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001000");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "mlhu") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001001");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "mlhss") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001010");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "and") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001011");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "invb") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001100");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "rotw") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001101");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "sfwu") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001110");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else if (strcmp(args[0], "sfhs") == 0){
            //Do Something
            strcat(opcodeOut, "11");
            strcat(opcodeOut, "00001111");

            strcat(opcodeOut, char2Bin(args[3], 5, 10));
            strcat(opcodeOut, char2Bin(args[2], 5, 10));
            strcat(opcodeOut, char2Bin(args[1], 5, 10));
        } else {
            printf("\nInstruction not found: %s", args[0]);
        }

        printf("Opcode: %s", opcodeOut);
        fprintf(outputFile, opcodeOut);
        fprintf(outputFile, "\n");
        lineIndex++;
    }

    //Once we're done, fill the rest of the machine code with nop instructions
    while (lineIndex < 64) {
        fprintf(outputFile, "1100000000000000000000000\n");
        lineIndex++;
    }
    fclose(inputFile);
    fclose(outputFile);
    return 0;
}