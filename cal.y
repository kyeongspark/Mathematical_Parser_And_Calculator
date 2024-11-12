%{
    #include<stdio.h>
    #include<math.h>
    #include<stdlib.h>
%}
%union
{ double p; }
%token<p> number term

%type<p> E T S F N
%%

ss: E { printf("========Answer is %g\n", $1);}

E :     T               { $$ = $1; }
        |E '+' T        { $$ = $1 + $3; }
        |E '-' T        { $$ = $1 - $3; }
        |E '+' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after '+'\n");
                          $$ = $1 + 1;
                        }
        |E '-' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after '-'\n");
                          $$ = $1 - 1;
                        }

T :     S               { $$ = $1; }
        |T '*' S        { $$ = $1 * $3; }
        |T '/' S        { if ($3 == 0) {
                                printf("Semantic WARNING: DIVIDED BY ZERO\n");
                          } 
                          $$ = $1 / $3; 
                        }
        |T S            { $$ = $1 * $2;
                          printf("ERROR!! MISSING OPERATOR BETWEEN %lf AND %lf\n", $1, $2);
                          printf("Recovered by putting '*' between %lf and %lf\n", $1, $2);
                        }
        |T '*' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after '*'\n");
                          $$ = $1;
                        }
        |T '/' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after '/'\n");
                          $$ = $1;
                        }

S :     F               { $$ = $1; }
        |S '^' F        { $$ = pow($1, $3); }
        |S 'v' F        { if ($3 == 0) {
                              printf("Semantic WARNING: LOG OF ZERO\n");
                          }
                          if ($1 <= 0 || $1 == 1) {
                              printf("Semantic ERROR!! INVALID LOG BASE\n");
                              printf("Recovered by replaing %1f with 1\n", $1);
                              $$ = 1;
                          } else {
                              $$ = log($3) / log($1);
                          }
                        }
        |S 'm' F        { if ($3 == 0) {
                              printf("Semantic ERROR!! INVALID MOD\n");
                              printf("Recovered by deleting mod\n");
                              $$ = $1;
                          }
                          $$ = fmod($1, $3);
                          if ($$ < 0) $$ += $3; 
                        }
        |S 'r' F        { if ($1 == 0) {
                              printf("Semantic ERROR!! INVALID ROOT\n");
                              printf("Recovered by replaing %lf with 1\n", $1);
                              $$ = 1;
                          } else {
                                $$ = pow($3, 1/$1); 
                          }
                        }
        |S '^' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1  after '^'\n");
                          $$ = $1;
                        }
        |S 'v' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'v'\n");
                          if ($1 <= 0 || $1 == 1) {
                              printf("Semantic ERROR!! INVALID LOG BASE\n");
                              printf("Recovered by replaing %lf with 1\n", $1);
                              $$ = 1;
                          } else {
                              $$ = log(1) / log($1);
                          }
                        }
        |S 'm' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'm'\n");
                          $$ = fmod($1, 1);
                        }
        |S 'r' error    { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'r'\n");
                          if ($1 == 0) {
                              printf("Semantic ERROR!! INVALID ROOT\n");
                              printf("Recovered by replaing %lf with 1\n", $1);
                              $$ = 1;
                          } else {
                                $$ = pow(1, 1/$1); 
                          }
                        }

F :     N               { $$ = $1; }
        |'n' F          { $$ = -$2; }
        |'a' F          { $$ = fabs($2); }
        |'t' F          { $$ = tan($2); }
        |'c' F          { $$ = cos($2); }
        |'s' F          { $$ = sin($2); }
        |'n' error      { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'n'\n");
                          $$ = -1; 
                        }
        |'a' error      { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'a'\n");
                          $$ = 1;
                        }
        |'t' error      { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 't'\n");
                          $$ = tan(1);
                        }
        |'c' error      { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 'c'\n");
                          $$ = cos(1);
                        }
        |'s' error      { yyerrok;
                          printf("ERROR!! MISSING NUMBER\n");
                          printf("Recovered by putting 1 after 's'\n");
                          $$ = sin(1);
                        }

N :     number;
        |term           { exit(0); }
        |N '!'          { if ($1 < 0) {
                            printf("Semantic ERROR!! NEGATIVE FACTORIAL\n");
                            printf("Recovered by replacing %lf with |%lf|\n", $1, $1);
                            $$ = tgamma(-$1+1);
                          } else {
                                $$ = tgamma($1+1);
                          }
                        }
        |'(' E ')'      { $$ = $2; }
        |'(' E error    { yyerrok;
                          $$ = $2; 
                        }
        |'(' error      { printf("ERROR!! USELESS PARENTHESIS\n");
                          printf("Recovered by replacing '()' with 1\n");
                          $$ = 1;
                        }
%%

int main() {
    printf("This is TEAM 9 Calculator by 20195061 KyeongSeop Park, 20195073 Junho Park.\n");
    printf("Enter your expression and press 'Enter'.\n");
    printf("Available number: integer, real number, e, PI\n");
    printf("Available operator: +, -, *, /, ^, v, m, r, n, a, t, c, s, !, (, )\n");
    printf("Enter \"quit\" to quit the calculator\n");
    do
    {
        printf("\n========Enter Expression : ");
            yyparse();
    } while(1);
}

yyerror(char *s)
{

}
