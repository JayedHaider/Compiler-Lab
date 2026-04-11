%option noyywrap

%x STRING
%x SingleComment
%x MultiComment

%{
#include<bits/stdc++.h>
#include "2005081_symbolTable.cpp"
#include "y.tab.h"

using namespace std;

extern ofstream logfile;
extern YYSTYPE yylval;

int word_count=0;
int line_no = 1;
string str;
string tokstr;
int StringStart;
int multistring = 0;
int error_no = 0;
int warning_no = 0;
ofstream TokenOutput;

SymbolInfo * Create_Token(string name, string type, string tok_name){
   SymbolInfo * ob = new SymbolInfo(name, type);
   string st = tok_name + " : " + name;
   ob->is_Terminal = true;
   ob->starting = line_no;
   ob->ending = line_no;
   ob->rule = st;
   return ob;
}

SymbolTable ob(10);

map<string, string> Escapechar = {
 {"\\n","\n"},
 {"\\r","\r"},
 {"\\a","\a"},
 {"\\t","\t"}
};

map<string, string> Escapechar2 = {
 {"n","\n"},
 {"r","\r"},
 {"a","\a"},
 {"t","\t"},
 {"\\", "\\"},
 {"r", "\r"},
 {"a", "\a"},
 {"b", "\b"},
 {"\"", "\""},
 {"\"", "\""},
 {"0", "\0"},
};

void PrintToken(string tok, string name)
{
   if(tok != "CONST_CHAR1")
   {
     //TokenOutput<<"<"<<tok<<", "<<name<<">"<<endl;
     cout<<"Line# "<<line_no<<": Token <"<<tok<<"> Lexeme "<<name<<" found"<<endl;
   }
   if(tok == "ID")
   {
    //bool flag = ob.Insert(name,tok);
    /*if(flag == true)
    { 
       //ob.Print_All();
    }*/
   }
   if(tok == "LCURL")
   {
    //ob.Enter_scope();
   }
   if(tok == "RCURL")
   {
    //ob.Exit_Scope();
   }
   if(tok == "CONST_CHAR")
   {
      string temp = name;
      temp = temp.substr(1,2);
      //temp = temp.substr(1,1);
      cout<<"<"<<tok<<", "<<Escapechar[temp]<<">"<<endl;
      cout<<"Line# "<<line_no<<": Token <"<<tok<<"> Lexeme "<<Escapechar[temp]<<" found"<<endl;
      cout<<"Line# "<<line_no<<": Token <"<<tok<<"> Lexeme "<<temp[0]<<" found"<<endl;
   }
}

void CharacterPrint(string tok, string name)
{
   string temp = name;
   if(tok == "CONST_CHAR")
   {
      TokenOutput<<"<"<<tok<<", "<<temp[1]<<">"<<endl;
      cout<<"Line# "<<line_no<<": Token <"<<tok<<"> Lexeme "<<temp[1]<<" found"<<endl;
   }
   if(tok == "CONST_CHAR1")
   {
      temp = temp.substr(1,2);
      //temp = temp.substr(1,1);
      TokenOutput<<"<"<<"CONST_CHAR"<<", "<<Escapechar[temp]<<">"<<endl;
      cout<<"Line# "<<line_no<<": Token <"<<"CONST_CHAR"<<"> Lexeme "<<Escapechar[temp]<<" found"<<endl;
   }
}

void PrintString()
{
   if(multistring == 1)
   {
      cout<<"Line# "<<StringStart<<": Token <"<<"MULTI LINE STRING"<<"> Lexeme "<<str<<" found"<<endl;
   }
   else
   {
      cout<<"Line# "<<StringStart<<": Token <"<<"SINGLE LINE STRING"<<"> Lexeme "<<str<<" found"<<endl;
   }
   string temp1 ="";
   string temp2 = "";
   if(multistring == 0)
   {
      for(int i=1;i<str.length()-1;i++)
      {
         if(str[i] == '\\')
         {
         temp2 = str[i+1];
         //cout<<"PRINING TEMP2 "<<temp2<<endl;
         //temp2 = temp2.substr(i,i+1);
         //TokenOutput<<"ESCAPE CHAR"<<Escapechar2[temp2]<<endl;
         temp1 += Escapechar2[temp2];
         i++;
         
         //cout<<str<<endl;
         //cout<<"PRINING TEMP1 "<<temp1<<endl;
         }
         else
         {
            temp1 += str[i];
         }
      }
   }

   /*if(multistring == 1)
   {
      for(int i=0;i<str.length();i++)
      {
         if(str[i] == '\\')
         {
         temp2 = "t";
         cout<<"PRINING TEMP2 "<<temp2<<endl;
         //temp2 = temp2.substr(i,i+1);
         cout<<"ESCAPE CHAR"<<Escapechar2[temp2]<<endl;
         temp1 += Escapechar2[temp2];
         i++;
         cout<<str<<endl;
         cout<<"PRINING TEMP1 "<<temp1<<endl;
         }
         else
         {
            temp1 += str[i];
         }
      }
   }*/
   
  if(multistring == 1)
   {
      TokenOutput<<"<"<<"MULTI LINE STRING"<<", "<<tokstr<<">"<<endl;
   }
   else
   {
      TokenOutput<<"<"<<"SINGLE LINE STRING"<<", "<<temp1<<">"<<endl;
   }
}

void PrintSingleComment()
{
   cout<<"Line# "<<StringStart<<": Token <"<<"SINGLE LINE COMMENT"<<"> Lexeme "<<str<<" found"<<endl;
}

void PrintMultiComment()
{
   cout<<"Line# "<<StringStart<<": Token <"<<"MULTI LINE COMMENT"<<"> Lexeme "<<str<<" found"<<endl;
}

void PrintError(int line, string type, string value)
{
   cout<<"Error at line# "<<line<<": "<<type<<" "<<value<<endl;
   if(type == "UNFINISHED_COMMENT")
   {
      ob.Print_All();
   }
}

%}

