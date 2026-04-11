%{
#include<bits/stdc++.h>    
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "2005081_symbolTable.cpp"
#include "y.tab.h"

using namespace std;

ofstream tree, logfile,errorfile,codefile;
extern int line_no;


int yyparse(void);
int yylex(void);
extern FILE *yyin;


SymbolTable *table;
vector<Identifiers> current_parameters;
vector<SymbolInfo *> real_current_parameters;
vector <SymbolInfo *> globals;
string current_function_name;
void yyerror(char *s)
{
	//write your code
}

void id_insert(vector<Identifiers> vec, string t)
{
    for(int i=0;i<vec.size();i++)
    {
        //cout<<vec[i].is_Array<<endl;
        SymbolInfo * info = new SymbolInfo(vec[i].name, t, t);
        info->is_Array = vec[i].is_Array;
        if(vec[i].is_Array)
        {
            info->type = "ARRAY";
        }
        SymbolInfo * ans = table->Lookup1(info->name);
        if(ans != nullptr)
        {
           // cout<<"CHECK1 "<<ans->data_type<<endl;
            if(ans->data_type != info->data_type && ans->data_type != info->type)
            {
                //cout<<"CHECK "<<info->data_type<<endl;
                errorfile<<"Line# "<<line_no<<": "<<"Conflicting types for "<<"'"<<info->name<<"'"<<endl;
            }
            else{
                errorfile<<"Line# "<<line_no<<": "<<"Redefinition of variable "<<"'"<<info->name<<"'"<<endl;
            }
        }
        else
        {
           table->Insert1(info);
        }
         
    }
}

void insert_func_def(string name, string type, vector<Identifiers> vec)
{
    SymbolInfo * ans = table->Lookup(name);
    if(ans == nullptr)
    {
        SymbolInfo * tmp = new SymbolInfo(name, "FUNCTION", type);
        tmp->func_ret = type;
        tmp->Identifiers_list = vec;
        tmp->data_type = type;
        table->Insert1(tmp);
        /*for(int i=0;i<vec.size();i++)
        {
            SymbolInfo * in = new (vec[i].)
        }*/
    }
    else
    {
        if(ans->func_ret != type)
        {
           errorfile<<"Line# "<<line_no<<": "<<"Conflicting types for "<<"'"<<ans->name<<"'"<<endl; 
        }
        else if(ans->Identifiers_list.size() != vec.size())
        {
            errorfile<<"Line# "<<line_no<<": "<<"Conflicting types for "<<"'"<<ans->name<<"'"<<endl;
        }
        else
        {
            for(int i=0;i<vec.size();i++)
                    {
                        if(ans->Identifiers_list[i].type != vec[i].type)
                        {
                            errorfile<<"Line# "<<line_no<<": "<<"Conflicting types for "<<"'"<<name<<"'"<<endl;
                        }
                    }   
        }
    }
}

void insert_func_dec(string name, string type, vector<Identifiers> vec){
    SymbolInfo * ans = table->Lookup(name);
    if(ans == nullptr)
    {
        SymbolInfo * tmp = new SymbolInfo(name, "FUNCTION", type);
        tmp->func_ret = type;
        tmp->Identifiers_list = vec;
        tmp->data_type = type;
        table->Insert1(tmp);
    }
    else
    {
        errorfile<<"Line# "<<line_no<<": "<<"'"<<name<<"'"<<" redeclared as different kind of symbol "<<endl;
    }
}




%}

%nonassoc THEN


%union{
    SymbolInfo * ysymbol;
}
 
%token <ysymbol> IF ELSE FOR WHILE DO BREAK RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON INT CHAR FLOAT DOUBLE VOID CONST_INT CONST_FLOAT ID MULOP LOOP
%type <ysymbol> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression expression_statement logic_expression rel_expression simple_expression term unary_expression factor variable argument_list arguments lcurl

%%

start : program
	{
		//write your code in this block in all the similar blocks below
	    cout<<"start : program"<<endl;
        $$ = new SymbolInfo("", "start");
        $$->rule = "start : program";
        $$->AddChild($1);
        $$->Print_ParseTree(tree);
        $$->global_list = globals;
        $$->Code_Generate(0, codefile);
    }
	;

