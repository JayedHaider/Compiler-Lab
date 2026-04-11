#pragma once
#include<bits/stdc++.h>

using namespace std;

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
    }
    SymbolInfo()
    {
        name = "5G";
        type = "Empty";
        next = nullptr;
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
    }
    ~ScopeTable()
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
           /*while(tmp != nullptr)
           {
               SymbolInfo * t = tmp;
               tmp = tmp->
           }*/
       }
       delete p;
    }
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
    ~SymbolTable()
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
    }
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