Letter [a-zA-Z]
DIGIT [0-9]
EXPONENT [Ee][+-]?{DIGIT}+
%%
[ \t\v]+ {}
if {PrintToken("IF","if");
          yylval.ysymbol = Create_Token(yytext, "KEYWORD", "IF");
          return IF;
             }

for {PrintToken("FOR","for");
          yylval.ysymbol = Create_Token(yytext, "KEYWORD", "FOR");
          return FOR;
         }
loop {PrintToken("LOOP","loop");
          yylval.ysymbol = Create_Token(yytext, "KEYWORD", "LOOP");
          return LOOP;
         }

do {PrintToken("DO","do");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "DO");
          return DO;}

int {PrintToken("INT","int");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "INT");
          return INT;}

float {PrintToken("FLOAT","float");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "FLOAT");
          return FLOAT;}

void {PrintToken("VOID","void");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "VOID");
          return VOID;}

switch {PrintToken("SWITCH","switch");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "SWITCH");
          return SWITCH;}

default {PrintToken("DEFAULT","default");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "DEFAULT");
          return DEFAULT;}

else {PrintToken("ELSE","else");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "ELSE");
          return ELSE;}

while {PrintToken("WHILE","while");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "WHILE");
          return WHILE;}

break {PrintToken("BREAK","break");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "BREAK");
          return BREAK;}

char {PrintToken("CHAR","char");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "CHAR");
          return CHAR;}

double {PrintToken("DOUBLE","double");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "DOUBLE");
          return DOUBLE;}

return {PrintToken("RETURN","return");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "RETURN");
          return RETURN;}

case {PrintToken("CASE","case");
         yylval.ysymbol = Create_Token(yytext, "KEYWORD", "CASE");
          return CASE;}

