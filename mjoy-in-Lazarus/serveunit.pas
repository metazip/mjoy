unit serveunit;

{$mode ObjFPC}{$H+}

interface

uses Windows,//sw_shownormal;...;
     Classes,//tstringlist
     SysUtils,//exception
     StdCtrls,//tmemo
     ExtCtrls,//tpaintbox
     Forms,//tform
     Types,//TPoint
     Graphics,//clblack //TCanvas
     ShellAPI,//run...
     typeunit;//ustring

const servemaxcell = 5000000;// servemaxcelldef=300000;
      servemincell  = 100000;// bitte passend einstellen;
      //prompt='';
      guiformheightsub=135;
      splitterheight = 11;   // clWebGold = $00D7FF; clWebOrange = $00A5FF;

var redef: boolean = false;
    guimemo: tmemo = nil;
    guipaintbox: tpaintbox = nil;
    guipanel: tpanel = nil;
    guiform: tform = nil;
    inqueue: tstringlist = nil;
    onquit: boolean = false;
    serveidledone: boolean = true;

procedure initserve(mc: int64;memo: tmemo;paintbox: tpaintbox;
                                    panel: tpanel;form: tform);
procedure finalserve;
procedure servedrawtrail;
procedure serverun(fname: ustring);// innerhalb von try verwenden!
function extractslashpath(s: ustring): ustring;
function extractslashname(s: ustring): ustring;
function selectline(txt: ustring; i: int64): ustring;
procedure serveidentdump;
procedure serveprintstack;
procedure tellserve(txt: ustring);
procedure serveprint(txt: ustring);
procedure servetogglepaintbox;
procedure servestopm;
procedure servereaction;

implementation

uses apiunit,vmunit,actunit;// primunit?

//schneller (?)
function car(i: cardinal): cardinal;//??? hier aufführen?
begin if (typeof[i]=xcons) then car:=cell[i].addr
                           else car:=xnil
end;

function cdr(i: cardinal): cardinal;//??? hier aufführen?
begin if (typeof[i]=xcons) then cdr:=cell[i].decr
                           else cdr:=xnil
end;

procedure servedrawtrail;
var i,p,q: cardinal;
    joypen: boolean;
    r: double;
    p1,p2: tpoint;
begin if (guipaintbox<>nil) then
      with guipaintbox.canvas do begin
           ;
           moveto(0,0);//x,y
           p1:=penpos;
           pen.color:=clblack;
           pen.width:=1;
           joypen:=true;
           i:=trail;
           while (i<>xnil) do begin
              p:=car(i);
              i:=cdr(i);
              if (i=xnil) then raise exception.create(eservedrawnopair);
              q:=car(i);
              i:=cdr(i);
              if (typeof[p]=xfloat) then begin
                 if (typeof[q]<>xfloat) then raise exception.create(eservedrawxynofloat);
                 p1:=penpos;
                 if joypen then lineto(round(cell[p].fnum),round(-cell[q].fnum))
                           else moveto(round(cell[p].fnum),round(-cell[q].fnum))
              end
              else if (p=idpen) then begin
                 if      (q=idtrue)  then joypen:=true
                 else if (q=idfalse) then joypen:=false
                 else raise exception.create(eservedrawpennological)
              end
              else if (p=idcolor) then begin
                 if (typeof[q]<>xfloat) then raise exception.create(eservedrawcolornofloat);
                 pen.color:=round(cell[q].fnum)//
              end
              else if (p=idsize) then begin
                 if (typeof[q]<>xfloat) then raise exception.create(eservedrawsizenofloat);
                 pen.width:=round(cell[q].fnum)//
              end
              else if (p=idbrush) then begin
                 if (typeof[q]<>xfloat) then raise exception.create(eservedrawbrushnofloat);
                 brush.color:=round(cell[q].fnum)//
              end
              else if (p=idcircle) then begin
                 if (typeof[q]<>xfloat) then raise exception.create(eservedrawcirclenofloat);
                 r:=cell[q].fnum;
                 try if joypen then
                        ellipse(round(penpos.x-r),round(penpos.y-r),
                                round(penpos.x+r),round(penpos.y+r))
                 except on ematherror do
                           raise exception.create(eservedrawcirclematherror)
                        else raise exception.create(eservedrawcircledrawerror)
                 end
              end
              else if (p=idrect) then begin
                 if joypen then
                    try p2:=penpos;
                        fillrect(rect(p1.x,p1.y,p2.x,p2.y));
                        moveto(p2.x,p2.y);
                        lineto(p2.x,p1.y);
                        lineto(p1.x,p1.y);
                        lineto(p1.x,p2.y);
                        lineto(p2.x,p2.y)//
                    except raise exception.create(eservedrawrectdrawerror)
                    end
              end
              else raise exception.create(eservedrawprotocolerror);
              //
           end
           //moveto(0,0);//lineto(200,200)//
      end
      else raise exception.create(eservedrawtrailexc)
