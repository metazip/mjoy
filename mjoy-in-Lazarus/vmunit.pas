unit vmunit;

{$mode ObjFPC}{$H+}

//maxstack im linker ?
interface

uses Classes,
     SysUtils,//exception
     //,
     typeunit;

type boolset = array [0..255] of boolean;

var //idquote: cardinal = xnil;
    //idbottom: cardinal = xnil;
    quotenext: boolean = false;
    joyformatsettings: tformatsettings;

procedure precom(var txt: ustring);
procedure postcom(redef: boolean);
procedure run;
function tosequence(i: cardinal): ustring;
function tovalue(i: cardinal): ustring;
procedure xreversey;
procedure eval;
procedure initvm(mc: int64);
procedure finalvm;

implementation

uses apiunit,primunit;

const specialset: ansistring = '()[]{}"'+qot;

var special: boolset;

// --------------------------- List-to-Text Ausgabe ----------------------------

//function tovalue(...   nein!
const joyformat = ffGeneral;
      maxdigits = 16;
      maxpdigits = 15;

function tofloat(num: double): ustring;
begin tofloat:=stringreplace(
               floattostrF(num,joyformat,maxdigits,maxpdigits,joyformatsettings),
               ',','.',[rfReplaceAll])
end;

//vergleichen!
function tostring(var i: cardinal): ustring;
var s: ustring; k,obj: cardinal;
begin s:='';
      k:=i;
      while (typeof[i]<>xnull) do begin//xnil
            obj:=cell[i].addr;
            if (typeof[obj]<>xchar) then break;
            s:=s+cell[obj].ch;
            k:=i;
            i:=cell[i].decr
      end;
      i:=k;
      tostring:=ansiquotedstr(s,'"')
      //
end;

var topobj: cardinal;

function tosequence(i: cardinal): ustring;
var s: ustring;
    sp: ustring;//[1];//gloabal deklarieren?
begin s:='';
      sp:='';
      while (typeof[i]=xcons) do begin
            topobj:=cell[i].addr;
            case typeof[topobj] of
                 xnull : s:=s + sp + '[]';
                 xident: s:=s + sp + cell[cell[topobj].pname].pstr^;
                 xint  : s:=s+sp+'('+inttostr(cell[topobj].inum)+')';
                 xfloat: s:=s + sp + tofloat(cell[topobj].fnum);
                 xcons : s:=s + sp + '['+tosequence(topobj)+']';
                 xchar : s:=s+sp+tostring(i);// i modifier;
                 xstring:s:=s + sp + '('+ansiquotedstr(cell[topobj].pstr^,'"')+')';
            else s:=s+sp+'(...)'
            end;
            sp:=' ';
            i:=cell[i].decr
      end;
      if (typeof[i]=xnull) then tosequence:=s //xnil
      else tosequence:='(...s)'
end;

//function tovalue(i: cardinal): string;
function tovalue(i: cardinal): ustring;
begin case typeof[i] of
           xnull : tovalue:='[]';
           xcons : tovalue:='['+tosequence(i)+']';
           xident: tovalue:=cell[cell[i].pname].pstr^;
           xint  : tovalue:='('+inttostr(cell[i].inum)+')';
           xfloat: tovalue:=tofloat(cell[i].fnum);
           xchar : tovalue:=ansiquotedstr(cell[i].ch,'"');
           xstring: tovalue:='('+ansiquotedstr(cell[i].pstr^,'"')+')';
      else tovalue:='(...v)'
      end
end;

// ------------------------------ Scanner --------------------------------------

function isspecial(x: unicodechar): boolean;
begin if (ord(x)>255) then isspecial:=false
      else isspecial:=special[ord(x)]
end;

function item(var s: ustring;var i: int64): ustring;
// i entspricht selstart
var k: int64;
    quit: boolean;
    ch: ustring;