continue {PrintToken("CONTINUE","continue");
               yylval.ysymbol = Create_Token(yytext, "KEYWORD", "CONTINUE");
               return CONTINUE;}

[+-] {PrintToken("ADDOP",yytext);
          yylval.ysymbol = Create_Token(yytext, "ADDOP", "ADDOP");
          return ADDOP;}

[*/%] {PrintToken("MULOP",yytext);
            yylval.ysymbol = Create_Token(yytext, "MULOP", "MULOP");
            return MULOP;}

"++"|"--" {PrintToken("INCOP",yytext);
               yylval.ysymbol = Create_Token(yytext, "INCOP", "INCOP");
               return INCOP;}

"<"|"<="|">"|">="|"=="|"!=" {PrintToken("RELOP",yytext);
                                 yylval.ysymbol = Create_Token(yytext, "RELOP", "RELOP");
                                 return RELOP;}

"=" {PrintToken("ASSIGNOP",yytext);
          yylval.ysymbol = Create_Token(yytext, "ASSIGNOP", "ASSIGNOP");
          return ASSIGNOP;}

"&&"|"||" {PrintToken("LOGICOP",yytext);
               yylval.ysymbol = Create_Token(yytext, "LOGICOP", "LOGICOP");
               return LOGICOP;}

"&"|"|"|"^"|"<<"|">>" {PrintToken("BITOP",yytext);
                           yylval.ysymbol = Create_Token(yytext, "BITOP", "BITOP");
                           return BITOP;}

"!" {PrintToken("NOT",yytext);
          yylval.ysymbol = Create_Token(yytext, "NOT", "NOT");
          return NOT;}

"(" {PrintToken("LPAREN",yytext);
          yylval.ysymbol = Create_Token(yytext, "LPAREN", "LPAREN");
          return LPAREN;}

")" {PrintToken("RPAREN",yytext);
          yylval.ysymbol = Create_Token(yytext, "RPAREN", "RPAREN");
          return RPAREN;}

"{" {PrintToken("LCURL",yytext);
          yylval.ysymbol = Create_Token(yytext, "LCURL", "LCURL");
          return LCURL;}

"}" {PrintToken("RCURL",yytext);
          yylval.ysymbol = Create_Token(yytext, "RCURL", "RCURL");
          return RCURL;}  

"[" {PrintToken("LSQUARE",yytext);
          yylval.ysymbol = Create_Token(yytext, "LSQUARE", "LSQUARE");
          return LSQUARE;}

"]" {PrintToken("RSQUARE",yytext);
          yylval.ysymbol = Create_Token(yytext, "RSQUARE", "RSQUARE");
          return RSQUARE;}

"," {PrintToken("COMMA",yytext);
          yylval.ysymbol = Create_Token(yytext, "COMMA", "COMMA");
          return COMMA;}

";" {PrintToken("SEMICOLON",yytext);
          yylval.ysymbol = Create_Token(yytext, "SEMICOLON", "SEMICOLON");
          return SEMICOLON;}

"println" {PrintToken("PRINTLN",yytext);
          yylval.ysymbol = Create_Token(yytext, "PRINTLN", "PRINTLN");
          return PRINTLN;}

'[a-zA-Z0-9_]' {CharacterPrint("CONST_CHAR", yytext);}

\'\\[a-zA-Z0-9]' {CharacterPrint("CONST_CHAR1",yytext);}

[a-zA-Z_][a-zA-Z0-9_]* {PrintToken("ID",yytext);
             SymbolInfo * ob = new SymbolInfo(yytext, "ID");
               string st = "ID : ";
               st += yytext;
              ob->is_Terminal = true;
             ob->starting = line_no;
             ob->ending = line_no;
             ob->rule = st;
             yylval.ysymbol = ob;
             return ID;} 

