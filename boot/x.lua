environment={{}};function getenv(k)local i=(length(environment)-1);while (i>=0) do local v=environment[(i+1)][k];if v then return(v); end i=(i-1); end  end variable={};function is_symbol_macro(k)local v=getenv(k);return((is_is(v) and (not (v==variable)) and (not is_macro(k)))); end function is_macro(k)return(is_function(getenv(k))); end function is_variable(k)return((last(environment)[k]==variable)); end function is_bound(x)return((is_symbol_macro(x) or is_macro(x) or is_variable(x))); end is_embed_macros=false;function is_vararg(x)return(((length(x)>3) and (sub(x,(length(x)-3),length(x))=="..."))); end function vararg_name(x)return(sub(x,0,(length(x)-3))); end function bind_arguments(args,body)local args1={};local bindings={};local _16=0;local _15=args;while (_16<length(_15)) do local arg=_15[(_16+1)];if is_vararg(arg) then local v=vararg_name(arg);local expr=(function ()if (target=="js") then return({"Array.prototype.slice.call","arguments",length(args1)}); else push(args1,"...");return({"list","..."}); end  end )();bindings=join(bindings,{v,expr});break; elseif is_list(arg) then local _17=make_id();push(args1,_17);bindings=join(bindings,{arg,_17}); else push(args1,arg); end _16=(_16+1); end if is_empty(bindings) then return({args1,body}); else return({args1,{join({"let",bindings},body)}}); end  end function bind(lh,rh)if (is_list(lh) and is_list(rh)) then local id=make_id();return(join({{id,rh}},bind(lh,id))); elseif is_atom(lh) then return({{lh,rh}}); else local bindings={};local i=0;local _18=lh;while (i<length(_18)) do local x=_18[(i+1)];local b=(function ()if is_vararg(x) then return({{vararg_name(x),{"sub",rh,i}}}); else return(bind(x,{"at",rh,i})); end  end )();bindings=join(bindings,b);i=(i+1); end return(bindings); end  end target="lua";function length(x)return(#x); end function is_empty(list)return((length(list)==0)); end function sub(x,from,upto)if is_string(x) then return(string.sub(x,(from+1),upto)); else upto=(upto or length(x));local i=from;local j=0;local x2={};while (i<upto) do x2[(j+1)]=x[(i+1)];i=(i+1);j=(j+1); end return(x2); end  end function push(arr,x)return(table.insert(arr,x)); end function pop(arr)return(table.remove(arr)); end function last(arr)return(arr[((length(arr)-1)+1)]); end function join(a1,a2)local i=0;local len=length(a1);local a3={};while (i<len) do a3[(i+1)]=a1[(i+1)];i=(i+1); end while (i<(len+length(a2))) do a3[(i+1)]=a2[((i-len)+1)];i=(i+1); end return(a3); end function reduce(f,x)if is_empty(x) then return(x); elseif (length(x)==1) then return(x[1]); else return(f(x[1],reduce(f,sub(x,1)))); end  end function keep(f,a)local a1={};local _20=0;local _19=a;while (_20<length(_19)) do local x=_19[(_20+1)];if f(x) then push(a1,x); end _20=(_20+1); end return(a1); end function find(f,a)local _22=0;local _21=a;while (_22<length(_21)) do local x=_21[(_22+1)];local x1=f(x);if x1 then return(x1); end _22=(_22+1); end  end function map(f,a)local a1={};local _24=0;local _23=a;while (_24<length(_23)) do local x=_23[(_24+1)];push(a1,f(x));_24=(_24+1); end return(a1); end function collect(f,a)local a1={};local _26=0;local _25=a;while (_26<length(_25)) do local x=_25[(_26+1)];a1=join(a1,f(x));_26=(_26+1); end return(a1); end function char(str,n)return(sub(str,n,(n+1))); end function search(str,pattern,start)if start then start=(start+1); end local i=string.find(str,pattern,start,true);return((i and (i-1))); end function split(str,sep)local strs={};while true do local i=search(str,sep);if is_nil(i) then break; else push(strs,sub(str,0,i));str=sub(str,(i+1)); end  end push(strs,str);return(strs); end function read_file(path)local f=io.open(path);return(f:read("*a")); end function write_file(path,data)local f=io.open(path,"w");return(f:write(data)); end function write(x)return(io.write(x)); end function exit(code)return(os.exit(code)); end function is_nil(x)return((x==nil)); end function is_is(x)return((not is_nil(x))); end function is_string(x)return((type(x)=="string")); end function is_string_literal(x)return((is_string(x) and (char(x,0)=="\""))); end function is_number(x)return((type(x)=="number")); end function is_boolean(x)return((type(x)=="boolean")); end function is_function(x)return((type(x)=="function")); end function is_composite(x)return((type(x)=="table")); end function is_atom(x)return((not is_composite(x))); end function is_table(x)return((is_composite(x) and is_nil(x[1]))); end function is_list(x)return((is_composite(x) and is_is(x[1]))); end function parse_number(str)return(tonumber(str)); end function to_string(x)if is_nil(x) then return("nil"); elseif is_boolean(x) then if x then return("true"); else return("false"); end  elseif is_atom(x) then return((x.."")); elseif is_function(x) then return("#<function>"); elseif is_table(x) then return("#<table>"); else local str="(";local i=0;local _29=x;while (i<length(_29)) do local y=_29[(i+1)];str=(str..to_string(y));if (i<(length(x)-1)) then str=(str.." "); end i=(i+1); end return((str..")")); end  end function apply(f,args)return(f(unpack(args))); end id_counter=0;function make_id(prefix)id_counter=(id_counter+1);return(("_"..(prefix or "")..id_counter)); end eval_result=nil;function eval(x)local y=("eval_result="..x);local f=load(y);if f then f();return(eval_result); else local f,e=load(x);if f then return(f()); else return(error((e.." in "..x))); end  end  end delimiters={["("]=true,[")"]=true,[";"]=true,["\n"]=true};whitespace={[" "]=true,["\t"]=true,["\n"]=true};function make_stream(str)return({pos=0,string=str,len=length(str)}); end function peek_char(s)if (s.pos<s.len) then return(char(s.string,s.pos)); end  end function read_char(s)local c=peek_char(s);if c then s.pos=(s.pos+1);return(c); end  end function skip_non_code(s)while true do local c=peek_char(s);if is_nil(c) then break; elseif whitespace[c] then read_char(s); elseif (c==";") then while (c and (not (c=="\n"))) do c=read_char(s); end skip_non_code(s); else break; end  end  end read_table={};eof={};read_table[""]=function (s)local str="";while true do local c=peek_char(s);if (c and ((not whitespace[c]) and (not delimiters[c]))) then str=(str..c);read_char(s); else break; end  end local n=parse_number(str);if is_is(n) then return(n); elseif (str=="true") then return(true); elseif (str=="false") then return(false); else return(str); end  end ;read_table["("]=function (s)read_char(s);local l={};while true do skip_non_code(s);local c=peek_char(s);if (c and (not (c==")"))) then push(l,read(s)); elseif c then read_char(s);break; else error(("Expected ) at "..s.pos)); end  end return(l); end ;read_table[")"]=function (s)return(error(("Unexpected ) at "..s.pos))); end ;read_table["\""]=function (s)read_char(s);local str="\"";while true do local c=peek_char(s);if (c and (not (c=="\""))) then if (c=="\\") then str=(str..read_char(s)); end str=(str..read_char(s)); elseif c then read_char(s);break; else error(("Expected \" at "..s.pos)); end  end return((str.."\"")); end ;read_table["'"]=function (s)read_char(s);return({"quote",read(s)}); end ;read_table["`"]=function (s)read_char(s);return({"quasiquote",read(s)}); end ;read_table[","]=function (s)read_char(s);if (peek_char(s)=="@") then read_char(s);return({"unquote-splicing",read(s)}); else return({"unquote",read(s)}); end  end ;function read(s)skip_non_code(s);local c=peek_char(s);if is_is(c) then return(((read_table[c] or read_table[""]))(s)); else return(eof); end  end function read_from_string(str)return(read(make_stream(str))); end operators={common={["+"]="+",["-"]="-",["*"]="*",["/"]="/",["<"]="<",[">"]=">",["="]="==",["<="]="<=",[">="]=">="},js={["~="]="!=",["and"]="&&",["or"]="||",["cat"]="+"},lua={["~="]="~=",["and"]=" and ",["or"]=" or ",["cat"]=".."}};function getop(op)return((operators["common"][op] or operators[target][op])); end function is_operator(form)return((is_list(form) and is_is(getop(form[1])))); end function is_quoting(depth)return(is_number(depth)); end function is_quasiquoting(depth)return((is_quoting(depth) and (depth>0))); end function is_can_unquote(depth)return((is_quoting(depth) and (depth==1))); end function macroexpand(form)if is_symbol_macro(form) then return(macroexpand(getenv(form))); elseif is_atom(form) then return(form); else local name=form[1];if (name=="quote") then return(form); elseif (name=="macro") then return(form); elseif is_macro(name) then return(macroexpand(apply(getenv(name),sub(form,1)))); elseif ((name=="function") or (name=="each")) then local _=form[1];local args=form[2];local body=sub(form,2);push(environment,{});local _37=0;local _36=args;while (_37<length(_36)) do local _35=_36[(_37+1)];last(environment)[_35]=variable;_37=(_37+1); end local _34=join({name,args},macroexpand(body));pop(environment);return(_34); elseif (name=="function-definition") then local _38=form[1];local f=form[2];local _39=form[3];local _40=sub(form,3);push(environment,{});local _44=0;local _43=_39;while (_44<length(_43)) do local _42=_43[(_44+1)];last(environment)[_42]=variable;_44=(_44+1); end local _41=join({name,f,_39},macroexpand(_40));pop(environment);return(_41); else return(map(macroexpand,form)); end  end  end function quasiexpand(form,depth)if is_quasiquoting(depth) then if is_atom(form) then return({"quote",form}); elseif (is_can_unquote(depth) and (form[1]=="unquote")) then return(quasiexpand(form[2])); elseif ((form[1]=="unquote") or (form[1]=="unquote-splicing")) then return(quasiquote_list(form,(depth-1))); elseif (form[1]=="quasiquote") then return(quasiquote_list(form,(depth+1))); else return(quasiquote_list(form,depth)); end  elseif is_atom(form) then return(form); elseif (form[1]=="quote") then return({"quote",form[2]}); elseif (form[1]=="quasiquote") then return(quasiexpand(form[2],1)); else return(map(function (x)return(quasiexpand(x,depth)); end ,form)); end  end function quasiquote_list(form,depth)local xs={{"list"}};local _46=0;local _45=form;while (_46<length(_45)) do local x=_45[(_46+1)];if (is_list(x) and is_can_unquote(depth) and (x[1]=="unquote-splicing")) then push(xs,quasiexpand(x[2]));push(xs,{"list"}); else push(last(xs),quasiexpand(x,depth)); end _46=(_46+1); end if (length(xs)==1) then return(xs[1]); else return(reduce(function (a,b)return({"join",a,b}); end ,keep(function (x)return(((length(x)==0) or (not ((length(x)==1) and (x[1]=="list"))))); end ,xs))); end  end function compile_args(forms,is_compile)local str="(";local i=0;local _47=forms;while (i<length(_47)) do local x=_47[(i+1)];str=(str..(function ()if is_compile then return(compile(x)); else return(identifier(x)); end  end )());if (i<(length(forms)-1)) then str=(str..","); end i=(i+1); end return((str..")")); end function compile_body(forms,is_tail)local str="";local i=0;local _48=forms;while (i<length(_48)) do local x=_48[(i+1)];local is_t=(is_tail and (i==(length(forms)-1)));str=(str..compile(x,true,is_t));i=(i+1); end return(str); end function identifier(id)local id2="";local i=0;while (i<length(id)) do local c=char(id,i);if (c=="-") then c="_"; end id2=(id2..c);i=(i+1); end local last=(length(id)-1);if (char(id,last)=="?") then local name=sub(id2,0,last);id2=("is_"..name); end return(id2); end function compile_atom(form)if (form=="nil") then if (target=="js") then return("undefined"); else return("nil"); end  elseif (is_string(form) and (not is_string_literal(form))) then return(identifier(form)); else return(to_string(form)); end  end function compile_call(form)if (length(form)==0) then return((compiler("list"))(form)); else local f=form[1];local f1=compile(f);local args=compile_args(sub(form,1),true);if is_list(f) then return(("("..f1..")"..args)); elseif is_string(f) then return((f1..args)); else return(error("Invalid function call")); end  end  end function compile_operator(_49)local op=_49[1];local args=sub(_49,1);local str="(";local op1=getop(op);local i=0;local _50=args;while (i<length(_50)) do local arg=_50[(i+1)];if ((op1=="-") and (length(args)==1)) then str=(str..op1..compile(arg)); else str=(str..compile(arg));if (i<(length(args)-1)) then str=(str..op1); end  end i=(i+1); end return((str..")")); end function compile_branch(condition,body,is_first,is_last,is_tail)local cond1=compile(condition);local body1=compile(body,true,is_tail);local tr=(function ()if (is_last and (target=="lua")) then return(" end "); else return(""); end  end )();if (is_first and (target=="js")) then return(("if("..cond1.."){"..body1.."}")); elseif is_first then return(("if "..cond1.." then "..body1..tr)); elseif (is_nil(condition) and (target=="js")) then return(("else{"..body1.."}")); elseif is_nil(condition) then return((" else "..body1.." end ")); elseif (target=="js") then return(("else if("..cond1.."){"..body1.."}")); else return((" elseif "..cond1.." then "..body1..tr)); end  end function compile_function(args,body,name,is_local)name=(name or "");local args1=compile_args(args);local body1=compile_body(body,true);if (target=="js") then return(("function "..name..args1.."{"..body1.."}")); else local pre=(function ()if is_local then return("local "); else return(""); end  end )();return((pre.."function "..name..args1..body1.." end ")); end  end function quote_form(form)if is_atom(form) then if is_string_literal(form) then local str=sub(form,1,(length(form)-1));return(("\"\\\""..str.."\\\"\"")); elseif is_string(form) then return(("\""..form.."\"")); else return(to_string(form)); end  else return((compiler("list"))(form,0)); end  end function compile_special(form,is_stmt,is_tail,is_toplevel)local name=form[1];if ((not is_stmt) and is_statement(name)) then return(compile({{"function",{},form}},false,is_tail)); else local is_tr=(is_stmt and (not is_self_terminating(name)));local tr=(function ()if is_tr then return(";"); else return(""); end  end )();return(((compiler(name))(sub(form,1),is_tail,is_toplevel)..tr)); end  end special={};function is_special(form)return((is_list(form) and is_is(special[form[1]]))); end function compiler(name)return(special[name]["compiler"]); end function is_statement(name)return(special[name]["statement"]); end function is_self_terminating(name)return(special[name]["terminated"]); end special["do"]={compiler=function (forms,is_tail)return(compile_body(forms,is_tail)); end ,statement=true,terminated=true};special["if"]={compiler=function (form,is_tail)local str="";local i=0;local _53=form;while (i<length(_53)) do local condition=_53[(i+1)];local is_last=(i>=(length(form)-2));local is_else=(i==(length(form)-1));local is_first=(i==0);local body=form[((i+1)+1)];if is_else then body=condition;condition=nil; end str=(str..compile_branch(condition,body,is_first,is_last,is_tail));i=(i+1);i=(i+1); end return(str); end ,statement=true,terminated=true};special["while"]={compiler=function (form)local condition=compile(form[1]);local body=compile_body(sub(form,1));if (target=="js") then return(("while("..condition.."){"..body.."}")); else return(("while "..condition.." do "..body.." end ")); end  end ,statement=true,terminated=true};special["function"]={compiler=function (_54)local args=_54[1];local body=sub(_54,1);return(compile_function(args,body)); end };special["function-definition"]={compiler=function (_55,_,is_toplevel)local name=_55[1];local args=_55[2];local body=sub(_55,2);return(compile_function(args,body,identifier(name),(not is_toplevel))); end ,statement=true,terminated=true};macros="";special["macro"]={compiler=function (_56)local name=_56[1];local args=_56[2];local body=sub(_56,2);local macro={"setenv!",{"quote",name},join({"fn",args},body)};eval(compile_for_target("lua",macro));if is_embed_macros then macros=(macros..compile_toplevel(macro)); end return(""); end ,statement=true,terminated=true};special["return"]={compiler=function (form)return(compile_call(join({"return"},form))); end ,statement=true};special["local"]={compiler=function (_57)local name=_57[1];local value=_57[2];local id=identifier(name);local keyword=(function ()if (target=="js") then return("var "); else return("local "); end  end )();if is_nil(value) then return((keyword..id)); else return((keyword..id.."="..compile(value))); end  end ,statement=true};special["each"]={compiler=function (_58)local _59=_58[1];local t=_59[1];local k=_59[2];local v=_59[3];local body=sub(_58,1);local t1=compile(t);if (target=="lua") then local body1=compile_body(body);return(("for "..k..","..v.." in pairs("..t1..") do "..body1.." end")); else local _60=compile_body(join({{"set!",v,{"get",t,k}}},body));return(("for("..k.." in "..t1.."){".._60.."}")); end  end ,statement=true};special["set!"]={compiler=function (_61)local lh=_61[1];local rh=_61[2];if is_nil(rh) then error("Missing right-hand side in assignment"); end return((compile(lh).."="..compile(rh))); end ,statement=true};special["get"]={compiler=function (_62)local object=_62[1];local key=_62[2];local o=compile(object);local k=compile(key);if ((target=="lua") and (char(o,0)=="{")) then o=("("..o..")"); end return((o.."["..k.."]")); end };special["dot"]={compiler=function (_63)local object=_63[1];local key=_63[2];return((compile(object).."."..identifier(key))); end };special["not"]={compiler=function (_64)local expr=_64[1];local e=compile(expr);local open=(function ()if (target=="js") then return("!("); else return("(not "); end  end )();return((open..e..")")); end };special["list"]={compiler=function (forms,depth)local open=(function ()if (target=="lua") then return("{"); else return("["); end  end )();local close=(function ()if (target=="lua") then return("}"); else return("]"); end  end )();local str="";local i=0;local _65=forms;while (i<length(_65)) do local x=_65[(i+1)];str=(str..(function ()if is_quoting(depth) then return(quote_form(x)); else return(compile(x)); end  end )());if (i<(length(forms)-1)) then str=(str..","); end i=(i+1); end return((open..str..close)); end };special["table"]={compiler=function (forms)local sep=(function ()if (target=="lua") then return("="); else return(":"); end  end )();local str="{";local i=0;while (i<(length(forms)-1)) do local k=forms[(i+1)];local v=compile(forms[((i+1)+1)]);if (not is_string(k)) then error(("Illegal table key: "..to_string(k))); end if ((target=="lua") and is_string_literal(k)) then k=("["..k.."]"); end str=(str..k..sep..v);if (i<(length(forms)-2)) then str=(str..","); end i=(i+2); end return((str.."}")); end };special["quote"]={compiler=function (_66)local form=_66[1];return(quote_form(form)); end };function is_can_return(form)if is_special(form) then return((not is_statement(form[1]))); else return(true); end  end function compile(form,is_stmt,is_tail,is_toplevel)local tr=(function ()if is_stmt then return(";"); else return(""); end  end )();if (is_tail and is_can_return(form)) then form={"return",form}; end if is_nil(form) then return(""); elseif is_atom(form) then return((compile_atom(form)..tr)); elseif is_operator(form) then return((compile_operator(form)..tr)); elseif is_special(form) then return(compile_special(form,is_stmt,is_tail,is_toplevel)); else return((compile_call(form)..tr)); end  end function compile_file(file)local form=nil;local output="";local s=make_stream(read_file(file));while true do form=read(s);if (form==eof) then break; end local result=compile_toplevel(form);output=(output..result); end return(output); end function compile_files(files)local output="";local _68=0;local _67=files;while (_68<length(_67)) do local file=_67[(_68+1)];output=(output..compile_file(file));_68=(_68+1); end return(output); end function compile_toplevel(form)return(compile(macroexpand(form),true,false,true)); end function compile_for_target(target1,form)local previous=target;target=target1;local result=compile_toplevel(form);target=previous;return(result); end function rep(str)return(print((to_string(eval(compile_toplevel(read_from_string(str))))))); end function repl()local execute=function (str)rep(str);return(write("> ")); end ;write("> ");while true do local str=io.stdin:read();if str then execute(str); else break; end  end  end function usage()print((to_string("usage: x [options] [inputs]")));print((to_string("options:")));print((to_string("  -o <output>\tOutput file")));print((to_string("  -t <target>\tTarget language (default: lua)")));print((to_string("  -e <expr>\tExpression to evaluate")));print((to_string("  -m \t\tEmbed macro definitions in output")));return(exit()); end function main()args=arg;if ((args[1]=="-h") or (args[1]=="--help")) then usage(); end local inputs={};local output=nil;local target1=nil;local expr=nil;local i=0;local _69=args;while (i<length(_69)) do local arg=_69[(i+1)];if ((arg=="-o") or (arg=="-t") or (arg=="-e")) then if (i==(length(args)-1)) then print((to_string("missing argument for")..to_string(arg))); else i=(i+1);local arg2=args[(i+1)];if (arg=="-o") then output=arg2; elseif (arg=="-t") then target1=arg2; elseif (arg=="-e") then expr=arg2; end  end  elseif (arg=="-m") then is_embed_macros=true; elseif ("-"==sub(arg,0,1)) then print((to_string("unrecognized option:")..to_string(arg)));usage(); else push(inputs,arg); end i=(i+1); end if output then if target1 then target=target1; end local compiled=compile_files(inputs);local main=compile({"main"},true);return(write_file(output,(compiled..macros..main))); else local _71=0;local _70=inputs;while (_71<length(_70)) do local file=_70[(_71+1)];eval(compile_file(file));_71=(_71+1); end if expr then return(rep(expr)); else return(repl()); end  end  end last(environment)["setenv!"]=function (k,v)return({"set!",{"get",{"last","environment"},k},v}); end ;last(environment)["at"]=function (arr,i)if ((target=="lua") and is_number(i)) then i=(i+1); elseif (target=="lua") then i={"+",i,1}; end return({"get",arr,i}); end ;last(environment)["let"]=function (bindings,...)local body={...};local i=0;local renames={};local locals={};local bindings1={};while (i<length(bindings)) do local lh=bindings[(i+1)];local rh=bindings[((i+1)+1)];bindings1=join(bindings1,bind(lh,rh));i=(i+2); end local _5=0;local _4=bindings1;while (_5<length(_4)) do local _6=_4[(_5+1)];local id=_6[1];local rh=_6[2];if is_bound(id) then local rename=make_id();push(renames,{id,rename});id=rename; else last(environment)[id]=variable; end push(locals,{"local",id,rh});_5=(_5+1); end return(join({"let-symbol",renames},join(locals,body))); end ;last(environment)["let-macro"]=function (definitions,...)local body={...};push(environment,{});local is_embed=is_embed_macros;is_embed_macros=false;map(function (m)return((compiler("macro"))(m)); end ,definitions);is_embed_macros=is_embed;local body1=macroexpand(body);pop(environment);return(join({"do"},body1)); end ;last(environment)["let-symbol"]=function (expansions,...)local body={...};push(environment,{});map(function (_8)local name=_8[1];local expr=_8[2];last(environment)[name]=expr; end ,expansions);local body1=macroexpand(body);pop(environment);return(join({"do"},body1)); end ;last(environment)["symbol"]=function (name,expansion)last(environment)[name]=expansion;return(nil); end ;last(environment)["global"]=function (name,value)return({"set!",name,value}); end ;last(environment)["define"]=function (name,x,...)local body={...};if is_empty(body) then return({"local",name,x}); else local _10=bind_arguments(x,body);local args=_10[1];local body1=_10[2];return(join({"function-definition",name,args},body1)); end  end ;last(environment)["fn"]=function (args,...)local body={...};local _12=bind_arguments(args,body);local args1=_12[1];local body1=_12[2];return(join({"function",args1},body1)); end ;last(environment)["across"]=function (_14,...)local list=_14[1];local v=_14[2];local i=_14[3];local start=_14[4];local body={...};local l=make_id();i=(i or make_id());start=(start or 0);return({"let",{i,start,l,list},{"while",{"<",i,{"length",l}},join({"let",{v,{"at",l,i}}},join(body,{{"set!",i,{"+",i,1}}}))}}); end ;last(environment)["set"]=function (...)local elements={...};return(join({"table"},collect(function (x)return({x,true}); end ,elements))); end ;last(environment)["language"]=function ()return({"quote",target}); end ;last(environment)["target"]=function (...)local clauses={...};return(find(function (x)if (x[1]==target) then return(x[2]); end  end ,clauses)); end ;last(environment)["join*"]=function (...)local xs={...};return(reduce(function (a,b)return({"join",a,b}); end ,xs)); end ;last(environment)["join!"]=function (a,...)local bs={...};return({"set!",a,join({"join*",a},bs)}); end ;last(environment)["list*"]=function (...)local xs={...};if (length(xs)==0) then return({}); else local t={};local i=0;local _28=xs;while (i<length(_28)) do local x=_28[(i+1)];if (i==(length(xs)-1)) then t={"join",join({"list"},t),x}; else push(t,x); end i=(i+1); end return(t); end  end ;last(environment)["cat!"]=function (a,...)local bs={...};return({"set!",a,join({"cat",a},bs)}); end ;last(environment)["pr"]=function (...)local xs={...};return({"print",join({"cat"},map(function (x)return({"to-string",x}); end ,xs))}); end ;last(environment)["define-reader"]=function (_31,...)local char=_31[1];local stream=_31[2];local body={...};return({"global",{"get","read-table",char},join({"fn",{stream}},body)}); end ;last(environment)["w/scope"]=function (_33,expr)local bound=_33[1];local result=make_id();local arg=make_id();return({"do",{"push","environment",{"table"}},{"across",{bound,arg},{"setenv!",arg,"variable"}},{"let",{result,expr},{"pop","environment"},result}}); end ;last(environment)["quasiquote"]=function (form)return(quasiexpand(form,1)); end ;last(environment)["define-compiler"]=function (name,_52,args,...)local keys=sub(_52,0);local body={...};return({"set!",{"get","special",{"quote",name}},join({"table","compiler",join({"fn",args},body)},collect(function (k)return({k,true}); end ,keys))}); end ;main();