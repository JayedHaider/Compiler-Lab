#pragma once
#include<bits/stdc++.h>

using namespace std;

//int scope_count = 0;

class Identifiers{
    public:
    string name;
    string type;
    bool is_Array;
    Identifiers(string name = "", string type = "", bool is_Array = false)
    {
        this->name = name;
        this->type = type;
        this->is_Array = is_Array;
    }
};

class SymbolInfo
{
public:
    string name;
    string type;
    bool is_Array;
    string func_ret;
    bool is_Terminal;
    string data_type;
    int starting;
    int ending;
    string rule;
    vector<SymbolInfo *> child_list;
    vector <Identifiers> Identifiers_list;
    SymbolInfo * next;
    int level;
    int fpos;
    int lpos;
    bool is_Global;
    vector <SymbolInfo *> declaration_list;
    //static vector <SymbolInfo *> global_list;
    vector <SymbolInfo *> global_list;
    int stack_offset;
       //static inline int scope = 0;
    static inline int label = 0;
    bool is_Condition ;
    string label_end;
    string label_true;
    string label_false;
    vector <SymbolInfo *> params;  
    int arraysize; 
    SymbolInfo(string name, string type, string data_type = "INT")
    {
        this->name = name;
        this->type = type;
        next = nullptr;
        is_Array = false;
        func_ret = "";
        is_Terminal = false;
        this->data_type = data_type;
        starting = -5;
        ending = -5;
        lpos = 0;
        fpos = 0;
        is_Global = false;
        stack_offset = 0;
        is_Condition = false;
        label_end = "";
        label_true = "";
        label_false = "";
        arraysize = 0;
        //scope++;
        //cout<<"IN SYMBOL"<<scope<<endl<<endl;
    }
    SymbolInfo()
    {
        name = "5G";
        type = "Empty";
        next = nullptr;
        //scope++;
        //cout<<"IN SYMBOL"<<scope<<endl<<endl;
    }
    string getName()
    {
        return name;
    }
    void setName(string str)
    {
        name = str;
    }
    string gettype()
    {
        return type;
    }
    SymbolInfo * getNext()
    {
        return next;
    }
    string CreateLabel()    
    {
        string str = "L";
        str = str + to_string(label) + ":";
        label++;
        return str;
    }
    string JmpIns(string str)
    {
        if(str == "<")
        {
            return "JL";
        }
        if(str == ">")
        {
            return "JG";
        }
        if(str == "<=")
        {
            return "JLE";
        }
        if(str == ">=")
        {
            return "JGE";
        }
        if(str == "==")
        {
            return "JE";
        }
        if(str == "!=")
        {
            return "JNE";
        }
    }
    void AddChild(SymbolInfo * ob)
    {
        ob->level = this->level+1;
        child_list.push_back(ob);
        if(starting == -5)
        {
            starting = ob->starting;
        }
        else
        {
            starting = min(this->starting, ob->starting);
        }
        if(ending == -5)
        {
            ending = ob->ending;
        }
        else
        {
        ending = max(ending, ob->ending);
        }    
    }
    void Print_ParseTree(ostream &out, SymbolInfo * list = nullptr, int lev=0)
    {
        //cout<<"IN PARSE_TREE"<<endl;
        if(list == nullptr)
        {
        for(int i=0;i<lev;i++)
        {
            out<<" ";
        }
        out<<this->rule<<"    "<<"<Line: "<<this->starting;
        if(is_Terminal == false)
        {
            out<<"-"<<ending;
        }
        list = this;
        }
        else
        {
            for(int i=0;i<lev;i++)
            {
                out<<" ";
            }   
            out<<list->rule<<"    "<<"<Line: "<<list->starting;
            if(list->is_Terminal == false)
            {
                out<<"-"<<list->ending;
            }
        }
        out<<">"<<endl;
        for(int i = 0; i<list->child_list.size(); i++)
        {
           Print_ParseTree(out, list->child_list[i],lev+1);
        }
    }

