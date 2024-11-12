%{
    #include<math.h>
    #include"y.tab.h"
    int count = 0;
    int start = 0;
%}
%%
[1-9][0-9]*+|0 {
    yylval.p = atoi(yytext);
    start = 1;
    return number;
}
[1-9][0-9]*\.[0-9]*[1-9]|0\.[0-9]*[1-9] {
    yylval.p = atof(yytext);
    start = 1;
    return number;
}

e {
    yylval.p = exp(1);
    start = 1;
    return number;
}

PI {
    yylval.p = M_PI;
    start = 1;
    return number;
}

[\+\-\*\/\^vmr][\+\-\*\/\^vmr\!]+ {
    printf("ERROR!! TOO MUCH OPERATORS: '%s'\n", yytext);
    printf("Recovered by deleting operators '%s' except '%c'\n", yytext, yytext[0]);
    if (start == 0) {
        printf("ERROR!! MISSING NUMBER\n");
        printf("Recovered by deleting operator '%c'\n", yytext[0]);
    } else {
        start = 1;
        return yytext[0];
    }
}

[natcs][\+\-\*\/\^vmr\!]+ {
    printf("ERROR!! TOO MUCH OPERATORS: '%s'\n", yytext);
    printf("Recovered by deleting operators '%s' except '%c'\n", yytext, yytext[0]);
    start = 1;
    return yytext[0];
}

[\+\-\*\/\^vmr] {
    if (start == 0) {
        printf("ERROR!! MISSING NUMBER\n");
        printf("Recovered by deleting operator '%c'\n", yytext[0]);
    } else {
        return yytext[0];
    }
}

[natcs] {
    start = 1;
    return yytext[0];
}

[\!] {
    if (start == 0) {
        printf("ERROR!! MISSING NUMBER\n");
        printf("Recovered by deleting operator '%c'\n", yytext[0]);
    } else {
        return yytext[0];
    }
}

[\(][\)] {
    printf("ERROR!! USELESS PARENTHESES '()'\n");
    printf("Recovered by replacing '()' with 1\n");
    yylval.p = 1;
    start = 1;
    return number;
}

[\(] { 
    count ++;
    start = 0;
    return yytext[0];
}

[\)] {
    if (count <= 0) {
        printf("ERROR!! MISSING OPENING PARENTHESIS '('\n");
        printf("Recovered by deleting closing parenthesis ')'\n");
    } else {
        count --;
        return yytext[0];
    }
}

[\ \t] ;

[\n]  {
    if (count > 0) {
        printf("ERROR!! MISSING %d CLOSING PARENTHESIS ')'\n", count);
        printf("Recovered by putting %d closing parenthesis ')'\n", count);
        count = 0;
    }
    start = 0;
    return 0;
}

[q][u][i][t] {
    return term;
}

. {
    printf("ERROR!! UNEXPECTED CHARACTER : '%c'\n", yytext[0]);
    printf("Recovered by replacing '%c' with 1\n", yytext[0]);
    start = 1;
    yylval.p = 1;
    return number;
}

%%
