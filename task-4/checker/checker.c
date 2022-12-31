#include <stdio.h>
#include <stdlib.h>
#define MAX_LINE 100001

int expression(char *p, int *i);
int term(char *p, int *i);
int factor(char *p, int *i);

int main()
{
    char s[MAX_LINE];
    int i = 0;
    char *p;  
    scanf("%s", s);
    p = s;
    printf("%d\n", expression(p, &i));
    return 0;
}