    void Code_Generate(int level, ostream &code)
    {
        if(rule == "start : program")
        {
            
            string newLineProc = "NEWLINE PROC\n\tPUSH AX\n\tPUSH DX\n\tMOV AH,2\n\tMOV DL,CR\n\tINT 21H\n\tMOV AH,2\n\tMOV DL,LF\n\tINT 21H\n\tPOP DX\n\tPOP AX\n\tRET\nNEWLINE ENDP\n";
            string printOutputProc = "PRINTNUMBER PROC  ;PRINT WHAT IS IN AX\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH SI\n\tLEA SI,NUMBER\n\tMOV BX,10\n\tADD SI,4\n\tCMP AX,0\n\tJNGE NEGATE\n\tPRINT:\n\tXOR DX,DX\n\tDIV BX\n\tMOV [SI],DL\n\tADD [SI],'0'\n\tDEC SI\n\tCMP AX,0\n\tJNE PRINT\n\tINC SI\n\tLEA DX,SI\n\tMOV AH,9\n\tINT 21H\n\tPOP SI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tNEGATE:\n\tPUSH AX\n\tMOV AH,2\n\tMOV DL,'-'\n\tINT 21H\n\tPOP AX\n\tNEG AX\n\tJMP PRINT\nPRINTNUMBER ENDP\n";
            string heading = ".MODEL SMALL \n .STACK 1000H \n.Data\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tNUMBER DB \"00000$\"\n";
            code<<heading<<endl;
            for(int i = 0;i < global_list.size();i++)
            {
                if(global_list[i]->is_Array == true)
                {
                    code<<global_list[i]->name<<" DW "<<global_list[i]->arraysize<<" DUP (0000H)"<<endl;
                }
                else
                {
                    code<<global_list[i]->name<<" DW 1 DUP (0000H)"<<endl;    
                }
                
            }
            code<<".CODE"<<endl;                
           child_list[0]->Code_Generate(level+1, code);
           code<<newLineProc<<endl;
           code<<printOutputProc<<endl;
           code<<"END main"<<endl;
        }
        if(rule == "program : program unit")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[1]->Code_Generate(level+1, code);
        }
        if(rule == "program : unit")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "unit : var_declaration")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "unit : func_declaration")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "unit : func_definition")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[3]->Code_Generate(level+1, code);
        }
        if(rule == "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[3]->Code_Generate(level+1, code);
            code<<child_list[1]->name<<" PROC"<<endl;
            if(child_list[1]->name == "main")
            {
                code<<"MOV AX, @DATA"<<endl;
                code<<"MOV DS, AX"<<endl;
            }
            code<<"PUSH BP"<<endl;
            code<<"MOV BP, SP"<<endl;
            child_list[5]->Code_Generate(level+1, code);
            code<<child_list[1]->name<<"_ending:"<<endl;
            if(child_list[1]->name == "main")
            {
                code<<"MOV AH, 4CH"<<endl;
                code<<"INT 21H"<<endl;
            }
            code<<"ADD SP, "<<child_list[5]->stack_offset<<endl;
            code<<"POP BP"<<endl;    
            if(child_list[1]->name != "main")
            {
                code<<"RET"<<endl;
            }
            code<<child_list[1]->name<<" ENDP"<<endl;
        }
        if(rule == "func_definition : type_specifier ID LPAREN RPAREN compound_statement")
        {
            child_list[0]->Code_Generate(level+1, code);
            code<<child_list[1]->name<<" PROC"<<endl;
            if(child_list[1]->name == "main")
            {
                code<<"MOV AX, @DATA"<<endl;
                code<<"MOV DS, AX"<<endl;
            }
            code<<"PUSH BP"<<endl;
            code<<"MOV BP, SP"<<endl;
            child_list[4]->Code_Generate(level+1, code);
            code<<child_list[1]->name<<"_ending:"<<endl;
            if(child_list[1]->name == "main")
            {
                code<<"MOV AH, 4CH"<<endl;
                code<<"INT 21H"<<endl;
            }
            code<<"ADD SP, "<<child_list[4]->stack_offset<<endl;
            code<<"POP BP"<<endl;
            if(child_list[1]->name != "main")
            {
                code<<"RET"<<endl;
            }
            code<<child_list[1]->name<<" ENDP"<<endl;
            //code<<"IN FUNCTION"<<endl;
        }
        if(rule == "parameter_list  : parameter_list COMMA type_specifier ID")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[2]->Code_Generate(level+1, code);
        }
        if(rule == "parameter_list  : parameter_list COMMA type_specifier")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[2]->Code_Generate(level+1, code);
        }
        if(rule == "parameter_list  : type_specifier ID")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "parameter_list  : type_specifier")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "compound_statement : LCURL statements RCURL")
        {
            if(label_end == "")
            {
                label_end = CreateLabel();
            }
            child_list[1]->label_end = label_end;
            child_list[1]->Code_Generate(level+1, code);
           // code<<"IN COMPOUND"<<endl;
        }
        /*if(rule == "compound_statement : LCURL RCURL")
        {
            
        }*/
        if(rule == "var_declaration : type_specifier declaration_list SEMICOLON")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[1]->Code_Generate(level+1, code);
           // code<<"IN VAR DECLARATION"<<endl;
            //code<<is_Global<<"  "<<declaration_list.size()<<endl;
            if(is_Global == false)
            {
                for(int i=0;i<declaration_list.size();i++)
                {
                    if(declaration_list[i]->is_Array == true)
                    {
                        code<<"SUB SP, "<<declaration_list[i]->arraysize*2<<endl;
                    }
                    else
                    {
                       code<<"SUB SP, 2"<<endl;     
                    }
                   
                }
            }
            
        }
        /*if(rule == "type_specifier	: INT")
        {
            
        }
        if(rule == "type_specifier	: FLOAT")
        {
            
        }
        if(rule == "type_specifier	: VOID")
        {
            
        }
        if(rule == "declaration_list : declaration_list COMMA ID")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "declaration_list : ID")
        {
            
        }
        if(rule == "declaration_list : ID LSQUARE CONST_INT RSQUARE")
        {
            
        }*/
        if(rule == "statements : statement")
        {
            child_list[0]->label_end = label_end;
            child_list[0]->Code_Generate(level+1, code);
            code<<label_end<<endl;
        }
        if(rule == "statements : statements statement")
        {
            child_list[0]->label_end = CreateLabel();
            child_list[1]->label_end = label_end;
            child_list[0]->Code_Generate(level+1, code);
            child_list[1]->Code_Generate(level+1, code);
            code<<label_end<<endl;
           // code<<"IN STATEMENT"<<endl;
        }
        if(rule == "statement : var_declaration")
        {
            child_list[0]->Code_Generate(level+1, code);
            //code<<"IN Statemnt VAR DECLARATION"<<endl;
        }
        if(rule == "statement : expression_statement")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "statement : compound_statement")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement")
        {
            child_list[3]->is_Condition = true;
            child_list[3]->label_true = CreateLabel();
            child_list[3]->label_false = label_end;
            child_list[5]->label_end = label_end;
            string itearate = CreateLabel();
            child_list[2]->Code_Generate(level+1, code);
            code<<itearate<<endl;
            child_list[3]->Code_Generate(level+1, code);
            code<<child_list[3]->label_true<<endl;
            child_list[6]->Code_Generate(level+1, code);
            child_list[4]->Code_Generate(level+1, code);
            code<<"JMP "<<itearate<<endl;
        }
        if(rule == "statement : IF LPAREN expression RPAREN statement")
        {
            child_list[2]->is_Condition = true;
            child_list[2]->label_true = CreateLabel();
            child_list[2]->label_false = label_end;
            child_list[4]->label_end = label_end;
            child_list[2]->Code_Generate(level+1, code);
            code<<child_list[2]->label_true<<endl;
            child_list[4]->Code_Generate(level+1, code);
        }
        if(rule == "statement : IF LPAREN expression RPAREN statement ELSE statement")
        {
            child_list[2]->is_Condition = true;
            child_list[2]->label_true = CreateLabel();
            child_list[2]->label_false = CreateLabel();
            child_list[4]->label_end = child_list[2]->label_false;
            child_list[6]->label_end = label_end;
            child_list[2]->Code_Generate(level+1, code);
            code<<child_list[2]->label_true<<endl;
            child_list[4]->Code_Generate(level+1, code);
            code<<"JMP "<<label_end<<endl;
            code<<child_list[2]->label_false<<endl;
            child_list[6]->Code_Generate(level+1, code);
        }
        if(rule == "statement : WHILE LPAREN expression RPAREN statement")
        {
            child_list[2]->is_Condition = true;
            child_list[2]->label_true = CreateLabel();
            child_list[2]->label_false = label_end;
            child_list[4]->label_end = label_end;
            string itearate = CreateLabel();
            code<<itearate<<endl;
            child_list[2]->Code_Generate(level+1, code);
            code<<child_list[2]->label_true<<endl;
            child_list[4]->Code_Generate(level+1, code);
            code<<"JMP "<<itearate<<endl;
        }
        if(rule == "statement : PRINTLN LPAREN ID RPAREN SEMICOLON")
        {
             if(is_Global == true)
             {
                code<<"MOV AX, "<<child_list[2]->name<<endl;
                code<<"CALL PRINTNUMBER"<<endl;
                code<<"CALL NEWLINE"<<endl;
             }
             if(is_Global == false)
             {
                code<<"MOV AX, [BP-"<<stack_offset<<"]"<<endl;
                code<<"CALL PRINTNUMBER"<<endl;
                code<<"CALL NEWLINE"<<endl;
             }
        }
        if(rule == "statement : RETURN expression SEMICOLON")
        {
            child_list[1]->Code_Generate(level+1, code);
            code<<"MOV DX, CX"<<endl;
            code<<"JMP "<<child_list[0]->name<<"_ending"<<endl;
        }
        if(rule == "expression_statement : SEMICOLON")
        {
            
        }
        if(rule == "expression_statement : expression SEMICOLON")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "variable : ID")
        {
            if(is_Global == false)
            {
                code<<"PUSH BP"<<endl;
                code<<"MOV BX, "<<stack_offset<<endl;
                code<<"SUB BP, BX"<<endl; 
            }
        }
        if(rule == "variable : ID LSQUARE expression RSQUARE")
        {
            child_list[2]->Code_Generate(level+1, code);
            if(is_Global == false)
            {
                code<<"PUSH BP"<<endl;
                code<<"MOV BX, CX"<<endl;
                code<<"ADD BX, BX"<<endl;
                code<<"ADD BX,"<<stack_offset<<endl;
                code<<"SUB BP, BX"<<endl; 
            }
            if(is_Global == true)
            {
                code<<"LEA SI, "<<child_list[0]->name<<endl;
                code<<"ADD SI, CX"<<endl;
                code<<"ADD SI, CX"<<endl;
                code<<"PUSH BP"<<endl;
                code<<"MOV BP, SI"<<endl;
            }
        }
        if(rule == "expression : logic_expression")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "expression : variable ASSIGNOP logic_expression")
        {
            child_list[2]->Code_Generate(level+1, code);
            child_list[0]->is_Condition = false;
            child_list[2]->is_Condition = false;
            //code<<"PUSH CX"<<endl;
            
            //code<<"POP CX"<<endl;
            if(child_list[0]->is_Global == true && child_list[0]->is_Array == false)
            {
                child_list[0]->Code_Generate(level+1, code);
                code<<"MOV "<<child_list[0]->name<<", CX"<<endl;
            }
            else
            {
                code<<"PUSH CX"<<endl;
                child_list[0]->Code_Generate(level+1, code);
                code<<"POP BX"<<endl;
                code<<"POP CX"<<endl;
                code<<"MOV [BP], CX"<<endl;
                code<<"MOV BP, BX"<<endl;
            }
           /* if(child_list[0]->is_Global == false)
            {
                code<<"PUSH CX"<<endl;
                child_list[0]->Code_Generate(level+1, code);
                code<<"POP BX"<<endl;
                code<<"POP CX"<<endl;
                code<<"MOV [BP], CX"<<endl;
                code<<"MOV BP, BX"<<endl;
            }*/
        }
        if(rule == "logic_expression : rel_expression")
        {
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "logic_expression : rel_expression LOGICOP rel_expression")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[2]->is_Condition = is_Condition;
            if(child_list[1]->name == "&&")
            {
               child_list[0]->label_true = CreateLabel();
               child_list[0]->label_false = label_false;
               child_list[2]->label_true = label_true;
                child_list[2]->label_false = label_false;
            }
            if(child_list[1]->name == "||")
            {
               child_list[0]->label_true = label_true;
               child_list[0]->label_false = CreateLabel();
               child_list[2]->label_true = label_true;
               child_list[2]->label_false = label_false;
            }
            child_list[0]->Code_Generate(level+1, code);
            if(is_Condition == true)
            {
                if(child_list[1]->name == "&&")
                {
                    code<<child_list[0]->label_true<<endl;
                }
                if(child_list[1]->name == "||")
                {
                    code<<child_list[0]->label_false<<endl;
                }
            }
            else
            {
                code<<"PUSH CX"<<endl;
            }
            child_list[2]->Code_Generate(level+1, code);
            if(is_Condition == false)
            {
                code<<"POP AX"<<endl;
                string inter = CreateLabel();
                string assign0 = CreateLabel();
                string assign1 = CreateLabel();
                string end = CreateLabel();
                if(child_list[1]->name == "||")
                {
                  code<<"CMP AX, 0"<<endl;
                  code<<"JE "<<inter<<endl;
                  code<<"JMP "<<assign1<<endl;
                  code<<inter<<endl;
                  code<<"CMP CX, 0"<<endl;
                  code<<"JE "<<assign0<<endl;
                  code<<assign1<<endl;
                  code<<"MOV CX, 1"<<endl;
                  code<<"JMP "<<end<<endl;
                  code<<assign0<<endl;
                  code<<"MOV CX, 0"<<endl;
                  code<<end<<endl;   
                }
                if(child_list[1]->name == "&&")
                {
                    code<<"CMP AX, 0"<<endl;
                    code<<"JE "<<assign0<<endl;
                    code<<"CMP CX, 0"<<endl;
                    code<<"JE "<<assign0<<endl;
                    code<<"JMP "<<assign1<<endl; 
                    code<<assign0<<endl;
                    code<<"MOV CX, 0"<<endl;
                    code<<"JMP "<<end<<endl;
                    code<<assign1<<endl;
                    code<<"MOV CX, 1"<<endl;
                    code<<end<<endl;   
                }
            }

        }
        if(rule == "rel_expression	: simple_expression")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "rel_expression	: simple_expression RELOP simple_expression")
        {
            child_list[0]->Code_Generate(level+1, code);
            code<<"PUSH CX"<<endl;
            child_list[2]->Code_Generate(level+1, code);
            code<<"POP AX"<<endl;
            string jmp = JmpIns(child_list[1]->name);
            code<<"CMP AX, CX"<<endl;
            if(label_true == "")
            {
                label_true = CreateLabel();
            }
            if(label_false == "")
            {
                label_false = CreateLabel();
            }
            code<<jmp<<" "<<label_true<<endl;
            code<<"JMP "<<label_false<<endl;
            if(is_Condition == false)
            {
                string ending = CreateLabel();
                code<<label_true<<endl;
                code<<"MOV CX, 1"<<endl;
                code<<"JMP "<<ending<<endl;
                code<<label_false<<endl;
                code<<"MOV CX, 0"<<endl;
                code<<ending<<endl;
            }
        }
        if(rule == "simple_expression : term")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "simple_expression : simple_expression ADDOP term")
        {
            child_list[0]->Code_Generate(level+1, code);
            code<<"PUSH CX"<<endl;
            child_list[2]->Code_Generate(level+1, code);
            code<<"POP AX"<<endl;
            if(child_list[1]->name == "+")
            {
                code<<"ADD CX, AX"<<endl;
            }
            if(child_list[1]->name == "-")
            {
                code<<"SUB AX, CX"<<endl;
                code<<"MOV CX, AX"<<endl;
            }
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "term :	unary_expression")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "term :	term MULOP unary_expression")
        {
            child_list[0]->Code_Generate(level+1, code);
            code<<"PUSH CX"<<endl;
            child_list[2]->Code_Generate(level+1, code);
            code<<"POP AX"<<endl;
            if(child_list[1]->name == "*")
            {
                code<<"IMUL CX"<<endl;
                code<<"MOV CX, AX"<<endl;
            }
            if(child_list[1]->name == "/")
            {
                code<<"CWD"<<endl;
                code<<"IDIV CX"<<endl;
                code<<"MOV CX, AX"<<endl;
            }
            if(child_list[1]->name == "%")
            {
                code<<"CWD"<<endl;
                code<<"IDIV CX"<<endl;
                code<<"MOV CX, DX"<<endl;
            }
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "unary_expression : ADDOP unary_expression")
        {
            child_list[1]->is_Condition = is_Condition;
            child_list[1]->label_true = label_true;
            child_list[1]->label_false = label_false;
            child_list[1]->Code_Generate(level+1, code);
            if(child_list[0]->name == "-")
            {
                code<<"NEG CX"<<endl;
            }
        }
        if(rule == "unary_expression : NOT unary_expression")
        {
            child_list[1]->Code_Generate(level+1, code);
        }
        if(rule == "unary_expression : factor")
        {
            child_list[0]->is_Condition = is_Condition;
            child_list[0]->label_true = label_true;
            child_list[0]->label_false = label_false;
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "factor	: variable")
        {
            child_list[0]->Code_Generate(level+1, code);
            if(child_list[0]->is_Global == true && child_list[0]->is_Array == false)
            {
                code<<"MOV CX, "<<child_list[0]->name<<endl;
            }
            else
            {
                code<<"MOV CX, [BP]"<<endl;
                code<<"POP BP"<<endl; 
            }
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "factor	: ID LPAREN argument_list RPAREN")
        {
            child_list[2]->Code_Generate(level+1, code);
            code<<"CALL "<<child_list[0]->name<<endl;
            code<<"MOV CX, DX"<<endl;
            code<<"ADD SP, "<<child_list[2]->stack_offset<<endl;
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "factor	: LPAREN expression RPAREN")
        {
            child_list[1]->Code_Generate(level+1, code);
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "factor	: CONST_INT")
        {
            int num = stoi(child_list[0]->name);
            code<<"MOV CX, "<<num<<endl;
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "factor	: CONST_FLOAT")
        {
            
        }
        if(rule == "factor	: variable INCOP")
        {
            child_list[0]->Code_Generate(level+1, code);
            if(child_list[0]->is_Global == true  && child_list[0]->is_Array == false)
            {
                code<<"MOV CX, "<<child_list[0]->name<<endl;
            }
            else
            {
               code<<"MOV CX, [BP]"<<endl; 
            }
            /*if(child_list[0]->is_Global == false)
            {
               code<<"MOV CX, [BP]"<<endl; 
            }*/
            code<<"PUSH CX"<<endl;
            if(child_list[1]->name == "++")
            {
                code<<"INC CX"<<endl;
            }
            if(child_list[1]->name == "--")
            {
                code<<"DEC CX"<<endl;
            }
            if(child_list[0]->is_Global == true)
            {
                code<<"MOV "<<child_list[0]->name<<", CX"<<endl;
                code<<"POP CX"<<endl;
            }
            if(child_list[0]->is_Global == false)
            {
               code<<"MOV [BP], CX"<<endl;
               code<<"POP CX"<<endl;
               code<<"POP BP"<<endl; 
            }
            if(is_Condition == true)
            {
                code<<"CMP CX, 0"<<endl;
                code<<"JE "<<label_false<<endl;
                code<<"JMP "<<label_true<<endl;
            }
        }
        if(rule == "factor	: variable DECOP")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "argument_list : arguments")
        {
            child_list[0]->Code_Generate(level+1, code);
        }
        if(rule == "argument_list : ")
        {
            
        }
        if(rule == "arguments : arguments COMMA logic_expression")
        {
            child_list[0]->Code_Generate(level+1, code);
            child_list[2]->Code_Generate(level+1, code);
            code<<"PUSH CX"<<endl;
        }
        if(rule == "arguments : logic_expression")
        {
            child_list[0]->Code_Generate(level+1, code);
            code<<"PUSH CX"<<endl;
        }

    }

};