program : program unit {
            cout<<"program : program unit"<<endl;
            $$ = new SymbolInfo("", "program");
            $$->rule = "program : program unit";
            $$->AddChild($1);
            $$->AddChild($2);        
    }
	| unit {
            cout<<"program : unit"<<endl;
            $$ = new SymbolInfo("", "program");
            $$->rule = "program : unit";
            $$->AddChild($1);
    }
	;
	
unit : var_declaration {
            cout<<"unit : var_declaration"<<endl;
            $$ = new SymbolInfo("", "unit");
            $$->rule = "unit : var_declaration";
            $$->AddChild($1);
            }
     | func_declaration {
            cout<<"unit : func_declaration"<<endl;
            $$ = new SymbolInfo("", "unit");
            $$->rule = "unit : func_declaration";
            $$->AddChild($1);
     }
     | func_definition {
            cout<<"unit : func_definition"<<endl;
            $$ = new SymbolInfo("", "unit");
            $$->rule = "unit : func_definition";
            $$->AddChild($1);
     }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
            cout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "func_declaration");
            $$->rule = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
            current_parameters.clear();
            insert_func_dec($2->name, $1->data_type, $4->Identifiers_list);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            $$->AddChild($6);
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
            cout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "func_declaration");
            $$->rule = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
            current_parameters.clear();
            insert_func_dec($2->name, $1->data_type, {});
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
        }
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN{ insert_func_def($2->name, $1->data_type, $4->Identifiers_list);current_function_name = $2->name;}
 compound_statement {
            cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
            $$ = new SymbolInfo("", "func_definition",$1->name);
            $$->rule = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            $$->AddChild($7);
}
		| type_specifier ID LPAREN RPAREN{insert_func_def($2->name, $1->data_type, {});current_function_name = $2->name;} compound_statement {
            cout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
            $$ = new SymbolInfo("", "func_definition",$1->name);
            $$->rule = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($6);
            current_function_name = $2->name;
        }
 		;				

parameter_list  : parameter_list COMMA type_specifier ID {
            cout<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl;
            $$ = new SymbolInfo("", "parameter_list");
            $$->rule = "parameter_list  : parameter_list COMMA type_specifier ID";
            $$->Identifiers_list = $1->Identifiers_list;
            Identifiers ob($4->name,$3->data_type);
            $$->Identifiers_list.push_back(ob);
            current_parameters = $$->Identifiers_list;
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->params = $1->params;
            $$->params.push_back($4);
            real_current_parameters = $$->params;
}
		| parameter_list COMMA type_specifier {
            cout<<"parameter_list  : parameter_list COMMA type_specifier"<<endl;
            $$ = new SymbolInfo("", "parameter_list");
            $$->rule = "parameter_list  : parameter_list COMMA type_specifier";
            $$->Identifiers_list = $1->Identifiers_list;
            Identifiers ob("",$3->data_type);
            $$->Identifiers_list.push_back(ob);
            current_parameters = $$->Identifiers_list;
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
        }
 		| type_specifier ID {
            cout<<"parameter_list  : type_specifier ID"<<endl;
            $$ = new SymbolInfo("", "parameter_list");
            $$->rule = "parameter_list  : type_specifier ID";
            Identifiers ob($2->name,$1->data_type);
            $$->Identifiers_list.push_back(ob);
            current_parameters = $$->Identifiers_list;
            $$->AddChild($1);
            $$->AddChild($2);
            $$->params.push_back($2);
            real_current_parameters = $$->params;
        }
		| type_specifier {
            cout<<"parameter_list  : type_specifier"<<endl;
            $$ = new SymbolInfo("", "parameter_list");
            $$->rule = "parameter_list  : type_specifier";
            Identifiers ob("",$1->data_type);
            $$->Identifiers_list.push_back(ob);
            current_parameters = $$->Identifiers_list;
            $$->AddChild($1);
        }
 		;

 		
