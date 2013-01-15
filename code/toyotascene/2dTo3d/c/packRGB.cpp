#include <iostream>
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char** argv) 
{
	int r = atoi((const char*)argv[1]);
	int g = atoi((const char*)argv[2]);
	int b = atoi((const char*)argv[3]);
    int rgb = ((int)r) << 16 | ((int)g) << 8 | ((int)b);
    printf("%d\n",rgb);
    return rgb;
}