static unsigned long long SDBMHash(string str)
{
    unsigned long long hash = 0;
    unsigned int len = str.length();

    for (int i = 0; i < len; i++)
    {
        hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
    }

    return hash;
}

class ScopeTable
{
public :
    int size;
    SymbolInfo ** p;
    string Id;
    int ChildNumber;
    ScopeTable * parentScope;
    ScopeTable * next;
    int total_stack_offset;
    //static int inline scope_number = -2;  
    ScopeTable(int size)
    {
        this->size = size;
        p = new SymbolInfo * [size];
        parentScope = nullptr;
        next = nullptr;
        ChildNumber = 0;
        for(int i=0; i<size; i++)
        {
            p[i] = new SymbolInfo();
            p[i]->setName("5G");
        }
        total_stack_offset = 0;
        //scope_number++;
        //cout<<"This IS SCOPE  "<<scope_number<<endl;
        //cout<<endl;
    }
   /* ~ScopeTable()
    {
       for(int i=0;i<size;i++)
       {
           SymbolInfo * tmp = p[i];
           while(tmp->next != nullptr)
           {
               SymbolInfo * t = tmp;
               tmp = tmp->next;
               delete t;
           }
        while(tmp != nullptr)
           {
               SymbolInfo * t = tmp;
               tmp = tmp->
           }
       }
       delete p;
    }*/
    bool Insert(SymbolInfo * ob)
    {
        int index = SDBMHash(ob->getName())%size;
        //cout<<"FIRST"<<endl;
        //cout<<index<<endl;
        if(p[index]->getName() == "5G")
        {
            //cout<<"IN IF"<<endl;
            p[index] = ob;
            //cout << "	Inserted  at position " << "<"<< index + 1 << ", 1" << "> of ScopeTable# " << Id<<endl;
            return true;
        }
        else
        {
            SymbolInfo * temp;
            temp = p[index];
            int counter = 2;
            while(1)
            {
                if(ob->getName() == temp->getName())
                {
                    //cout<< "	"<<ob->getName()<<" "<<"already exists in the current ScopeTable"<<endl;
                    return false;
                }
                else
                {
                    if(temp->next == nullptr)
                    {
                        temp->next = ob;
                        //cout << "	Inserted  at position " << "<" <<index + 1<< ", " << counter << "> of ScopeTable# " << Id<<endl;
                        return true;
                    }
                    else
                    {
                        temp = temp->next;
                        counter++;
                    }
                }
            }
        }
    }
    SymbolInfo * Lookup(string str)
    {
        int index = SDBMHash(str)%size;
        SymbolInfo * temp = p[index];
        SymbolInfo * answer;
        int counter = 1;
        while(1)
        {
            if(temp->getName() == str)
            {
                answer = temp;
                //cout<< "	'"<< str << "'" <<" found at position <" << index + 1<< ", "<<counter<<"> of ScopeTable# "<<Id<<endl;
                return answer;
            }
            else
            {
                //cout<<"IN ELSE"<<temp->getName()<<endl;
                if(temp->next == nullptr)
                {
                    //cout<<"IN ELSE IF"<<endl;
                    answer = nullptr;
                    //cout<<"'"<<str<<"'"<<" not found in any of the ScopeTables"<<endl;
                    return answer;
                }
                else
                {
                    temp = temp->next;
                    counter++;
                }
            }
        }
    }
    bool Delete(string str)
    {
        int index = SDBMHash(str)%size;
        SymbolInfo * curr;
        SymbolInfo * prev;
        curr = p[index];
        //cout<<curr->getName()<<endl;
        //cout<<str<<endl;
        prev = curr;
        SymbolInfo * ob = new SymbolInfo("5G","Invalid");
        //ob->setName("5G");
        int counter = 1;
        while(1)
        {
            if(curr->getName() == str)
            {
                //cout<<"IN IF"<<endl;
                if(curr->next == nullptr && prev == curr)
                {
                    delete curr;
                    //cout<<"IN IF First"<<endl;
                    cout<< "	Deleted "<<"'"<<str<<"' "<<"from position "<<"<"<<index + 1 <<", 1> of ScopeTable# "<<Id<<endl;
                    p[index] = ob;
                    return true;
                }
                if(curr->next != nullptr && prev == curr)
                {
                    p[index] = p[index]->next;
                    p[index]->next = nullptr;
                    cout<< "	Deleted "<<"'"<<str<<"' "<<"from position "<<"<"<<index<<", "<<counter<<"> of ScopeTable# "<<Id<<endl;
                    return true;
                }
                if(curr->next != nullptr && prev != curr)
                {
                    prev->next = curr->next;
                    curr->next = nullptr;
                    delete curr;
                    cout<< "	Deleted "<<"'"<<str<<"' "<<"from position "<<"<"<<index<<", "<<counter<<"> of ScopeTable# "<<Id<<endl;
                    return true;
                }
                if(curr->next == nullptr && prev != curr)
                {
                    prev->next = nullptr;
                    delete curr;
                    return true;
                }
            }
            else
            {
                if(curr->next == nullptr)
                {
                   // cout<< "	Not found in the current ScopeTable# "<<Id<<endl;
                    return false;
                }
                else
                {
                    counter++;
                    prev = curr;
                    curr = curr->next;
                }
            }
        }
    }
    void Print()
    {
        cout<< "	ScopeTable# "<<Id<<endl;
        for(int i=0; i<size; i++)
        {
            if(p[i] == nullptr || p[i]->getName() == "5G")
            {
                //cout<< "	"<<i+1<<endl;
            }
            else
            {
                cout<< "	"<<i+1<< " --> "<<"("<<p[i]->getName()<<","<<p[i]->gettype()<<")";
                SymbolInfo * itrat = p[i]->next;
                while(itrat != nullptr)
                {
                    if(itrat->func_ret != "")
                    {
                        cout<<" --> "<<"("<<itrat->getName()<<","<<itrat->gettype()<<","<<itrat->func_ret<<")";
                    }
                    else
                    {
                        if(!itrat->is_Array)
                    {
                        cout<<" --> "<<"("<<itrat->getName()<<","<<itrat->gettype()<<")";    
                    }
                        else
                        {
                            cout<<" --> "<<"("<<itrat->getName()<<","<<"Array"<<")";
                        }
                    }
                    
                    itrat = itrat->next;
                }
                cout<<endl;
            }
        }
    }
};