compound_statement : lcurl statements RCURL {
            //table->Enter_scope();
            cout<<"compound_statement : LCURL statements RCURL"<<endl;
            $$ = new SymbolInfo("", "compound_statement");
            $$->rule = "compound_statement : LCURL statements RCURL";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->stack_offset = table->get_current_total_stack_offset();
            table->Print_All();
            table->Exit_Scope();
}
 		    | lcurl RCURL {
            cout<<"compound_statement : LCURL RCURL"<<endl;
            //table->Enter_scope();
            $$ = new SymbolInfo("", "compound_statement");
            $$->rule = "compound_statement : LCURL RCURL";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->stack_offset = table->get_current_total_stack_offset();
            table->Print_All();
            table->Exit_Scope();
            }
            | LOOP lcurl RCURL{
              cout<<"compound_statement : LOOP lcurl RCURL"<<endl;
              $$ = new SymbolInfo("", "compound_statement");
              $$->rule = "compound_statement : LOOP lcurl RCURL";
              $$->AddChild($1);
              $$->AddChild($2);
              $$->AddChild($3);
            }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
            cout<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "var_declaration");
            $$->rule = "var_declaration : type_specifier declaration_list SEMICOLON";
            //id_insert($2->Identifiers_list, $1->data_type);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            for(int i=0;i<$2->declaration_list.size();i++)
            {
                //cout<<$2->Identifiers_list[i].name<<"  ";
                if(table->get_current_id() == "1")
                {
                    $$->is_Global = true;
                    $2->declaration_list[i]->is_Global = true;
                    globals.push_back($2->declaration_list[i]);   
                }
                else
                {
                    int a = table->get_current_total_stack_offset();
                    if($2->declaration_list[i]->is_Array == true)
                    {
                        a += 2*$2->declaration_list[i]->arraysize;
                    }
                    else
                    {
                       a += 2;
                    }
                    
                    table->set_current_total_stack_offset(a);
                    $2->declaration_list[i]->stack_offset = table->get_current_total_stack_offset();
                    cout<<"STACK "<<$2->declaration_list[i]->stack_offset<<endl<<endl;
                } 
               bool flag1 =  table->Insert1($2->declaration_list[i]);
               //cout<<flag1<<endl<<endl;
                //cout<<"BEFORE LOOKUP "<<$2->declaration_list[i]->name<<$2->declaration_list[i]->stack_offset<<endl<<endl;
                //SymbolInfo * tm = table->Lookup($2->declaration_list[i]->name);
                //cout<<"JUST AFTER INSERTING "<<tm->name<<"  "<<tm->stack_offset<<endl<<endl;
            }
            $$->declaration_list = $2->declaration_list;
}
 		 ;
 		 
type_specifier	: INT {
            cout<<"type_specifier	: INT"<<endl;
            $$ = new SymbolInfo("", "type_specifier","INT");
            $$->rule = "type_specifier	: INT";
            $$->AddChild($1);
}
 		| FLOAT {
            cout<<"type_specifier	: FLOAT"<<endl;
            $$ = new SymbolInfo("", "type_specifier", "FLOAT");
            $$->rule = "type_specifier	: FLOAT";
            $$->AddChild($1);
        }
 		| VOID {
            cout<<"type_specifier	: VOID"<<endl;
            $$ = new SymbolInfo("", "type_specifier", "VOID");
            $$->rule = "type_specifier	: VOID";
            $$->AddChild($1);
        }
 		;
 		