begin inc(i);
      ch:=copy(s,i,1);
      while ((length(ch)=1) and (ch[1]<=#32)) do begin
            inc(i);
            ch:=copy(s,i,1)
      end;
      k:=i;
      quit:=false;
      if (ch<>'') then begin
         if isspecial(s[i]) then inc(i)
         else repeat inc(i);
                     if (i>length(s)) then quit:=true
                     else quit:=(isspecial(s[i]) or (s[i]<=#32))
              until quit
      end;
      item:=copy(s,k,i-k);
      dec(i)
end;

// ------------------------------ Precompiler ----------------------------------

procedure nreverse(var n: cardinal);
var p,reseq: cardinal;
begin reseq:=xnil;
      while (n<>xnil) do begin
            p:=n;
            n:=cell[n].decr;
            cell[p].decr:=reseq;
            reseq:=p
      end;
      n:=reseq
end;

procedure precom(var txt: ustring);
var it: ustring;
    ix: int64;

    procedure precomraise(s: ustring);
    begin //textdump:=true;
          raise exception.create(s)
    end;

    procedure comment;
    begin repeat it:=item(txt,ix);//=    inc(ix);it:=copy(txt,ix,1)
                 if (it='') then precomraise(ecomnocommentend)//fpraise(iderrornocommentend,copy(txt,1,ix))
          until (it=')')
    end;

    procedure comstring;
    var k:longint;//???
    begin k:=ix;
          repeat inc(ix);
                 it:=copy(txt,ix,1);
                 if (it='') then precomraise(ecomnostringend);
                 if (it='"') then begin
                    if (copy(txt,ix+1,1)<>'"') then break;
                    inc(ix);
                 end;
          until false;
          it:=copy(txt,k,ix-k+1);
          cstack:=cons(newstring(AnsiDequotedStr(it,'"')),cstack)//
    end;

    procedure charsequence;
    begin repeat inc(ix);
                 it:=copy(txt,ix,1);
                 if (it='') then precomraise(ecomnoquote);
                 if (it='"') then begin
                    if (copy(txt,ix+1,1)<>'"') then break;
                    inc(ix);
                    cstack:=cons(cindex[ord('"')],cstack)
                 end
                 else if (it[1]<=#255) then
                         cstack:=cons(cindex[ord(it[1])],cstack)
                      else cstack:=cons(newchar(it[1]),cstack)
          until false
    end;

    function find(it: ustring): cardinal;
    var seq,found: cardinal;
    begin seq:=identlist;
          found:=xnil;
          while ((seq<>xnil) and (found=xnil)) do
                if (cell[cell[cell[seq].addr].pname].pstr^ = it) then
                   found:=cell[seq].addr
                else seq:=cell[seq].decr;
          find:=found
    end;

    function ident(it: ustring): cardinal;
    var id: cardinal;
    begin id:=find(it);
          if (id=xnil) then ident:=newident(it,xnil)
                       else ident:=id
    end;

    procedure atom(var it: ustring);
    var numstr: ustring;
        errcode: longint;
        num: double;
    begin numstr:=stringreplace(it,',','.',[rfReplaceAll]);
          val(numstr,num,errcode);
          if (numstr[1]='.')         then errcode:=1;
          if (copy(numstr,1,2)='-.') then errcode:=1;
          if (upcase(numstr[1])='E') then errcode:=1;
          if (errcode=0) then cstack:=cons(newfloat(num),cstack)
                         else cstack:=cons(ident(it),cstack)
    end;

    procedure cbackcons;
    var p,q: cardinal;
    begin p:=xnil;
          while (cell[cstack].addr<>idmark) do begin
                q:=cstack;
                cstack:=cell[cstack].decr;
                cell[q].decr:=p;
                p:=q
          end;
          cell[cstack].addr:=p
    end;

    procedure list;
    begin cstack:=cons(idmark,cstack);
          it:=item(txt,ix);
          while (it<>']') do begin
                if      (it='')  then precomraise(ecomnopostbracket)//fpraise(iderrornopostbracket,copy(txt,1,ix))
                else if (it='[') then list
                else if (it='(') then comment
                else if (it=')') then precomraise(ecomnocommentbegin)
                else if (it='"') then charsequence
                //else if (it='"') then comstring
                else atom(it);
                it:=item(txt,ix)
          end;
          cbackcons
    end;

//procedure precom; // fin? anpassung
begin ix:=0;
      cstack:=xnil;
      it:=item(txt,ix);
      while (it<>'') do begin
            if      (it='[') then list
            else if (it=']') then precomraise(ecomnoprebracket)//fpraise(iderrornoprebracket,copy(txt,1,ix))
            else if (it='(') then comment
            else if (it=')') then precomraise(ecomnocommentbegin)
            else if (it='"') then charsequence
            //else if (it='"') then comstring
            else atom(it);
            it:=item(txt,ix)
      end;
      nreverse(cstack);
end;

// ------------------------------- Postcompiler --------------------------------

procedure postcomraise(s: ustring); // fin? anpassung
begin //cstack:=etop;
      nreverse(cstack);
      //etop:=
      //generror(s);
      //listdump:=true;
      raise exception.create(s)
end;

procedure postcom(redef: boolean); // fin? anpassung             redef???
var tail,obj,p: cardinal;//???longint;
begin nreverse(cstack);
      tail:=xnil;
      while (cstack<>xnil) do begin
            obj:=cell[cstack].addr;
            if (obj=iddef) then begin
               cstack:=cell[cstack].decr;
               if (cstack=xnil) then postcomraise(ecomnoconstname);
               obj:=cell[cstack].addr;
               if (typeof[obj]<>xident) then postcomraise(ecomconstnoident);
               if (not(redef) and (cell[obj].value<>xnil)) then
                  postcomraise(ecomconsttaken+' - '+tovalue(obj));
               cell[obj].value:=tail;
               tail:=xnil;
               cstack:=cell[cstack].decr
            end
            else begin
               p:=cstack;
               cstack:=cell[cstack].decr;
               cell[p].decr:=tail;
               tail:=p;
            end
      end;
      cstack:=tail;
      tail:=xnil//???
end;

// -------------------------- mjoy-interpreter ---------------------------------
//
// interpreter for higher-order programming

procedure xreversey;//muss Liste sein!
begin y:=xnil;
      while (x<>xnil) do begin
            y:=cons(cell[x].addr,y);
            x:=cell[x].decr
      end;
      //x:=xnil
end;

var id: cardinal;

procedure eval;  //eval: efun erwartet eine liste...???
begin //liste interpretieren
      estack:=cons(efun,estack);
      try if ((efun=xnil) or (typeof[efun]=xcons)) then
          //efun:=cell[estack].addr;//???
          //hier:was anderes als liste abprüfen...
          while (efun<>xnil) do begin
                efun:=cell[efun].addr;
                if quotenext then begin quotenext:=false;
                                        stack:=cons(efun,stack)
                                  end
                else if (typeof[efun]<>xident) then stack:=cons(efun,stack)
                else begin
                   id:=efun;
                   efun:=cell[efun].value;
                   if (typeof[efun]=xint) then proc[cell[efun].inum]//grenzen abprüfen!
                   else if (efun<>xnil) then eval
                   else raise exception.create(eidentnull+' - '+tovalue(id))
                end;
                efun:=cell[cell[estack].addr].decr;
                cell[estack].addr:=efun
          end
          else if (typeof[efun]<>xident) then stack:=cons(efun,stack)
          else begin
             id:=efun;
             efun:=cell[efun].value;
             if (typeof[efun]=xint) then proc[cell[efun].inum]//grenzen abprüfen!
             else if (efun<>xnil) then eval
             else raise exception.create(eidentnull+' - '+tovalue(id))
             //
          end;//...
          estack:=cell[estack].decr
          //
          //;mjform.ioedit.lines.append('ok');
      except estack:=cell[estack].decr;
             raise
      end
end;

procedure run;
begin efun:=cstack;
      estack:=xnil;
      quotenext:=false;//?
      eval;
      //
end;

// ----------------------------- Initialisierung -------------------------------

procedure initcharset(var tab: boolset; s: unicodestring);//--> charinset
var i: cardinal;
begin //tab:=[];
      for i:=0 to 255 do tab[i]:=false;//chr(i)
      for i:=1 to length(s) do tab[ord(s[i])]:=true
end;

procedure initvm(mc: int64);
begin joyformatsettings:=DefaultFormatSettings;//TFormatSettings.Create;//(Locale);
      initapi(mc);
      initcharset(special,specialset);
      initidentprimitives;
      //initidents;
      //initprimitives;
      //servprint('sizeof(mjcell)='+inttostr(sizeof(mjcell)))//sizeof(mjcell)
      //
end;

procedure finalvm;
begin finalapi;
      //joyformatsettings.free//?
end;

end.


// (CC BY 3.0) metazip
