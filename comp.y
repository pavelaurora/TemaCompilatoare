%{
	#include<stdio.h>
	#include<string.h>


	int yylex();
	int yyerror(const char *msg);
	extern FILE* yyin;

	int EsteCorecta = 1;
	char msg[500];

//tabela de simboli
	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
         void add(char* n, int v = -1);
         int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
		 this->nume = new char[strlen(n)+1];
		 strcpy(this->nume,n);
		 this->valoare = v;
		 this->next = NULL;
	}

	TVAR::TVAR()
	{
		  TVAR::head = NULL;
		  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
		  TVAR* tmp = TVAR::head;
		  while(tmp != NULL)
		  {
		    if(strcmp(tmp->nume,n) == 0)
		      return 1;
	            tmp = tmp->next;
		  }
		  return 0;
	 }

     void TVAR::add(char* n, int v)
	 {
		   TVAR* elem = new TVAR(n, v);
		   if(head == NULL)
		   {
		     TVAR::head = TVAR::tail = elem;
		   }
		   else
		   {
		     TVAR::tail->next = elem;
		     TVAR::tail = elem;
		   }
	 }

      int TVAR::getValue(char* n)
	 {
		   TVAR* tmp = TVAR::head;
		   while(tmp != NULL)
		   {
		     if(strcmp(tmp->nume,n) == 0)
		      	return tmp->valoare;
		     tmp = tmp->next;
		   }
		   return -1;
	  }
	
	  void TVAR::setValue(char* n, int v)
	  {
		    TVAR* tmp = TVAR::head;
		    while(tmp != NULL)
		    {
		      if(strcmp(tmp->nume,n) == 0)
		      {
					tmp->valoare = v;
		      }
		      tmp = tmp->next;
		    }
	  }

	TVAR* ts = NULL;
%}

%union { char* sir; int val; }

%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER
%token TOK_DIV TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token TOK_LEFT TOK_RIGHT TOK_ATRIB 
%token TOK_PLUS TOK_MINUS TOK_MULTIPLY 

%token <val> TOK_INT
%token <sir> TOK_ID

%type <val> E T F
%type <sir> I


%start P

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIV

%locations


%%
P: 	TOK_PROGRAM P1 TOK_VAR D TOK_BEGIN S TOK_END '.'
	|
	error { EsteCorecta = 0; };
	
	
	
P1: TOK_ID;

D:   D1
     |
     D ';' D1
     |
     error { EsteCorecta = 0; }
    ;
	
D1: I ':' T1
	{
    char* token=strtok($1,",");
	while(token!=NULL)
	{
		if(ts != NULL)
		{
		  if(ts->exists(token)==1)
		  {
			sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, token);
		    yyerror(msg);
		    YYERROR;
		    
		  }
		  else
		  {
		    ts->add(token);
		  }
		}
		else
		{
		  ts = new TVAR();
		  ts->add(token);
		}
	token=strtok(NULL,",");
	}
      };
     

T1: TOK_INTEGER;

I:   TOK_ID 
     |
     I ',' TOK_ID 
	 {
		strcat($$,",");
		strcat($$,$3);
	 };
	 
S: 	S1
	| 
	 S ';' S1
	 ;
	 
	 
S1:  A
	 | 
	 R
	 |
	 W
	 | 
	 F1
	 |
	 error { EsteCorecta = 0; }
	 ;
	 	 
	
A: TOK_ID TOK_ATRIB E
 {
	if(ts != NULL)
	{
	  if(ts->exists($1)==1)
	  {
	    ts->setValue($1, $3);
	   
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
	
      };
	

E: 	 T { $$ = $1; }
	 |
	 E TOK_PLUS T { $$ = $1 + $3; }
	 |
	 E TOK_MINUS T { $$ = $1 - $3; };
	 
	 
T: 	 F { $$ = $1; }
	 |
	 T TOK_MULTIPLY F { $$ = $1 * $3; }
	 |
	 T TOK_DIV F
	{ 
	  if($3 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	  else { $$ = $1 / $3; } 
	};
	 

F:	 TOK_ID
	{
		if(ts != NULL)
		{
			  if(ts->exists($1) ==1)
			  {
			    $$ = ts->getValue($1);
			  }
			  else
			  {
			    sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
			    yyerror(msg);
			    YYERROR;
			  }
		}
	}
	 |
	 TOK_INT { $$ = $1; }
	 |
	 TOK_LEFT E TOK_RIGHT {$$ = $2;};

	 
	 
R: TOK_READ TOK_LEFT I TOK_RIGHT
{
	if(ts != NULL)
	{
	  if(ts->exists($3) == 1)
	  {
	    	//ts->setValue($3,)
	  		///trebuie citita o valoare

	  
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	  yyerror(msg);
	  YYERROR;
	}
	
};	
 
W: TOK_WRITE TOK_LEFT I TOK_RIGHT
{
	if(ts != NULL)
	{
	  if(ts->exists($3) == 1)
	  {
	    if(ts->getValue($3) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $3);
	      yyerror(msg);
	      YYERROR;
	    }
	    else
	    {
	      //printf("%d\n",ts->getValue($3));
	    }
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	  yyerror(msg);
	  YYERROR;
	}
};
	

F1: TOK_FOR I1 TOK_DO B;

I1: TOK_ID TOK_ATRIB E TOK_TO E
	{
		if(ts != NULL)
		{
		  if(ts->exists($1)==1)
		  {
		    ts->setValue($1, $3);
		   
		  }
		  else
		  {
		    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
		    yyerror(msg);
		    YYERROR;
		  }
		}
		else
		{
		  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
		  yyerror(msg);
		  YYERROR;
		}
	

	}
;

B:   S1
     |
     TOK_BEGIN S TOK_END;
	 
 
%%	 

int main(int argc, char* argv[])
{
	FILE *fis=fopen(argv[1],"r");
	yyin=fis;


	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("\nCORECTA\n");		
	}
	else
	{
		printf("\nGRESITA\n");		
	}

	
       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
	
	
		
