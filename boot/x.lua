function make_environment()return({{}}); end macros=make_environment();scopes=make_environment();symbol_macros=make_environment();is_embed_macros=false;function is_vararg(name)return((sub(name,(length(name)-3),length(name))=="...")); end function bind1(list,value)local forms={};local i=0;local _3=list;while (i<length(_3)) do local x=_3[(i+1)];if is_list(x) then forms=join(forms,bind1(x,{"at",value,i})); elseif is_vararg(x) then local v=sub(x,0,(length(x)-3));push(forms,{"local",v,{"sub",value,i}});break; else push(forms,{"local",x,{"at",value,i}}); end i=(i+1); end return(forms); end target="lua";function length(x)return(#x); end function is_empty(list)return((length(list)==0)); end function sub(x,from,upto)if is_string(x) then return(string.sub(x,(from+1),upto)); else upto=(upto or length(x));local i=from;local j=0;local x2={};while (i<upto) do x2[(j+1)]=x[(i+1)];i=(i+1);j=(j+1); end return(x2); end  end function push(arr,x)return(table.insert(arr,x)); end function pop(arr)return(table.remove(arr)); end function last(arr)return(arr[((length(arr)-1)+1)]); end function join(a1,a2)local a3={};local i=0;local len=length(a1);while (i<len) do a3[(i+1)]=a1[(i+1)];i=(i+1); end while (i<(len+length(a2))) do a3[(i+1)]=a2[((i-len)+1)];i=(i+1); end return(a3); end function reduce(f,x)if is_empty(x) then return(x); elseif (length(x)==1) then return(x[1]); else return(f(x[1],reduce(f,sub(x,1)))); end  end function filter(f,a)local a1={};local _5=0;local _4=a;while (_5<length(_4)) do local x=_4[(_5+1)];if f(x) then push(a1,x); end _5=(_5+1); end return(a1); end function find(f,a)local _7=0;local _6=a;while (_7<length(_6)) do local x=_6[(_7+1)];local x1=f(x);if x1 then return(x1); end _7=(_7+1); end  end function map(f,a)local a1={};local _9=0;local _8=a;while (_9<length(_8)) do local x=_8[(_9+1)];push(a1,f(x));_9=(_9+1); end return(a1); end function collect(f,a)local a1={};local _11=0;local _10=a;while (_11<length(_10)) do local x=_10[(_11+1)];a1=join(a1,f(x));_11=(_11+1); end return(a1); end function getenv(env,k)local i=(length(env)-1);while (i>=0) do local v=env[(i+1)][k];if v then return(v); end i=(i-1); end  end function setenv(env,k,v)last(env)[k]=v; end function pushenv(env)return(push(env,{})); end function popenv(env)return(pop(env)); end function char(str,n)return(sub(str,n,(n+1))); end function search(str,pattern,start)if start then start=(start+1); end local i=string.find(str,pattern,start,true);return((i and (i-1))); end function split(str,sep)local strs={};while true do local i=search(str,sep);if (i==nil) then break; else push(strs,sub(str,0,i));str=sub(str,(i+1)); end  end push(strs,str);return(strs); end function read_file(path)local f=io.open(path);return(f:read("*a")); end function write_file(path,data)local f=io.open(path,"w");return(f:write(data)); end function write(x)return(io.write(x)); end function exit(code)return(os.exit(code)); end function is_string(x)return((type(x)=="string")); end function is_string_literal(x)return((is_string(x) and (char(x,0)=="\""))); end function is_number(x)return((type(x)=="number")); end function is_boolean(x)return((type(x)=="boolean")); end function is_composite(x)return((type(x)=="table")); end function is_atom(x)return((not is_composite(x))); end function is_table(x)return((is_composite(x) and (x[1]==nil))); end function is_list(x)return((is_composite(x) and (not (x[1]==nil)))); end function parse_number(str)return(tonumber(str)); end function to_string(x)if (x==nil) then return("nil"); elseif is_boolean(x) then if x then return("true"); else return("false"); end  elseif is_atom(x) then return((x.."")); elseif is_table(x) then return("#<table>"); else local str="(";local i=0;local _14=x;while (i<length(_14)) do local y=_14[(i+1)];str=(str..to_string(y));if (i<(length(x)-1)) then str=(str.." "); end i=(i+1); end return((str..")")); end  end function apply(f,args)return(f(unpack(args))); end id_counter=0;function make_id(prefix)id_counter=(id_counter+1);return(("_"..(prefix or "")..id_counter)); end eval_result=nil;function eval(x)local y=("eval_result="..x);local f=load(y);if f then f();return(eval_result); else local f,e=load(x);if f then return(f()); else return(error((e.." in "..x))); end  end  end delimiters={["("]=true,[")"]=true,[";"]=true,["\n"]=true};whitespace={[" "]=true,["\t"]=true,["\n"]=true};function make_stream(str)return({pos=0,string=str,len=length(str)}); end function peek_char(s)if (s.pos<s.len) then return(char(s.string,s.pos)); end  end function read_char(s)local c=peek_char(s);if c then s.pos=(s.pos+1);return(c); end  end function skip_non_code(s)while true do local c=peek_char(s);if (not c) then break; elseif whitespace[c] then read_char(s); elseif (c==";") then while (c and (not (c=="\n"))) do c=read_char(s); end skip_non_code(s); else break; end  end  end read_table={};eof={};read_table[""]=function (s)local str="";while true do local c=peek_char(s);if (c and ((not whitespace[c]) and (not delimiters[c]))) then str=(str..c);read_char(s); else break; end  end local n=parse_number(str);if (not (n==nil)) then return(n); elseif (str=="true") then return(true); elseif (str=="false") then return(false); else return(str); end  end ;read_table["("]=function (s)read_char(s);local l={};while true do skip_non_code(s);local c=peek_char(s);if (c and (not (c==")"))) then push(l,read(s)); elseif c then read_char(s);break; else error(("Expected ) at "..s.pos)); end  end return(l); end ;read_table[")"]=function (s)return(error(("Unexpected ) at "..s.pos))); end ;read_table["\""]=function (s)read_char(s);local str="\"";while true do local c=peek_char(s);if (c and (not (c=="\""))) then if (c=="\\") then str=(str..read_char(s)); end str=(str..read_char(s)); elseif c then read_char(s);break; else error(("Expected \" at "..s.pos)); end  end return((str.."\"")); end ;read_table["'"]=function (s)read_char(s);return({"quote",read(s)}); end ;read_table["`"]=function (s)read_char(s);return({"quasiquote",read(s)}); end ;read_table[","]=function (s)read_char(s);if (peek_char(s)=="@") then read_char(s);return({"unquote-splicing",read(s)}); else return({"unquote",read(s)}); end  end ;function read(s)skip_non_code(s);local c=peek_char(s);if c then return(((read_table[c] or read_table[""]))(s)); else return(eof); end  end function read_from_string(str)return(read(make_stream(str))); end operators={common={["+"]="+",["-"]="-",["*"]="*",["/"]="/",["<"]="<",[">"]=">",["="]="==",["<="]="<=",[">="]=">="},js={["and"]="&&",["or"]="||",["cat"]="+"},lua={["and"]=" and ",["or"]=" or ",["cat"]=".."}};function get_op(op)return((operators["common"][op] or operators[target][op])); end function is_operator(form)return((is_list(form) and (not (get_op(form[1])==nil)))); end function get_symbol_macro(form)return(getenv(symbol_macros,form)); end function get_macro(form)return(getenv(macros,form)); end function is_quoting(depth)return(is_number(depth)); end function is_quasiquoting(depth)return((is_quoting(depth) and (depth>0))); end function is_can_unquote(depth)return((is_quoting(depth) and (depth==1))); end function macroexpand(form)if get_symbol_macro(form) then return(macroexpand(get_symbol_macro(form))); elseif is_atom(form) then return(form); else local name=form[1];if (name=="quote") then return(form); elseif (name=="defmacro") then return(form); elseif get_macro(name) then return(macroexpand(apply(get_macro(name),sub(form,1)))); elseif ((name=="lambda") or (name=="each")) then local _=form[1];local args=form[2];local body=sub(form,2);pushenv(scopes);local _22=0;local _21=args;while (_22<length(_21)) do local _20=_21[(_22+1)];setenv(scopes,_20,true);_22=(_22+1); end local _19=join({name,args},macroexpand(body));popenv(scopes);return(_19); elseif (name=="defun") then local _=form[1];local fn=form[2];local args=form[3];local body=sub(form,3);pushenv(scopes);local _26=0;local _25=args;while (_26<length(_25)) do local _24=_25[(_26+1)];setenv(scopes,_24,true);_26=(_26+1); end local _23=join({"defun",fn,args},macroexpand(body));popenv(scopes);return(_23); else return(map(macroexpand,form)); end  end  end function quasiexpand(form,depth)if is_quasiquoting(depth) then if is_atom(form) then return({"quote",form}); elseif (is_can_unquote(depth) and (form[1]=="unquote")) then return(quasiexpand(form[2])); elseif ((form[1]=="unquote") or (form[1]=="unquote-splicing")) then return(quasiquote_list(form,(depth-1))); elseif (form[1]=="quasiquote") then return(quasiquote_list(form,(depth+1))); else return(quasiquote_list(form,depth)); end  elseif is_atom(form) then return(form); elseif (form[1]=="quote") then return({"quote",form[2]}); elseif (form[1]=="quasiquote") then return(quasiexpand(form[2],1)); else return(map(function (x)return(quasiexpand(x,depth)); end ,form)); end  end function quasiquote_list(form,depth)local xs={{"list"}};local _28=0;local _27=form;while (_28<length(_27)) do local x=_27[(_28+1)];if (is_list(x) and is_can_unquote(depth) and (x[1]=="unquote-splicing")) then push(xs,quasiexpand(x[2]));push(xs,{"list"}); else push(last(xs),quasiexpand(x,depth)); end _28=(_28+1); end if (length(xs)==1) then return(xs[1]); else return(reduce(function (a,b)return({"join",a,b}); end ,filter(function (x)return(((length(x)==0) or (not ((length(x)==1) and (x[1]=="list"))))); end ,xs))); end  end function compile_args(forms,is_compile)local str="(";local i=0;local _29=forms;while (i<length(_29)) do local x=_29[(i+1)];local x1=(function ()if is_compile then return(compile(x)); else return(identifier(x)); end  end )();str=(str..x1);if (i<(length(forms)-1)) then str=(str..","); end i=(i+1); end return((str..")")); end function compile_body(forms,is_tail)local str="";local i=0;local _30=forms;while (i<length(_30)) do local x=_30[(i+1)];local is_t=(is_tail and (i==(length(forms)-1)));str=(str..compile(x,true,is_t));i=(i+1); end return(str); end function identifier(id)local id2="";local i=0;while (i<length(id)) do local c=char(id,i);if (c=="-") then c="_"; end id2=(id2..c);i=(i+1); end local last=(length(id)-1);if (char(id,last)=="?") then local name=sub(id2,0,last);id2=("is_"..name); end return(id2); end function compile_atom(form)if (form=="nil") then if (target=="js") then return("undefined"); else return("nil"); end  elseif (is_string(form) and (not is_string_literal(form))) then return(identifier(form)); else return(to_string(form)); end  end function compile_call(form)if (length(form)==0) then return((compiler("list"))(form)); else local fn=form[1];local fn1=compile(fn);local args=compile_args(sub(form,1),true);if is_list(fn) then return(("("..fn1..")"..args)); elseif is_string(fn) then return((fn1..args)); else return(error("Invalid function call")); end  end  end function compile_operator(_32)local op=_32[1];local args=sub(_32,1);local str="(";local op1=get_op(op);local i=0;local _31=args;while (i<length(_31)) do local arg=_31[(i+1)];if ((op1=="-") and (length(args)==1)) then str=(str..op1..compile(arg)); else str=(str..compile(arg));if (i<(length(args)-1)) then str=(str..op1); end  end i=(i+1); end return((str..")")); end function compile_branch(condition,body,is_first,is_last,is_tail)local cond1=compile(condition);local body1=compile(body,true,is_tail);local tr=(function ()if (is_last and (target=="lua")) then return(" end "); else return(""); end  end )();if (is_first and (target=="js")) then return(("if("..cond1.."){"..body1.."}")); elseif is_first then return(("if "..cond1.." then "..body1..tr)); elseif ((condition==nil) and (target=="js")) then return(("else{"..body1.."}")); elseif (condition==nil) then return((" else "..body1.." end ")); elseif (target=="js") then return(("else if("..cond1.."){"..body1.."}")); else return((" elseif "..cond1.." then "..body1..tr)); end  end function bind_arguments(args,body)local args1={};local _34=0;local _33=args;while (_34<length(_33)) do local arg=_33[(_34+1)];if is_vararg(arg) then local v=sub(arg,0,(length(arg)-3));local expr=(function ()if (target=="js") then return({"Array.prototype.slice.call","arguments",length(args1)}); else push(args1,"...");return({"list","..."}); end  end )();body=join({{"local",v,expr}},body);break; elseif is_list(arg) then local v=make_id();push(args1,v);body=macroexpand(join({{"bind",arg,v}},body)); else push(args1,arg); end _34=(_34+1); end return({args1,body}); end function compile_function(args,body,name)name=(name or "");local expanded=bind_arguments(args,body);local args1=compile_args(expanded[1]);local body1=compile_body(expanded[2],true);if (target=="js") then return(("function "..name..args1.."{"..body1.."}")); else return(("function "..name..args1..body1.." end ")); end  end function quote_form(form)if is_atom(form) then if is_string_literal(form) then local str=sub(form,1,(length(form)-1));return(("\"\\\""..str.."\\\"\"")); elseif is_string(form) then return(("\""..form.."\"")); else return(to_string(form)); end  else return((compiler("list"))(form,0)); end  end function compile_special(form,is_stmt,is_tail)local name=form[1];if ((not is_stmt) and is_statement(name)) then return(compile({{"lambda",{},form}},false,is_tail)); else local is_tr=(is_stmt and (not is_self_terminating(name)));local tr=(function ()if is_tr then return(";"); else return(""); end  end )();return(((compiler(name))(sub(form,1),is_tail)..tr)); end  end special={};function is_special(form)return((is_list(form) and (not (special[form[1]]==nil)))); end function compiler(name)return(special[name]["compiler"]); end function is_statement(name)return(special[name]["statement"]); end function is_self_terminating(name)return(special[name]["terminated"]); end special["do"]={compiler=function (forms,is_tail)return(compile_body(forms,is_tail)); end ,statement=true,terminated=true};special["if"]={compiler=function (form,is_tail)local str="";local i=0;local _37=form;while (i<length(_37)) do local condition=_37[(i+1)];local is_last=(i>=(length(form)-2));local is_else=(i==(length(form)-1));local is_first=(i==0);local body=form[((i+1)+1)];if is_else then body=condition;condition=nil; end i=(i+1);str=(str..compile_branch(condition,body,is_first,is_last,is_tail));i=(i+1); end return(str); end ,statement=true,terminated=true};special["while"]={compiler=function (form)local condition=compile(form[1]);local body=compile_body(sub(form,1));if (target=="js") then return(("while("..condition.."){"..body.."}")); else return(("while "..condition.." do "..body.." end ")); end  end ,statement=true,terminated=true};special["defun"]={compiler=function (_38)local name=_38[1];local args=_38[2];local body=sub(_38,2);local id=identifier(name);return(compile_function(args,body,id)); end ,statement=true,terminated=true};embedded_macros="";special["defmacro"]={compiler=function (_39)local name=_39[1];local args=_39[2];local body=sub(_39,2);local macro={"setenv","macros",{"quote",name},join({"lambda",args},body)};eval(compile_for_target("lua",macro,true));if is_embed_macros then embedded_macros=(embedded_macros..compile(macroexpand(macro),true)); end return(""); end ,statement=true,terminated=true};special["return"]={compiler=function (form)return(compile_call(join({"return"},form))); end ,statement=true};special["local"]={compiler=function (_40)local name=_40[1];local value=_40[2];local id=identifier(name);local keyword=(function ()if (target=="js") then return("var "); else return("local "); end  end )();if (value==nil) then return((keyword..id)); else local v=compile(value);return((keyword..id.."="..v)); end  end ,statement=true};special["each"]={compiler=function (_41)local t=_41[1][1];local k=_41[1][2];local v=_41[1][3];local body=sub(_41,1);local t1=compile(t);if (target=="lua") then local body1=compile_body(body);return(("for "..k..","..v.." in pairs("..t1..") do "..body1.." end")); else local body1=compile_body(join({{"set",v,{"get",t,k}}},body));return(("for("..k.." in "..t1.."){"..body1.."}")); end  end ,statement=true};special["set"]={compiler=function (form)if (length(form)<2) then error("Missing right-hand side in assignment"); end local lh=compile(form[1]);local rh=compile(form[2]);return((lh.."="..rh)); end ,statement=true};special["get"]={compiler=function (_42)local object=_42[1];local key=_42[2];local o=compile(object);local k=compile(key);if ((target=="lua") and (char(o,0)=="{")) then o=("("..o..")"); end return((o.."["..k.."]")); end };special["dot"]={compiler=function (_43)local object=_43[1];local key=_43[2];local o=compile(object);local id=identifier(key);return((o.."."..id)); end };special["not"]={compiler=function (_44)local expr=_44[1];local e=compile(expr);local open=(function ()if (target=="js") then return("!("); else return("(not "); end  end )();return((open..e..")")); end };special["list"]={compiler=function (forms,depth)local open=(function ()if (target=="lua") then return("{"); else return("["); end  end )();local close=(function ()if (target=="lua") then return("}"); else return("]"); end  end )();local str="";local i=0;local _45=forms;while (i<length(_45)) do local x=_45[(i+1)];local x1=(function ()if is_quoting(depth) then return(quote_form(x)); else return(compile(x)); end  end )();str=(str..x1);if (i<(length(forms)-1)) then str=(str..","); end i=(i+1); end return((open..str..close)); end };special["table"]={compiler=function (forms)local sep=(function ()if (target=="lua") then return("="); else return(":"); end  end )();local str="{";local i=0;while (i<(length(forms)-1)) do local k=forms[(i+1)];if (not is_string(k)) then error(("Illegal table key: "..to_string(k))); end local v=compile(forms[((i+1)+1)]);if ((target=="lua") and is_string_literal(k)) then k=("["..k.."]"); end str=(str..k..sep..v);if (i<(length(forms)-2)) then str=(str..","); end i=(i+2); end return((str.."}")); end };special["lambda"]={compiler=function (_46)local args=_46[1];local body=sub(_46,1);return(compile_function(args,body)); end };special["quote"]={compiler=function (_47)local form=_47[1];return(quote_form(form)); end };function is_can_return(form)if is_special(form) then return((not is_statement(form[1]))); else return(true); end  end function compile(form,is_stmt,is_tail)local tr=(function ()if is_stmt then return(";"); else return(""); end  end )();if (is_tail and is_can_return(form)) then form={"return",form}; end if (form==nil) then return(""); elseif is_atom(form) then return((compile_atom(form)..tr)); elseif is_operator(form) then return((compile_operator(form)..tr)); elseif is_special(form) then return(compile_special(form,is_stmt,is_tail)); else return((compile_call(form)..tr)); end  end function compile_file(file)local form;local output="";local s=make_stream(read_file(file));while true do form=read(s);if (form==eof) then break; end output=(output..compile(macroexpand(form),true)); end return(output); end function compile_files(files)local output="";local _49=0;local _48=files;while (_49<length(_48)) do local file=_48[(_49+1)];output=(output..compile_file(file));_49=(_49+1); end return(output); end function compile_for_target(target1,form,is_stmt)local previous=target;target=target1;local result=compile(macroexpand(form),is_stmt);target=previous;return(result); end function rep(str)return(print(to_string(eval(compile(read_from_string(str)))))); end function repl()local execute=function (str)rep(str);return(write("> ")); end ;write("> ");while true do local str=io.stdin:read();if str then execute(str); else break; end  end  end function usage()print("usage: x [options] [inputs]");print("options:");print("  -o <output>\tOutput file");print("  -t <target>\tTarget language (default: lua)");print("  -e <expr>\tExpression to evaluate");print("  -m \t\tEmbed macro definitions in output");return(exit()); end function main()args=arg;if ((args[1]=="-h") or (args[1]=="--help")) then usage(); end local inputs={};local output=nil;local target1=nil;local expr=nil;local i=0;local _50=args;while (i<length(_50)) do local arg=_50[(i+1)];if ((arg=="-o") or (arg=="-t") or (arg=="-e")) then if (i==(length(args)-1)) then print("missing argument for",arg); else i=(i+1);local arg2=args[(i+1)];if (arg=="-o") then output=arg2; elseif (arg=="-t") then target1=arg2; elseif (arg=="-e") then expr=arg2; end  end  elseif (arg=="-m") then is_embed_macros=true; elseif ("-"==sub(arg,0,1)) then print("unrecognized option:",arg);usage(); else push(inputs,arg); end i=(i+1); end if output then if target1 then target=target1; end local compiled=compile_files(inputs);local main=compile({"main"},true);return(write_file(output,(compiled..embedded_macros..main))); else local _52=0;local _51=inputs;while (_52<length(_51)) do local file=_51[(_52+1)];eval(compile_file(file));_52=(_52+1); end if expr then return(rep(expr)); else return(repl()); end  end  end setenv(macros,"at",function (arr,i)if ((target=="lua") and is_number(i)) then i=(i+1); elseif (target=="lua") then i={"+",i,1}; end return({"get",arr,i}); end );setenv(macros,"let",function (bindings,...)local body={...};local renames={};local scope=last(scopes);local i=0;local locals={};while (i<length(bindings)) do local id=bindings[(i+1)];if scope[id] then local rename=make_id();push(renames,{id,rename});id=rename; else scope[id]=true; end push(locals,{"local",id,bindings[((i+1)+1)]});i=(i+2); end return(join({"symbol-macrolet",renames},join(locals,body))); end );setenv(macros,"macrolet",function (definitions,...)local body={...};pushenv(macros);local is_embed=is_embed_macros;is_embed_macros=false;map(function (macro)return((compiler("defmacro"))(macro)); end ,definitions);is_embed_macros=is_embed;local body1=macroexpand(body);popenv(macros);return(join({"do"},body1)); end );setenv(macros,"symbol-macrolet",function (expansions,...)local body={...};pushenv(symbol_macros);map(function (pair)return(setenv(symbol_macros,pair[1],pair[2])); end ,expansions);local body1=macroexpand(body);popenv(symbol_macros);return(join({"do"},body1)); end );setenv(macros,"define-symbol-macro",function (name,expansion)setenv(symbol_macros,name,expansion);return(nil); end );setenv(macros,"defvar",function (name,value)return({"set",name,value}); end );setenv(macros,"bind",function (list,value)if is_list(value) then local v=make_id();return(join({"do",{"local",v,value}},bind1(list,value))); else return(join({"do"},bind1(list,value))); end  end );setenv(macros,"across",function (_2,...)local body={...};local list=_2[1];local v=_2[2];local i=_2[3];local start=_2[4];local l=make_id();i=(i or make_id());start=(start or 0);return({"do",{"local",i,start},{"local",l,list},join({"while",{"<",i,{"length",l}},{"local",v,{"at",l,i}}},join(body,{{"set",i,{"+",i,1}}}))}); end );setenv(macros,"make-set",function (...)local elements={...};return(join({"table"},collect(function (x)return({x,true}); end ,elements))); end );setenv(macros,"language",function ()return({"quote",target}); end );setenv(macros,"target",function (...)local clauses={...};return(find(function (x)if (x[1]==target) then return(x[2]); end  end ,clauses)); end );setenv(macros,"join*",function (...)local xs={...};return(reduce(function (a,b)return({"join",a,b}); end ,xs)); end );setenv(macros,"list*",function (...)local xs={...};if (length(xs)==0) then return({}); else local t={};local i=0;local _13=xs;while (i<length(_13)) do local x=_13[(i+1)];if (i==(length(xs)-1)) then t={"join",join({"list"},t),x}; else push(t,x); end i=(i+1); end return(t); end  end );setenv(macros,"cat!",function (a,...)local bs={...};return({"set",a,join({"cat",a},bs)}); end );setenv(macros,"define-reader",function (_16,...)local body={...};local char=_16[1];local stream=_16[2];return({"set",{"get","read-table",char},join({"lambda",{stream}},body)}); end );setenv(macros,"with-scope",function (_18,expr)local bound=_18[1];local result=make_id();local arg=make_id();return({"do",{"pushenv","scopes"},{"across",{bound,arg},{"setenv","scopes",arg,true}},{"local",result,expr},{"popenv","scopes"},result}); end );setenv(macros,"quasiquote",function (form)return(quasiexpand(form,1)); end );setenv(macros,"define-compiler",function (name,_36,args,...)local body={...};local keys=sub(_36,0);return({"set",{"get","special",{"quote",name}},join({"table","compiler",join({"lambda",args},body)},collect(function (k)return({k,true}); end ,keys))}); end );main();