declaration_list : declaration_list COMMA ID {
            cout<<"declaration_list : declaration_list COMMA ID"<<endl;
            $$ = new SymbolInfo("", "declaration_list");
            $$->rule = "declaration_list : declaration_list COMMA ID";
            $$->Identifiers_list = $1->Identifiers_list;
            Identifiers ob($3->name, $3->type);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->declaration_list = $1->declaration_list;
            $$->declaration_list.push_back($3);
}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
            cout<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE"<<endl;
            $$ = new SymbolInfo("", "declaration_list");
            $$->rule = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
            $$->Identifiers_list = $1->Identifiers_list;
            Identifiers ob($3->name, $3->type,true);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            $$->AddChild($6);
            $$->declaration_list = $1->declaration_list;
            $3->is_Array = true;
            string str = $5->name;
            int x = stoi(str);
            $3->arraysize = x;
            $$->declaration_list.push_back($3);
          }
 		  | ID {
            cout<<"declaration_list : ID"<<endl;
            $$ = new SymbolInfo("", "declaration_list");
            $$->rule = "declaration_list : ID";
            Identifiers ob($1->name, $1->type);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
            $$->declaration_list.push_back($1);
          }
 		  | ID LSQUARE CONST_INT RSQUARE {
            cout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE"<<endl;
            $$ = new SymbolInfo("", "declaration_list");
            $$->rule = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
            Identifiers ob($1->name, $1->type,true);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $1->is_Array = true;
            string str = $3->name;
            int x = stoi(str);
            $1->arraysize = x;
            $$->declaration_list.push_back($1);
          }
 		  ;
 		  
statements : statement {
            cout<<"statements : statement"<<endl;
            $$ = new SymbolInfo($1->name, "statements");
            $$->rule = "statements : statement";
            $$->AddChild($1);
}
	   | statements statement {
            cout<<"statements : statements statement"<<endl;
            $$ = new SymbolInfo($1->name, "statements");
            $$->rule = "statements : statements statement";
            $$->AddChild($1);
            $$->AddChild($2);
       }
	   ;
	   
statement : var_declaration {
            cout<<"statement : var_declaration"<<endl;
            $$ = new SymbolInfo("$1->name", "statement", $1->data_type);
            $$->rule = "statement : var_declaration";
            $$->AddChild($1);
}
	  | expression_statement {
            cout<<"statement : expression_statement"<<endl;
            $$ = new SymbolInfo("$1->name", "statement", $1->data_type);
            $$->rule = "statement : expression_statement";
            $$->AddChild($1);
      }
	  | compound_statement {
            cout<<"statement : compound_statement"<<endl;
            $$ = new SymbolInfo("$1->name", "statement", $1->data_type);
            $$->rule = "statement : compound_statement";
            $$->AddChild($1);
      }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
            cout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            $$->AddChild($6);
            $$->AddChild($7);
      }
	  | IF LPAREN expression RPAREN statement {
            cout<<"statement : IF LPAREN expression RPAREN statement"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : IF LPAREN expression RPAREN statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
      }
	  | IF LPAREN expression RPAREN statement ELSE statement {
            cout<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : IF LPAREN expression RPAREN statement ELSE statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            $$->AddChild($6);
            $$->AddChild($7);
      }
	  | WHILE LPAREN expression RPAREN statement {
            cout<<"statement : WHILE LPAREN expression RPAREN statement"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : WHILE LPAREN expression RPAREN statement";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
      }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
            cout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->AddChild($5);
            SymbolInfo * t = table->Lookup($3->name);
            $$->stack_offset = t->stack_offset;
            $$->is_Global = t->is_Global;
      }
	  | RETURN expression SEMICOLON {
            cout<<"statement : RETURN expression SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "statement");
            $$->rule = "statement : RETURN expression SEMICOLON";
            $1->name = current_function_name;
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            
      }
	  ;
	  
expression_statement : SEMICOLON	{
            cout<<"expression_statement : SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "expression_statement");
            $$->rule = "expression_statement : SEMICOLON";
            $$->AddChild($1);
}		
			| expression SEMICOLON {
            cout<<"expression_statement : expression SEMICOLON"<<endl;
            $$ = new SymbolInfo("", "expression_statement");
            $$->rule = "expression_statement : expression SEMICOLON";
            $$->AddChild($1);
            $$->AddChild($2);
            } 
			;
	  