class SymbolTable
{
public:
    ScopeTable * current;
    ScopeTable * ob;
    int ScopetableSize;
    SymbolTable(int n)
    {
        ScopetableSize = n;
        ob = new ScopeTable(n);
        //cout<<ob->size<<endl;
        current = ob;
        //cout<<current->size<<endl;
        current->parentScope = nullptr;
        current->Id = "1";
    }
   /* ~SymbolTable()
    {
        ScopeTable * tmp;
        tmp = current;
        while(tmp != nullptr)
        {
           ScopeTable * t;
           t = tmp;
           tmp = tmp->parentScope;
           delete t;
        }
        //delete ob;
    }*/
    void Enter_scope()
    {
        ScopeTable * temp = new ScopeTable(ScopetableSize);
        current->next = temp;
        temp->parentScope = current;
        current->ChildNumber++;
        string str1 = to_string(current->ChildNumber);
        str1 = "." + str1;
        string str2 = current->Id;
        string str = str2.append(str1);
        current = current->next;
        temp->Id = str;
       // cout<< "	ScopeTable# "<<current->Id<<" created"<<endl;
    }
    void Exit_Scope()
    {
        if(current->Id == "1")
        {
            //cout<< "	ScopeTable# 1 cannot be deleted"<<endl;
        }
        else
        {
            ScopeTable * tmp = current;
            current = current->parentScope;
            current->next = nullptr;
            //cout<< "	ScopeTable# "<<tmp->Id<<" deleted"<<endl;
            delete tmp;
        }
    }
    bool Insert(string name, string type)
    {
        SymbolInfo * ob;
        ob = new SymbolInfo(name,type);
        //cout<<"IN SYMBOL"<<endl;
        //cout<<current->size<<endl;
        return current->Insert(ob);
    }
    bool Insert1(SymbolInfo * ob)
    {
        //SymbolInfo * ob;
        //ob = new SymbolInfo(name,type);
        //cout<<"IN SYMBOL"<<endl;
        //cout<<current->size<<endl;
        return current->Insert(ob);
    }
    bool Remove(string str)
    {
        return current->Delete(str);
    }
    SymbolInfo *  Lookup(string str)
    {
        SymbolInfo * tmp;
        ScopeTable * tmp1 = current;
        while(1)
        {
            tmp = tmp1->Lookup(str);
            if(tmp != nullptr)
            {
                return tmp;
            }
            if(tmp1->parentScope == nullptr)
            {
                //cout<< "	'"<<str<<"'"<<" not found in any of the ScopeTables"<<endl;
                return tmp;
            }
            else
            {
                tmp1 = tmp1->parentScope;
            }
        }
    }
    SymbolInfo * Lookup1(string str)
    {
        SymbolInfo * tmp;
        ScopeTable * tmp1 = current;
        tmp = tmp1->Lookup(str);
        return tmp;
    }
    void Print_current()
    {
        current->Print();
    }
    void Print_All()
    {
        ScopeTable * tmp;
        tmp = current;
        while(tmp != nullptr)
        {
            tmp->Print();
            tmp = tmp->parentScope;
        }
    }
    void Quit()
    {
        ScopeTable * tmp = current;
        while(tmp != nullptr)
        {
          //cout<<"	ScopeTable# "<<tmp->Id<<" deleted"<<endl;
          tmp = tmp->parentScope;
        }
    }
    string get_current_id()
    {
        return current->Id;
    }
    int get_current_total_stack_offset()
    {
        return current->total_stack_offset;
    }
    void set_current_total_stack_offset(int a)
    {
        current->total_stack_offset = a;
    }
};

