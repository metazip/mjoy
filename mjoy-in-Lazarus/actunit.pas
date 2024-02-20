unit actunit;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils;

procedure domonad;

implementation

uses apiunit,serveunit,vmunit,typeunit;

procedure mdot;
begin if (stack=xnil) then raise exception.create(emdotstacknull);
      serveprint(tovalue(cell[stack].addr));//bitte kompackter? ,ok-Haken
      stack:=cell[stack].decr
end;

procedure mprint;
begin if (stack=xnil) then raise exception.create(emprintstacknull);
      x:=cell[stack].addr;
      stack:=cell[stack].decr;
      if (typeof[x]=xcons) then serveprint(tosequence(x))
                           else serveprint(tovalue(x));//wie bei []?
      x:=xnil
end;

procedure mshowgraph;
begin if (stack=xnil) then raise exception.create(emshowgraphstacknull);
      trail:=cell[stack].addr;
      stack:=cell[stack].decr;
      if ((guipaintbox<>nil) and (guiform<>nil)) then begin
         if (guipaintbox.height<=1) then
            guipaintbox.height:=guiform.height-guiformheightsub;//bitte umbauen!
         guipaintbox.repaint
      end//
end;

procedure mloadstring;
var fname,txt,crlf: ustring;
    slist: tstringlist;
    i: longint;//groß genug?
begin if (stack=xnil) then raise exception.create(emloadstringstacknull);
      x:=cell[stack].addr;
      stack:=cell[stack].decr;
      if not((typeof[x]=xcons) or (x=xnil)) then
         raise exception.create(emloadstringtypenolist);
      fname:=seqtostring(x);
      //parampath...
      if not(fileexists(fname)) then
         raise exception.create('"'+fname+'" - '+emloadstringfilenotexists); //???
      slist:=tstringlist.Create;
      try slist.loadfromfile(fname);
          txt:='';  crlf:='';
          for i:=0 to slist.count-1 do begin
              txt:=txt+crlf+slist.Strings[i];
              crlf:=#13#10
          end;
      except slist.free;
             raise exception.create('"'+fname+'" - '+emloadstringloaderror); //???
      end;
      slist.free;
      x:=newcharseq(txt);
      //servprint('{'+fname+'}');
      stack:=cons(x,stack);
      x:=xnil
end;

procedure msavestring;
var fname,s: ustring;
    slist: tstringlist;
begin if (stack=xnil) then raise exception.create(emsavestringstacknull);
      y:=cell[stack].addr;
      stack:=cell[stack].decr;
      if (stack=xnil) then raise exception.create(emsavestringstacknull);
      x:=cell[stack].addr;
      stack:=cell[stack].decr;
      if not((typeof[x]=xcons) or (x=xnil)) then
         raise exception.create(emsavestringtypenolist1);
      if not((typeof[y]=xcons) or (y=xnil)) then
         raise exception.create(emsavestringtypenolist2);
      fname:=seqtostring(x);
      //parampath...
      s:=seqtostring(y);
      slist:=tstringlist.create;
      //??? exc...
      try slist.text:=s; s:='';
          slist.WriteBOM:=true;
          slist.savetofile(fname,TEncoding.UTF8);// gerne UTF8BOM
      except slist.free;
             raise exception.create('"'+fname+'" - '+emsavestringsaveerror); //???
      end;
      slist.free;
      //servprint('{'+fname+'}');
      x:=xnil;
      y:=xnil
      //
end;

procedure mrun;
var fname: ustring;
begin if (stack=xnil) then raise exception.create(emrunstacknull);
      x:=cell[stack].addr;
      stack:=cell[stack].decr;
      if (typeof[x]=xcons) then fname:=AnsiDequotedStr(tosequence(x),'"')
                           else fname:=AnsiDequotedStr(tovalue(x),'"');
      x:=xnil;
      serverun(fname)
end;

procedure domonad;
var i: int64;
begin stack:=cell[stack].decr;
      if (stack=xnil) then raise exception.create(emonadstacknull);
      y:=cell[stack].addr;
      stack:=cell[stack].decr;
      if (stack=xnil) then raise exception.create(emonadstacknull);
      x:=cell[stack].addr;
      stack:=cell[stack].decr;
      if not((y=xnil) or (typeof[y]=xcons)) then
         raise exception.create(emonadtypenolist);
      if (typeof[x]=xfloat) then begin
         try i:=round(cell[x].fnum)
         except raise exception.create(emonadrounderror)
         end;
         mstack:=cons(y,mstack);
         case i of
              1: mdot;
              2: mprint;
              3: mshowgraph;
              4: mloadstring;
              5: msavestring;
              6: mrun;
              7: serveidentdump;
         else raise exception.create(emonadnofunc)
         end//
      end
      else if ((x=xnil) or (typeof[x]=xcons)) then begin
         mstack:=cons(y,mstack);
         efun:=x;
         eval//
      end
      else raise exception.create(emonadnocorrecttype);
      x:=xnil;
      y:=xnil;
      //eval//...
end;

end.


// (CC BY 3.0) metazip
