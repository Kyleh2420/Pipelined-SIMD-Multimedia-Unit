#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//This function will take a decimal character string and return a 5 bit binary value
//Ex: Input 7 --> 00111
//Ex: Input 31 --> 11111
char* dec2Bin(char* charInput) {

}

//This function will take a hex character string and return a 16 bit binary value
//Ex: Input FFFF --> 1111111111111111
//Ex: Input 0000 --> 0000000000000000
char* hex2Bin(char* charInput) {

}

int main() {
    //Open a inputFile called "input.txt" in read only mode
    FILE* inputFile = fopen("input.txt", "r"); 

    //Open an outputFile called "output.txt" in write only mode
    FILE* outputFile = fopen("output.txt", "w"); 
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

        printf("\n%s", line);

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
/*
        //Print all arguements
        for (int i = 0; i < 5; i++) {
            printf("\n%d: %s", i, args[i]);
        }
*/
        //There's probably a better way to do this. I can think of one: A hashmap and a switch statement.
        //However, since this is a simple instructionset with minimal instructions, I have elected to use a if-else ladder
        //If this was a more complicated assembler, the smarter way would be a hashmap
        if(strcmp(args[0], "li") == 0) {
            printf("\nFound LI");
            
            
        } else if (strcmp(args[0], "simal") == 0){
            //Do Something
        } else if (strcmp(args[0], "simah") == 0){
            //Do Something
        } else if (strcmp(args[0], "simsl") == 0){
            //Do Something
        } else if (strcmp(args[0], "simsh") == 0){
            //Do Something
        } else if (strcmp(args[0], "slmal") == 0){
            //Do Something
        } else if (strcmp(args[0], "slmah") == 0){
            //Do Something
        } else if (strcmp(args[0], "slmsl") == 0){
            //Do Something
        } else if (strcmp(args[0], "slmsh") == 0){
            //Do Something
        } else if (strcmp(args[0], "nop") == 0){
            //Do Something
        } else if (strcmp(args[0], "shrhi") == 0){
            //Do Something
        } else if (strcmp(args[0], "au") == 0){
            //Do Something
        } else if (strcmp(args[0], "cnt1h") == 0){
            //Do Something
        } else if (strcmp(args[0], "ahs") == 0){
            //Do Something
        } else if (strcmp(args[0], "or") == 0){
            //Do Something
        } else if (strcmp(args[0], "cbcw") == 0){
            //Do Something
        } else if (strcmp(args[0], "maxws") == 0){
            //Do Something
        } else if (strcmp(args[0], "minws") == 0){
            //Do Something
        } else if (strcmp(args[0], "mlhu") == 0){
            //Do Something
        } else if (strcmp(args[0], "mlhss") == 0){
            //Do Something
        } else if (strcmp(args[0], "and") == 0){
            printf("\nFound and");
            //Do Something
        } else if (strcmp(args[0], "invb") == 0){
            //Do Something
        } else if (strcmp(args[0], "rotw") == 0){
            //Do Something
        } else if (strcmp(args[0], "sfwu") == 0){
            //Do Something
        } else if (strcmp(args[0], "sfhs") == 0){
            //Do Something
        } else {
            printf("\nInstruction not found: %s", args[0]);
        }

        fprintf(outputFile, opcodeOut);
        lineIndex++;
    }
    fclose(inputFile);
    fclose(outputFile);
    return 0;
}