[0-9]+ {PrintToken("CONST_INT",yytext);
         SymbolInfo * ob = new SymbolInfo(yytext, "CONST_INT","int");
               string st = "CONST_INT : ";
               st += yytext;
              ob->is_Terminal = true;
             ob->starting = line_no;
             ob->ending = line_no;
             ob->rule = st;
             yylval.ysymbol = ob;
             return CONST_INT;}
{DIGIT}*(\.{DIGIT}+)?{EXPONENT}? {PrintToken("CONST_FLOAT",yytext);
         SymbolInfo * ob = new SymbolInfo(yytext, "CONST_FLOAT","float");
               string st = "CONST_FLOAT : ";
               st += yytext;
              ob->is_Terminal = true;
             ob->starting = line_no;
             ob->ending = line_no;
             ob->rule = st;
             yylval.ysymbol = ob;
             return CONST_FLOAT;}             
             


\" {str = yytext; tokstr = ""; StringStart = line_no; BEGIN STRING;}
<STRING>\\(\r)?\n       {str += yytext; tokstr += "" ; line_no++; multistring = 1;}
<STRING>\\\"      {str += yytext; tokstr += yytext;}
<STRING>[^\"\n\r]       {str += yytext; tokstr += yytext;}
<STRING>\"     {str += yytext; PrintString(); multistring = 0; BEGIN INITIAL; }
<STRING>(\r)?\n      {line_no++; error_no++ ; PrintError(line_no-1, "UNFINISHED_STRING" , str); BEGIN INITIAL;}

"//" {str = yytext; StringStart = line_no; BEGIN SingleComment; }
<SingleComment>\\(\r)?\n      {str += yytext; line_no++; }
<SingleComment>.     {str+= yytext;}
<SingleComment>(\r)?\n     {line_no++; PrintSingleComment(); BEGIN INITIAL;}

"/*" {str = yytext; StringStart = line_no; BEGIN MultiComment;}
<MultiComment>(\r)?\n {str += yytext; line_no++;}
<MultiComment>"*/" {str += yytext; PrintMultiComment(); BEGIN INITIAL;}
<MultiComment>. {str += yytext;}
<MultiComment><<EOF>> {error_no++; PrintError(line_no, "UNFINISHED_COMMENT" , str); cout<<"Total lines: "<<line_no<<endl; cout<<"Total errors: "<<error_no<<endl; cout<<"Total warnings: "<<warning_no<<endl; return 0;}

[0-9]*\.[0-9]+E?[+-]?\.[0-9]*(\.[0-9])*E?[+-]?[0-9]*? {error_no ++; PrintError(line_no, "TOO_MANY_DECIMAL_POINTS",yytext);}
[1-9][0-9]*E[+-]?[0-9]*\.[0-9]+ {error_no ++; PrintError(line_no, "ILLFORMED_NUMBER",yytext);}
[0-9]+[a-zA-Z_]+ {error_no ++; PrintError(line_no, "INVALID_ID_SUFFIX_NUM_PREFIX",yytext);}
'.[^\'\n\r]+' {error_no ++; PrintError(line_no, "MULTICHAR_CONST_CHAR",yytext);}
'\\' {error_no ++; PrintError(line_no, "UNFINISHED_CONST_CHAR",yytext);}
'\\?[^\'\r\n]* {error_no ++; PrintError(line_no, "UNFINISHED_CONST_CHAR",yytext);}
'' {error_no ++; PrintError(line_no, "EMPTY_CONST_CHAR",yytext);}

(\r)?\n {line_no++;}
<<EOF>> {cout<<"Total lines: "<<line_no<<endl; cout<<"Total errors: "<<error_no<<endl; cout<<"Total warnings: "<<warning_no<<endl; return 0;}
. {error_no ++; PrintError( line_no, "UNRECOGNIZED_CHAR", yytext);}
%%

/*int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
   freopen("2005081_log.txt", "w", stdout);
    TokenOutput.open("2005081_token.txt");
	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}*/