variable : ID {
            cout<<"variable : ID"<<endl;
            $$ = new SymbolInfo($1->name, "VARIABLE", $1->data_type);
            SymbolInfo * ans = table->Lookup($1->name);
            if(ans == nullptr)
            {
                errorfile<<"Line# "<<line_no<<": "<<"Undeclared variable "<<"'"<<$1->name<<"'"<<endl;
            }
            $$->rule = "variable : ID";
            $$->AddChild($1);
            SymbolInfo * tmp = table->Lookup($1->name);
            $$->stack_offset = tmp->stack_offset;
            cout<<"IN ASSIGNING "<<tmp->name<<"  "<<tmp->stack_offset<<endl<<endl;
            $$->is_Global = tmp->is_Global;
            $$->is_Array = tmp->is_Array;
}		
	 | ID LSQUARE expression RSQUARE {
            cout<<"variable : ID LSQUARE expression RSQUARE"<<endl;
            $$ = new SymbolInfo($1->name, "VARIABLE", $1->data_type);
            SymbolInfo * ans = table->Lookup($1->name);
            if(ans == nullptr)
            {
                errorfile<<"Line# "<<line_no<<": "<<"Undeclared variable "<<"'"<<$1->name<<"'"<<endl;
            }
            if(ans != nullptr && ans->is_Array == false)
            {
                errorfile<<"Line# "<<line_no<<": "<<"'"<<$1->name<<"'"<<" is not an array"<<endl;
            }
            if(ans != nullptr && ans->is_Array == true && $3->data_type != "INT")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Array subscript is not an integer"<<endl;
            }
            $$->rule = "variable : ID LSQUARE expression RSQUARE";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
            $$->is_Array = ans->is_Array;
            $$->is_Global = ans->is_Global;
            $$->stack_offset = ans->stack_offset;
     } 
	 ;
	 
 expression : logic_expression	{
            cout<<"expression : logic_expression"<<endl;
            $$ = new SymbolInfo($1->name, "expression", $1->data_type);
            $$->rule = "expression : logic_expression";
            $$->AddChild($1);
 }
	   | variable ASSIGNOP logic_expression {
            cout<<"expression : variable ASSIGNOP logic_expression"<<endl;
            $$ = new SymbolInfo("", "expression");
            $$->rule = "expression : variable ASSIGNOP logic_expression";
            //errorfile<<$1->data_type<<$3->data_type<<endl;
            if($1->data_type == "VOID" || $3->data_type == "VOID")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Void cannot be used in expression"<<endl;
            }
            if($1->data_type == "INT" && $3->data_type == "FLOAT")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
                $1->data_type = "INT";
            }
            
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
       } 	
	   ;
			
logic_expression : rel_expression {
            cout<<"logic_expression : rel_expression"<<endl;
            $$ = new SymbolInfo($1->name, "logic_expression",$1->data_type);
            $$->rule = "logic_expression : rel_expression";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
} 	
		 | rel_expression LOGICOP rel_expression {
            cout<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl;      
            $$ = new SymbolInfo("", "logic_expression");
            $$->rule = "logic_expression : rel_expression LOGICOP rel_expression";
            $$->data_type = "INT";
            if($1->data_type == "VOID" || $3->data_type == "VOID")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Void cannot be used in expression"<<endl;
            }
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
         } 	
		 ;
			
rel_expression	: simple_expression {
            cout<<"rel_expression	: simple_expression"<<endl;
            $$ = new SymbolInfo($1->name, "rel_expression",$1->data_type);
            $$->rule = "rel_expression	: simple_expression";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
}
		| simple_expression RELOP simple_expression {
            cout<<"rel_expression	: simple_expression RELOP simple_expression"<<endl;    
            $$ = new SymbolInfo("", "rel_expression");
            $$->rule = "rel_expression	: simple_expression RELOP simple_expression";
            if($1->data_type == "VOID" || $3->data_type == "VOID")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Void cannot be used in expression"<<endl;
            }
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
        }	
		;
				
simple_expression : term {
            cout<<"simple_expression : term"<<endl;
            $$ = new SymbolInfo($1->name, "simple_expression",$1->data_type);
            $$->rule = "simple_expression : term";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
}
		  | simple_expression ADDOP term {
            cout<<"simple_expression : simple_expression ADDOP term"<<endl;
            $$ = new SymbolInfo("", "simple_expression");
            $$->rule = "simple_expression : simple_expression ADDOP term";
            if($1->data_type == "VOID" || $3->data_type == "VOID")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Void cannot be used in expression"<<endl;
            }
            $$->data_type = $3->data_type;
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
          }
		  ;
					