/*int main()
{
   // freopen("input.txt","r",stdin);
    //freopen("output.txt","w",stdout);
    int number;
    cin>>number;
    SymbolTable ob(number);
    cout<< "	ScopeTable# 1 created";
    string option = "a";
     int cmd = 0;
    while(1)
    {
        if(cmd != 0)
        {
          cout<<"Cmd "<<cmd<<": ";
        }
        string str;
            getline(cin, str);
            cout<<str<<endl;
            char * token = strtok((char *)str.c_str(), " ");
            string s[10];
            int num = 0;
            while (token != NULL)
            {
                s[num] = token;
                num++;
                token = strtok(NULL, " ");
                if(num == 10)
                    break;
            }
        //cin>>option;
        option = s[0];
        if(option == "I")
        {
            if(num != 3)
            {
                cout<< "	Wrong number of arguments for the command I"<<endl;
            }
            else
            {
               string name, type;
            name = s[1];
            type = s[2];
            //cin>>name>>type;
            //SymbolInfo * OB;
            //OB = new SymbolInfo(name,type);
            ob.Insert(name, type);
            }
        }
        if(option == "L")
        {
            if(num != 2)
            {
                cout<< "	Wrong number of arguments for the command L"<<endl;
            }
            else
            {
            string str = s[1];
            //cin>>str;
            ob.Lookup(str);
            }

        }
        if(option == "D")
        {
            if(num != 2)
            {
                cout<< "	Wrong number of arguments for the command D"<<endl;
            }
            else
            {
            string str;
            str = s[1];
            //cin>>str;
            ob.Remove(str);
            }
        }
        if(option == "P")
        {
            string str;
            str = s[1];
            //cin>>str;
            if(str == "A")
            {
                ob.Print_All();
            }
            else if(str == "C")
            {
                ob.Print_current();
            }
            else
            {
                cout<< "	Invalid argument for the command P"<<endl;
            }
        }
        if(option == "S")
        {
            ob.Enter_scope();
        }
        if(option == "E")
        {
            ob.Exit_Scope();
        }
        if(option == "Q")
        {
            ob.Quit();
            return 0;
        }
        cmd++;
    }
    return 0;
}*/