end;

function extractslashpath(s: ustring): ustring;
var i: int64;//
    found: boolean;
begin i:=length(s);
      found:=false;
      while ((i>0) and not(found)) do begin
            found:=((s[i]='\') or (s[i]='/') or (s[i]=':'));
            if not(found) then dec(i)
      end;
      extractslashpath:=copy(s,1,i)
end;

function extractslashname(s: ustring): ustring;
var i: int64;//
    found: boolean;
begin i:=length(s);
      found:=false;
      while ((i>0) and not(found)) do begin
            found:=((s[i]='\') or (s[i]='/') or (s[i]=':'));
            if not(found) then dec(i)
      end;
      extractslashname:=copy(s,i+1,length(s)-i)
end;

function selectline(txt: ustring; i: int64): ustring;//
var k: int64;//
    quit: boolean;
begin k:=i+1;
      quit:=false;
      repeat if (i=0) then quit:=true
             else if (txt[i]=#10) then quit:=true
             else dec(i)
      until quit;
      quit:=false;
      repeat if (k>length(txt)) then quit:=true
             else if (txt[k]=#13) then quit:=true
             else inc(k)
      until quit;
      selectline:=copy(txt,i+1,k-i-1)
end;

//kopiert von FPXE11 und modif
procedure serveidentdump;
var p,q,id,len: cardinal;
    s,crlf: ustring;
begin p:=identlist;
      s:='';
      crlf:='';
      while (p<>xnil) do begin
            id:=cell[p].addr;
            q:=cell[id].value;
            if (q=xnil) then s:='( '+tovalue(id)+' )'+crlf+s
            else if (typeof[q]=xint) then
                    s:=tovalue(id)+' '+joydef+' '+tovalue(q)+crlf+s
            else s:=tovalue(id)+' '+joydef+' '+tosequence(q)+crlf+s;
            crlf:=#13#10;
            p:=cell[p].decr//
      end;
      if (guimemo<>nil) then len:=length(unicodestring(guimemo.text))
                        else len:=0;
      serveprint(s);
      if (guimemo<>nil) then begin guimemo.selstart:=len;
                                   guimemo.sellength:=length(s)+length(#13#10)
                            end
      //serveprint(prompt)//bitte markieren!!!!!!!!!!!!!!!
      {with fpform.iomemo do begin
           len:=length(text);
           lines.append(s+#13#10+ioprompt);//+#9
           selstart:=len;
           sellength:=length(#13#10)+length(s)+length(#13#10+ioprompt)
      end//}
      //s:=s+#13#10+prompt;
      //len:=0
      //
end;

procedure serveprintstack;
begin x:=stack;
      xreversey;
      if (y=xnil) then serveprint('(null)')
      else serveprint(tosequence(y));
      //servprint(tovalue(stack));
end;

procedure tellserve(txt: ustring);
begin inqueue.add(txt);
end;

procedure serveprint(txt: ustring);//txt ist pointer
begin if (guimemo <> nil) then guimemo.lines.append(txt)
      else raise exception.create(eserveprintexc);
end;

{
procedure servetogglepaintbox;
begin if ((guipaintbox<>nil) and (guiform<>nil)) then begin //and...
         if (guipaintbox.height<=1) then
            guipaintbox.height:=guiform.height-guiformheightsub //prov
         else guipaintbox.height:=0;
         //guipaintbox.repaint;
         //etop:=iodict //guipaintbox.repaint      ,xnil???
      end
      else raise exception.create('Device ist nicht installiert...')//...
end;
}

procedure servetogglepaintbox;
var delta: longint;
begin if ((guipaintbox<>nil) and (guipanel<>nil) and (guiform<>nil)) then begin
         if guipanel.visible then delta:=guipanel.height
                             else delta:=0;
         if (guipaintbox.height>1) then guipaintbox.height:=0
         else guipaintbox.height:=guiform.clientheight-delta-splitterheight;
         //
      end
      else raise exception.create('device is not installed (favorite)...')// provi
end;

procedure serverun(fname: ustring);//name bitte in try except verwenden!
const errorcode = 'ERRORCODE';
var res: longint;
begin //panelbar nullstring
      if (guiform=nil) then raise exception.create('guiformular is nil...')//provi
      else with guiform do begin
         res:=shellexecute(handle,'open'#0,pWideChar(fname),#0,#0,sw_shownormal);//???
         if (res<=32) then
            case res of
                 ERROR_FILE_NOT_FOUND: raise exception.create('"'+fname+'" - '+efilenotfound);
            else raise exception.create('"'+fname+'" - '+errorcode+' #'+inttostr(res))
            end
      end
end;

procedure servestopm;
begin //...
      mstack:=xnil;
      if (stack<>xnil) then
         if (cell[stack].addr=idmonad) then stack:=cell[stack].decr
end;

procedure servereaction; // fundamental loop
var txt: ustring;
    len: cardinal;
begin try onquit:=false;//richtig?
          if (stack<>xnil) then begin
             if (cell[stack].addr=idmonad) then begin domonad;//servmonad;
                                                      serveidledone:=false;
            { txt:=guimemo.text;
             len:=length(txt);
             txt:=selectline(txt,len);
             if (txt<>prompt) then servprint(prompt)
             else guimemo.selstart:=len;
             guimemo.setfocus }
                                                      ;
                                                      exit
                                                end
          end;
          if (mstack<>xnil) then begin efun:=cell[mstack].addr;
                                       mstack:=cell[mstack].decr;
                                       eval;
                                       serveidledone:=false;
                                       exit
                                 end;
          if (inqueue.count>0) then begin
             txt:=inqueue.strings[0];//auf nils achten
             inqueue.delete(0);
             precom(txt);
             postcom(redef);
             run;
             //servprint(tovalue(cstack));
             //
             //stack:=cons(newfloat(500),stack);
             //stack:=cons(idmonad,stack);
             //newexc('hallo welt');//
             //
             //servprint(inttostr($00A5FF));
             //if(typeof[cstack]=xcons)then servprint('--> '+tovalue(cell[cstack].addr));
             serveidledone:=false;   //?
             exit
          end;
          if not(serveidledone) then begin
             txt:=guimemo.text;
             len:=length(txt);
             txt:=selectline(txt,len);
             if (txt<>'') then if (guimemo <> nil) then begin
                //guimemo.lines.add('');
                txt:=guimemo.text+#13#10;
                guimemo.text:=txt;
                guimemo.selstart:=length(txt);
                //guimemo.setfocus
             end;
          end;
          serveidledone:=true;
          //
      except mstack:=xnil;//? ...
             raise// prov ,servprint prompt
      end
end;

procedure initserve(mc: int64;memo: tmemo;paintbox: tpaintbox;
                                    panel: tpanel;form: tform);
begin onquit:=false;
      idmonad:=xnil;// hier?
      mstack:=xnil;
      inqueue:=tstringlist.create;
      serveidledone:=true;
      //
      guimemo:=memo;
      guipaintbox:=paintbox;
      guipanel:=panel;
      guiform:=form;
      //
      //trail:=...
      initvm(mc)
      ;idmonad:=newident('!',xnil);// hier?
      //
end;

procedure finalserve;
begin finalvm;
      idmonad:=xnil;//?
      //trail:=xnil;//?
      inqueue.free;
      guimemo:=nil;
      guipaintbox:=nil;
      guipanel:=nil;
      guiform:=nil;
      //
end;

end.


// (CC BY 3.0) metazip