term :	unary_expression {
            cout<<"term :	unary_expression"<<endl;
            $$ = new SymbolInfo($1->name, "term",$1->data_type);
            $$->rule = "term :	unary_expression";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
}
     |  term MULOP unary_expression {
            cout<<"term :	term MULOP unary_expression"<<endl;
            $$ = new SymbolInfo("", "MULOP");
            $$->rule = "term :	term MULOP unary_expression";
            if($1->data_type == "VOID" || $3->data_type == "VOID")
            {
                errorfile<<"Line# "<<line_no<<": "<<"Void cannot be used in expression"<<endl;
            }
            if($2->name == "%")
            {
                if($1->data_type == "FLOAT" || $3->data_type == "FLOAT")
                {
                    errorfile<<"Line# "<<line_no<<": "<<"Operands of modulus must be integers"<<endl;
                }
                else if($3->name == "0")
                {
                    errorfile<<"Line# "<<line_no<<": "<<"Warning: division by zero"<<endl;
                }
                else
                {
                   $$->data_type = "INT"; 
                }
                if($1->data_type != $2->data_type )
                {
                    $$->data_type = "FLOAT";
                }
                else
                {
                    $$->data_type = "INT";
                }
            }
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
     }
     ;

unary_expression : ADDOP unary_expression {
            cout<<"unary_expression : ADDOP unary_expression"<<endl;
            $$ = new SymbolInfo("", "unary_expression");
            $$->rule = "unary_expression : ADDOP unary_expression";
            $$->data_type = $2->data_type;
            $$->AddChild($1);
            $$->AddChild($2);
}
		 | NOT unary_expression {
            cout<<"unary_expression : NOT unary_expression"<<endl;
            $$ = new SymbolInfo("", "unary_expression");
            $$->rule = "unary_expression : NOT unary_expression";
            $$->data_type = $2->data_type;
            $$->AddChild($1);
            $$->AddChild($2);
         } 
		 | factor {
            cout<<"unary_expression : factor"<<endl;
            $$ = new SymbolInfo($1->name, "unary_expression",$1->data_type);
            $$->rule = "unary_expression : factor";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
         }
		 ;
	
factor	: variable {
            cout<<"factor	: variable"<<endl;
            $$ = new SymbolInfo($1->name, "factor",$1->data_type);
            $$->rule = "factor	: variable";
            $$->AddChild($1);
            $$->is_Array = $1->is_Array;
}
	| ID LPAREN argument_list RPAREN {
            cout<<"factor	: ID LPAREN argument_list RPAREN"<<endl;
            $$ = new SymbolInfo("", "factor");
            $$->rule = "factor	: ID LPAREN argument_list RPAREN";
            SymbolInfo * ans = table->Lookup($1->name);
            if(ans == nullptr)
            {
                errorfile<<"Line# "<<line_no<<": "<<"Undeclared function "<<"'"<<$1->name<<"'"<<endl;
            }
            else
            {
                if(ans->Identifiers_list.size() > $3->Identifiers_list.size())
                {
                    errorfile<<"Line# "<<line_no<<": "<<"Too many arguments to function "<<"'"<<$1->name<<"'"<<endl;
                }
                else if(ans->Identifiers_list.size() < $3->Identifiers_list.size())
                {
                    errorfile<<"Line# "<<line_no<<": "<<"Too few arguments to function "<<"'"<<$1->name<<"'"<<endl;
                }
                else
                {
                    for(int i=0;i<$3->Identifiers_list.size();i++)
                    {
                        if(ans->Identifiers_list[i].type != $3->Identifiers_list[i].type)
                        {
                            errorfile<<"Line# "<<line_no<<": "<<"Type mismatch for argument "<<i+1<<" of "<<"'"<<$1->name<<"'"<<endl;
                        }
                    }
                }
            }
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
            $$->AddChild($4);
    }
 	| LPAREN expression RPAREN {
            cout<<"factor	: LPAREN expression RPAREN"<<endl;
            $$ = new SymbolInfo($2->name, "factor",$2->data_type);
            $$->rule = "factor	: LPAREN expression RPAREN";
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
    }
	| CONST_INT {
            cout<<"factor	: CONST_INT"<<endl;
            $$ = new SymbolInfo($1->name, "factor","INT");
            $$->rule = "factor	: CONST_INT";
            $$->AddChild($1);
    }
	| CONST_FLOAT {
            cout<<"factor	: CONST_FLOAT"<<endl;
            $$ = new SymbolInfo($1->name, "factor","FLOAT");
            $$->rule = "factor	: CONST_FLOAT";
            $$->AddChild($1);
    }
	| variable INCOP {
            cout<<"factor	: variable INCOP"<<endl;
            $$ = new SymbolInfo("", "factor");
            $$->rule = "factor	: variable INCOP";
            $$->data_type = $1->data_type;
            $$->AddChild($1);
            $$->AddChild($2);
    }
	| variable DECOP {
            cout<<"factor	: variable DECOP"<<endl;
            $$ = new SymbolInfo("", "factor");
            $$->rule = "factor	: variable DECOP";
            $$->data_type = $1->data_type;
            $$->AddChild($1);
            $$->AddChild($2);
    }
	;
	
