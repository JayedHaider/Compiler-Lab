%option noyywrap

%x STRING
%x SingleComment
%x MultiComment

%{
#include<bits/stdc++.h>
#include "2005081_symbolTable.cpp"
using namespace std;
int word_count=0;
int line_no = 1;
string str;
string tokstr;
int StringStart;
int multistring = 0;
int error_no = 0;
int warning_no = 0;
ofstream TokenOutput;

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
     TokenOutput<<"<"<<tok<<", "<<name<<">"<<endl;
     cout<<"Line# "<<line_no<<": Token <"<<tok<<"> Lexeme "<<name<<" found"<<endl;
   }
   if(tok == "ID")
   {
    bool flag = ob.Insert(name,tok);
    if(flag == true)
    { 
       ob.Print_All();
    }
   }
   if(tok == "LCURL")
   {
    ob.Enter_scope();
   }
   if(tok == "RCURL")
   {
    ob.Exit_Scope();
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

%%
[ \t\v]+ {}
if {PrintToken("IF","if");}
for {PrintToken("FOR","for");}
do {PrintToken("DO","do");}
int {PrintToken("INT","int");}
float {PrintToken("FLOAT","float");}
void {PrintToken("VOID","void");}
switch {PrintToken("SWITCH","switch");}
default {PrintToken("DEFAULT","default");}
else {PrintToken("ELSE","else");}
while {PrintToken("WHILE","while");}
break {PrintToken("BREAK","break");}
char {PrintToken("CHAR","char");}
double {PrintToken("DOUBLE","double");}
return {PrintToken("RETURN","return");}
case {PrintToken("CASE","case");}
continue {PrintToken("CONTINUE","continue");}

[+-] {PrintToken("ADDOP",yytext);}
[*/%] {PrintToken("MULOP",yytext);}
"++"|"--" {PrintToken("INCOP",yytext);}
"<"|"<="|">"|">="|"=="|"!=" {PrintToken("RELOP",yytext);}
"=" {PrintToken("ASSIGNOP",yytext);}
"&&"|"||" {PrintToken("LOGICOP",yytext);}
"&"|"|"|"^"|"<<"|">>" {PrintToken("BITOP",yytext);}
"!" {PrintToken("NOT",yytext);}
"(" {PrintToken("LPAREN",yytext);}
")" {PrintToken("RPAREN",yytext);}
"{" {PrintToken("LCURL",yytext);}
"}" {PrintToken("RCURL",yytext);}  
"[" {PrintToken("LSQUARE",yytext);}
"]" {PrintToken("RSQUARE",yytext);}
"," {PrintToken("COMMA",yytext);}
";" {PrintToken("SEMICOLON",yytext);}

'[a-zA-Z0-9_]' {CharacterPrint("CONST_CHAR", yytext);}
\'\\[a-zA-Z0-9]' {CharacterPrint("CONST_CHAR1",yytext);}
[a-zA-Z_][a-zA-Z0-9_]* {PrintToken("ID",yytext);} 
[0-9]+ {PrintToken("CONST_INT",yytext);}
[0-9]*\.[0-9]+E?-?[0-9]+|[0-9]+E-?[0-9]+ {PrintToken("CONST_FLOAT",yytext);}

\" {str = yytext; tokstr = ""; StringStart = line_no; BEGIN STRING;}
<STRING>\\(\r)?\n {str += yytext; tokstr += "" ; line_no++; multistring = 1;}
<STRING>\\\" {str += yytext; tokstr += yytext;}
<STRING>[^\"\n\r] {str += yytext; tokstr += yytext;}
<STRING>\" {str += yytext; PrintString(); multistring = 0; BEGIN INITIAL; }
<STRING>(\r)?\n {line_no++; error_no++ ; PrintError(line_no-1, "UNFINISHED_STRING" , str); BEGIN INITIAL;}

"//" {str = yytext; StringStart = line_no; BEGIN SingleComment; }
<SingleComment>\\(\r)?\n {str += yytext; line_no++; }
<SingleComment>. {str+= yytext;}
<SingleComment>(\r)?\n {line_no++; PrintSingleComment(); BEGIN INITIAL;}

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
<<EOF>> { ob.Print_All(); cout<<"Total lines: "<<line_no<<endl; cout<<"Total errors: "<<error_no<<endl; cout<<"Total warnings: "<<warning_no<<endl; return 0;}
. {error_no ++; PrintError( line_no, "UNRECOGNIZED_CHAR", yytext);}
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
	
   freopen("2005081_log.txt", "w", stdout);
    TokenOutput.open("2005081_token.txt");
	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