argument_list : arguments {
            cout<<"argument_list : arguments"<<endl;
            $$ = new SymbolInfo("", "argument_list");
            $$->rule = "argument_list : arguments";
            $$->Identifiers_list = $1->Identifiers_list;
            $$->AddChild($1);
            int x = $$->Identifiers_list.size();
            $$->stack_offset = x*2;
}
			  | {
            $$ = new SymbolInfo("", "argument_list");
            $$->rule = "argument_list : ";
            $$->starting = line_no;
            $$->ending = line_no;
              }
			  ;
	
arguments : arguments COMMA logic_expression {
            cout<<"arguments : arguments COMMA logic_expression"<<endl;
            $$ = new SymbolInfo("", "arguments");
            $$->rule = "arguments : arguments COMMA logic_expression";
            $$->Identifiers_list = $1->Identifiers_list;
            Identifiers ob($3->name, $3->data_type);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
            $$->AddChild($2);
            $$->AddChild($3);
}
	      | logic_expression {
            cout<<"arguments : logic_expression"<<endl;
            $$ = new SymbolInfo("", "arguments");
            $$->rule = "arguments : logic_expression";
            Identifiers ob($1->name, $1->data_type);
            $$->Identifiers_list.push_back(ob);
            $$->AddChild($1);
          }
	      ;
 lcurl : LCURL {
    table->Enter_scope();
    /*for(int i=0;i<current_parameters.size();i++)
    {
        //cout<<current_parameters[i].name<<"  ";
        SymbolInfo * tmp = table->Lookup1(current_parameters[i].name);
        if(tmp != nullptr)
        {
            errorfile<<"Line# "<<line_no<<": "<<"Redefinition of parameter "<<"'"<<current_parameters[i].name<<"'"<<endl;
        }
        else
        {
            SymbolInfo * ob = new SymbolInfo(current_parameters[i].name, current_parameters[i].type, current_parameters[i].type);
            table->Insert1(ob);
        }
    }*/
    for(int i=real_current_parameters.size()-1; i >= 0; i--)
    {
        real_current_parameters[i]->stack_offset =(real_current_parameters.size()-1 - i)*-2 - 4;
        table->Insert1(real_current_parameters[i]);
    }
    current_parameters.clear();
    real_current_parameters.clear();
 }

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	table = new SymbolTable(11);
   freopen("2005081_log.txt", "w", stdout);
    tree.open("parse_tree.txt");
    errorfile.open("error.txt");
    codefile.open("assembly_code.txt");
	yyin= fin;
    yyparse();
	//yylex();
	fclose(yyin);
    tree.close();
	return 0;
}
/*int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");
	

	yyin=fp;
	yyparse();
	

	fclose(fp2);
	fclose(fp3);
	
	return 0;
}*/

