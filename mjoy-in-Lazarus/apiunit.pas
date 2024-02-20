unit apiunit;

{$mode ObjFPC}{$H+}

interface

uses // Classes,
     SysUtils,
     typeunit;//es,ustring,pustring

const //in Deutsch?
      efilenotfound: es = 'File not found';//?
      //
      // apiunit Speicherverwaltung
      egcerror: es = 'Garbage Collection: Recycling kann nicht durchgeführt werden. Abbruch!';
      ecellnotfree: es = 'Garbage Collection: Gesamter Cell-Speicher verbraucht. Abbruch!';
      enostringmemerror: es = 'Kein Speicherplatz mehr frei für Zeichenkette.';
      //
      enomemoryerror: es = 'Nicht genug Betriebsmittel für Cell-Speicher.';
      //
      // vmunit Compiler
      ecomnocommentbegin: es = 'Compiler > Kein Kommentaranfang.';
      ecomnocommentend: es  = 'Compiler > Kommentar nicht abgeschlossen.';
      ecomnoprebracket:es   = 'Compiler > Text ohne Anfangsklammer.';
      ecomnopostbracket:es = 'Compiler > Frühzeitiges Ende des Textes. "]" fehlt.';
      ecomnostringend: es = 'Compiler > String nicht abgeschlossen.';//???
      ecomnoquote: es = 'Compiler > comnoquote > ''Abschließendes Quote (") fehlt.''';
      //'Termination quote is missing.';//engl?
      //
      ecomnoconstname: es = 'Compiler > Konstanten-Bezeichner fehlt.';
      ecomconstnoident: es = 'Compiler > Konstantenname muss Bezeichner sein.';
      ecomconsttaken: es = 'Compiler > Konstante ist bereits definiert';
      //
      // vmunit Interpreter
      eidentnull: es = 'Interpreter > Bezeichner ist nicht definiert';
      //
      // serveunit Drawtrail
      eserveprintexc: es = 'Print procedure not defined.';//engl.?;
      eservedrawnopair: es = 'Paired arrangement in the list expected.';
      eservedrawxynofloat: es = 'For x,y two floats expected.';
      eservedrawpennological: es = 'For pen a logical operand expected.';
      eservedrawcolornofloat: es = 'For color a float as operand expected.';
      eservedrawsizenofloat: es = 'For size a float as operand expected.';
      eservedrawbrushnofloat: es = 'For brush a float as operand expected.';
      eservedrawcirclenofloat: es = 'For circle a float as operand expected.';
      eservedrawcirclematherror: es = 'Circle calculation error.';
      eservedrawcircledrawerror: es = 'Error occurred during drawing of circle.';
      eservedrawrectdrawerror: es = 'Error occurred during drawing of rect.';
      eservedrawprotocolerror: es = 'Error in the protocol.';
      eservedrawtrailexc: es = 'Graphic procedure not defined.';
      //
      // primunit
      estacknull = '"Stack ist leer."';
      //emonadstacknull = 'monad > stacknull > '+estacknull;
      //
      efuncundef: es = 'eval > funcundef > "Funktion ist nicht definiert."';
      //efundef = 'undef > funcundef > ''Funktion ist nicht definiert.''';
      etypenofloat='"Typ ist kein Float."';
      efloatexpected='"Fließkommazahl erwartet."';
      //edotstacknull = '. > stacknull > '+estacknull;//???
      eunstackstacknull: es = 'unstack > stacknull > '+estacknull;
      eunstacktypenolist: es = 'unstack > typenolist > "Typ ist keine Liste."';
      edupstacknull: es = 'dup > stacknull > '+estacknull;//???
      epopstacknull: es = 'pop > stacknull > '+estacknull;//???
      eswapstacknull: es = 'swap > stacknull > '+estacknull;//???
      eoverstacknull: es = 'over > stacknull > '+estacknull;
      efirststacknull: es = 'first > stacknull > '+estacknull;
      //efirsttypenocons = 'first > typenocons > ''Typ ist nicht cons.''';
      ereststacknull: es = 'rest > stacknull > '+estacknull;
      econsstacknull: es = 'cons > stacknull > '+estacknull;
      econstypenolist: es = 'cons > typenolist > "Typ ist keine Liste."';
      eunconsstacknull: es = 'uncons > stacknull > '+estacknull;
      eunconstypenocons: es = 'uncons > typenocons > "Typ ist keine Cons-Zelle."';
      eswonsstacknull: es = 'swons > stacknull > '+estacknull;
      eswonstypenolist: es = 'swons > typenolist > "Typ ist keine Liste."';
      eunswonsstacknull: es = 'unswons > stacknull > '+estacknull;
      eunswonstypenocons: es = 'unswons > typenocons > "Typ ist keine Cons-Zelle."';
      //
      eaddstacknull: es = '+ > stacknull > '+estacknull;
      eaddtypenofloat: es = '+ > typenofloat > '+etypenofloat;
      esubstacknull: es = '- > stacknull > '+estacknull;
      esubtypenofloat: es = '- > typenofloat > '+etypenofloat;
      emulstacknull: es = '* > stacknull > '+estacknull;
      emultypenofloat: es = '* > typenofloat > '+etypenofloat;
      edivstacknull: es = '/ > stacknull > '+estacknull;
      edivtypenofloat: es = '/ > typenofloat > '+etypenofloat;
      epowstacknull: es = 'pow > stacknull > '+estacknull;
      epowtypenofloat: es = 'pow > typenofloat > "Fließkommazahl erwartet."';
      //
      etypestacknull: es = 'type > stacknull > '+estacknull;//???
      eintstacknull: es = 'int > stacknull > '+estacknull;
      einttypenofloat: es = 'int > typenofloat > "Fließkommazahl erwartet."';
      epredstacknull: es = 'pred > stacknull > '+estacknull;
      epredtypenonum: es = 'pred > typenonum > "Float oder Char erwartet."';//???
      esuccstacknull: es = 'succ > stacknull > '+estacknull;
      esucctypenonum: es = 'succ > typenonum > "Float oder Char erwartet."';//???
      esignstacknull: es = 'sign > stacknull > '+estacknull;
      esigntypenofloat: es = 'sign > typenofloat > "Fließkommazahl erwartet."';
      eabsstacknull: es='abs > stacknull > '+estacknull;
      eabstypenofloat: es='abs > typenofloat > "Fließkommazahl erwartet."';
      enegstacknull: es = 'neg > stacknull > '+estacknull;
      enegtypenofloat: es = 'neg > typenofloat > "Fließkommazahl erwartet."';
      eroundstacknull: es = 'round > stacknull > '+estacknull;
      eroundtypenofloat: es = 'round > typenofloat > "Fließkommazahl erwartet."';
      eexpstacknull: es = 'exp > stacknull > '+estacknull;
      eexptypenofloat: es='exp > typenofloat > "Fließkommazahl erwartet."';
      elogstacknull: es='log > stacknull > '+estacknull;
      elogtypenofloat: es = 'log > typenofloat > "Fließkommazahl erwartet."';
      elog10stacknull: es = 'log10 > stacknull > '+estacknull;
      elog10typenofloat: es = 'log10 > typenofloat > "Fließkommazahl erwartet."';
      elog2stacknull: es = 'log2 > stacknull > '+estacknull;
      elog2typenofloat: es = 'log2 > typenofloat > "Fließkommazahl erwartet."';
      //
      eequalstacknull: es = '= > stacknull > '+estacknull;
      eltstacknull: es = '< > stacknull > '+estacknull;
      elttypenocomp: es = '< > typenocomp > "Typen sind nicht zu vergleichen."';//???
      elttypenochar: es='< > typenostring > "Typ ist kein String."';//???
      enotstacknull: es = 'not > stacknull > '+estacknull;
      enottypenobool: es = 'not > typenobool > "Typ ist kein logischer Wert."';
      eandstacknull: es = 'and > stacknull > '+estacknull;
      eandtypenobool: es = 'and > typenobool > "Typ ist kein logischer Wert."';
      eorstacknull: es = 'or > stacknull > '+estacknull;
      eortypenobool: es = 'or > typenobool > "Typ ist kein logischer Wert."';
      exorstacknull: es = 'xor > stacknull > '+estacknull;
      exortypenobool: es = 'xor > typenobool > "Typ ist kein logischer Wert."';
      enullstacknull: es='null > stacknull > '+estacknull;
      eliststacknull: es='list > stacknull > '+estacknull;
      elogicalstacknull: es='logical > stacknull > '+estacknull;
      econspstacknull: es='consp > stacknull > '+estacknull;
      eidentstacknull: es='ident > stacknull > '+estacknull;
      efloatstacknull: es='float > stacknull > '+estacknull;
      echarstacknull: es='char > stacknull > '+estacknull;
      eundefstacknull: es='undef > stacknull > '+estacknull;
      enamestacknull: es='name > stacknull > '+estacknull;
      enametypenoident: es='name > typenoident > "Typ ist kein Ident."';
      ebodystacknull: es='body > stacknull > '+estacknull;
      ebodytypenoident: es='body > typenoident > "Typ ist kein Ident."';
      euserstacknull: es = 'user > stacknull > '+estacknull;
      eusertypenoident: es = 'user > typenoident > "Typ ist kein Ident."';
      eaddrstacknull: es = 'addr > stacknull > '+estacknull;
      //
      //eshowgraphstacknull='showgraph > stacknull > '+estacknull;
      //
      eistacknull: es = 'i > stacknull > '+estacknull;
      edipstacknull: es = 'dip > stacknull > '+estacknull;
      eifstacknull: es = 'if > stacknull > '+estacknull;
      eiftypenobool: es = 'if > typenobool > "Typ ist kein logischer Wert."';
      ebranchstacknull: es = 'branch > stacknull > '+estacknull;
      ebranchtypenobool: es = 'branch > typenobool > "Typ ist kein logischer Wert."';
      echoicestacknull: es = 'choice > stacknull > '+estacknull;
      echoicetypenobool: es = 'choice > typenobool > "Typ ist kein logischer Wert."';
      eselectstacknull: es='select > stacknull > '+estacknull;
      eselecttypenolist: es='select > typenolist > "Typ ist keine Liste."';
      eselectnocons: es='select > typenocons > "Typ ist keine Cons-Zelle."';//???
      econdstacknull: es='cond > stacknull > '+estacknull;
      econdtypenolist: es='cond > typenolist > "Typ ist keine Liste."';
      econdnocons: es='cond > typenocons > "Typ ist keine Cons-Zelle."';//???
      econdnobool: es='cond > typenobool > "Typ ist kein logischer Wert."';
      etrystacknull: es = 'try > stacknull > '+estacknull;
      estepstacknull: es = 'step > stacknull > '+estacknull;
      esteptypenolist: es='step > typenolist > "Typ ist keine Liste."';//
      erollupstacknull: es = 'rollup > stacknull > '+estacknull;
      erolldownstacknull: es = 'rolldown > stacknull > '+estacknull;
      erotatestacknull: es = 'rotate > stacknull > '+estacknull;
      //
      etimesstacknull: es = 'times > stacknull > '+estacknull;
      ewhilestacknull: es = 'while > stacknull > '+estacknull;
      ewhilestacknullforbool: es='while > stacknullforbool > "Kein logischer Wert im Stack."';//???
      ewhiletypenobool: es='while > typenobool > "Typ ist kein logischer Wert."';
      //
      eindexstacknull: es = 'index > stacknull > '+estacknull;
      eindextypenofloat: es='index > typenofloat > "Fließkommazahl erwartet."';
      eindexrounderror: es='index > rounderror > "Rundungfehler."';
      eindexoutofrange: es='index > outofrange > "Zugriff außerhalb des Stacks."';
      //
      //eprintstacknull = 'print > stacknull > '+estacknull;
      //
      ereversestacknull: es = 'reverse > stacknull > '+estacknull;
      ereversetypenolist: es = 'reverse > typenolist > "Typ ist keine Liste."';
      esizestacknull: es = 'size > stacknull > '+estacknull;
      esizetypenolist: es = 'size > typenolist > "Typ ist keine Liste."';
      etakestacknull: es='take > stacknull > '+estacknull;
      etaketypenolist: es='take > typenolist > "Typ ist keine Liste."';
      etaketypenofloat: es='take > typenofloat > "Fließkommazahl erwartet."';
      etakerounderror: es='take > rounderror > "Rundungsfehler."';
      edropstacknull: es='drop > stacknull > '+estacknull;
      edroptypenolist: es='drop > typenolist > "Typ ist keine Liste."';
      edroptypenofloat: es='drop > typenofloat > "Fließkommazahl erwartet."';
      edroprounderror: es='drop > rounderror > "Rundungsfehler."';
      econcatstacknull: es='concat > stacknull > '+estacknull;
      econcattypenolist: es='concat > typenolist > "Typ ist keine Liste."';
      eswoncatstacknull: es = 'swoncat > stacknull > '+estacknull;
      eswoncattypenolist: es = 'swoncat > typenolist > "Typ ist keine Liste."';
      egetstacknull: es='get > stacknull > '+estacknull;
      egettypenolist: es='get > typenolist > "Typ ist keine Liste."';
      egettypenoident: es='get > typenoident > "Typ ist kein Bezeichner."';
      egetkeynovalue: es='get > keynovalue > "Zum Key fehlt der Value."';//???
      eputstacknull: es='put > stacknull > '+estacknull;
      eputtypenolist: es='put > typenolist > "Typ ist keine Liste."';
      eputtypenoident: es='put > typenoident > "Typ ist kein Bezeichner."';
      eputkeynovalue: es='put > keynovalue > "Zum Key fehlt der Value."';//???
      //;
      eiotastacknull: es = 'iota > stacknull > '+estacknull;
      eiotatypenofloat: es = 'iota > typenofloat > "Fließkommazahl erwartet."';
      eiotarounderror: es = 'iota > rounderror > "Rundungsfehler."';
      eradstacknull: es = 'rad > stacknull > '+estacknull;
      eradtypenofloat: es = 'rad > typenofloat > '+efloatexpected;
      edegstacknull: es = 'deg > stacknull > '+estacknull;
      edegtypenofloat: es = 'deg > typenofloat > '+efloatexpected;
      //
      esinstacknull: es = 'sin > stacknull > '+estacknull;
      esintypenofloat: es = 'sin > typenofloat > "Fließkommazahl erwartet."';
      ecosstacknull: es = 'cos > stacknull > '+estacknull;
      ecostypenofloat: es = 'cos > typenofloat > "Fließkommazahl erwartet."';
      etanstacknull: es = 'tan > stacknull > '+estacknull;
      etantypenofloat: es = 'tan > typenofloat > "Fließkommazahl erwartet."';
      easinstacknull: es = 'asin > stacknull > '+estacknull;
      easintypenofloat: es = 'asin > typenofloat > "Fließkommazahl erwartet."';
      eacosstacknull: es = 'acos > stacknull > '+estacknull;
      eacostypenofloat: es = 'acos > typenofloat > '+efloatexpected;
      eatanstacknull: es = 'atan > stacknull > '+estacknull;
      eatantypenofloat: es = 'atan > typenofloat > '+efloatexpected;
      eatan2stacknull: es = 'atan2 > stacknull > '+estacknull;
      eatan2typenofloat: es = 'atan2 > typenofloat > "Fließkommazahl erwartet."';
      esinhstacknull: es = 'sinh > stacknull > '+estacknull;
      esinhtypenofloat: es = 'sinh > typenofloat > "Fließkommazahl erwartet."';
      ecoshstacknull: es = 'cosh > stacknull > '+estacknull;
      ecoshtypenofloat: es = 'cosh > typenofloat > "Fließkommazahl erwartet."';
      etanhstacknull: es = 'tanh > stacknull > '+estacknull;
      etanhtypenofloat: es = 'tanh > typenofloat > "Fließkommazahl erwartet."';
      esqrtstacknull: es='sqrt > stacknull > '+estacknull;
      esqrttypenofloat: es='sqrt > typenofloat > "Fließkommazahl erwartet."';
      //
      eupperstacknull: es='upper > stacknull > '+estacknull;
      euppertypenochar: es='upper > typenochar > "Char erwartet."';
      elowerstacknull: es='lower > stacknull > '+estacknull;
      elowertypenochar: es='lower > typenochar > "Char erwartet."';
      echrstacknull: es='chr > stacknull > '+estacknull;
      echrtypenofloat: es='chr > typenofloat > '+efloatexpected;
      echroutofrange: es='chr > outofrange > "Wert außerhalb des Unicode-Bereiches."';
      eordstacknull: es='ord > stacknull > '+estacknull;
      eordtypenochar: es='ord > typenochar > "Char erwartet."';
      eminstacknull: es = 'min > stacknull > '+estacknull;
      emintypenocomp: es = 'min > typenocomp > "Typen sind nicht zu vergleichen."';//???
      emaxstacknull: es = 'max > stacknull > '+estacknull;
      emaxtypenocomp: es = 'max > typenocomp > "Typen sind nicht zu vergleichen."';//???
      //
      ergbstacknull: es = 'rgb > stacknull > '+estacknull;
      ergbtypenofloat: es='rgb > typenofloat > '+etypenofloat;
      //seiteneffekt:
      eoutstacknull: es='out > stacknull > '+estacknull;
      eparsestacknull: es='parse > stacknull > '+estacknull;
      eparsetypenolist: es='parse > typenolist > "Typ ist keine Liste."';
      etostrstacknull: es = 'tostr > stacknull > '+estacknull;
      eerrorstacknull: es = 'error > stacknull > '+estacknull;
      // actunit
      emonadstacknull: es = 'monad > stacknull > '+estacknull;
      emonadtypenolist: es = 'monad > typenolist > "Liste für Folgefunktion erwartet."';
      emonadrounderror: es = 'monad > rounderror > "Fehler bei Rundung."';
      emdotstacknull: es = 'mdot > stacknull > '+estacknull;
      emprintstacknull: es = 'mprint > stacknull > '+estacknull;
      emshowgraphstacknull: es = 'mshowgraph > stacknull > '+estacknull;
      emonadnofunc: es = 'monad > nofunc > "Funktion nicht definiert."';
      emonadnocorrecttype: es = 'monad > nocorrecttype > "Monade erwartet korrekte Parameter."';
      emloadstringstacknull: es='mloadstring > stacknull > '+estacknull;
      emloadstringtypenolist: es='mloadstring > typenolist > "Liste für den Dateinamen erwartet."';
      emloadstringfilenotexists: es='Datei existiert nicht.';//? format?
      emloadstringloaderror: es='Datei kann nicht geladen werden.';//? format?
      emsavestringstacknull: es='msavestring > stacknull > '+estacknull;
      emsavestringtypenolist1: es='msavestring > typenolist > "Liste für den Dateinamen erwartet."';
      emsavestringtypenolist2: es='msavestring > typenolist > "Liste für den String erwartet."';
      emsavestringsaveerror: es = 'Datei kann nicht gespeichert werden.';
      emrunstacknull: es = 'mrun > stacknull > '+estacknull;
      //

const xnil = 0;
      maxproc = 1000;
      joydef = '==';
      qot='''';

type xtype=(xnull,xcons,xident,xint,xfloat,xchar,xstring);
     joycell = record case xtype of
                           xnull:   ();
                           xcons:   (addr,decr: cardinal);
                           xident:  (pname,value: cardinal);
                           xint:    (inum: int64);//64 bit
                           xfloat:  (fnum: double);//64 bit
                           xchar:   (ch: char);//unicode
                           xstring: (pstr: pustring);// 32/64 Bit
              end;
     cellmem = array of joycell;
     typemem = array of xtype;
     bitmem  = array of byte;
     charindex = array [byte] of cardinal;//???
     procmem = array [0..maxproc] of procedure;

var cell: cellmem;
    typeof: typemem;
    cebit: bitmem;
    cindex: charindex;
    proc: procmem;
    maxcell,freelist,identlist,cstack,efun,estack,x,y,z: cardinal;
    freeid: cardinal = xnil;
    idmark: cardinal = xnil;
    stack: cardinal = xnil;
    //idmonad: cardinal = xnil;
    iddef: cardinal = xnil;
    trail: cardinal = xnil;
    mstack: cardinal = xnil;
    //redef: boolean = false;// hier?
    //
    idpen: cardinal = xnil;
    idcolor: cardinal = xnil;
    idsize: cardinal = xnil;
    idbrush: cardinal = xnil;
    idcircle: cardinal = xnil;
    idrect: cardinal = xnil;
    //
    idtrue: cardinal = xnil;
    idfalse: cardinal = xnil;
    idmonad: cardinal = xnil;

function cons(a,d: cardinal): cardinal;//prov
function newstring(s: ustring): cardinal;//prov
function newident(s: ustring;v: cardinal): cardinal;
function newint(x: int64): cardinal;
function newfloat(x: double): cardinal;//prov
function newchar(x: char): cardinal;
function newcharseq(s: ustring): cardinal;
function seqtostring(i: cardinal): ustring;
//procedure newexc(s: string);
procedure gc(a,d: cardinal);
procedure initapi(mc: int64);
procedure finalapi;

implementation

// --------------------------- Speicherverwaltung ------------------------------

var freetop: cardinal;

procedure initfreelist;
var i: cardinal;
begin typeof[xnil]:=xnull;
      cebit[xnil]:=1;
      freelist:=xnil;
      for i:=maxcell downto 1 do begin
          typeof[i]:=xcons;
          with cell[i] do begin addr:=xnil; decr:=freelist end;
          freelist:=i;
          cebit[i]:=0
      end
end;

var objp: cardinal;

procedure traverse(i: cardinal);// kein onjump verwenden!
begin if (cebit[i]=0) then begin
         cebit[i]:=1;
         if (typeof[i]=xcons) then
            repeat objp:=cell[i].addr;
                   if (typeof[objp]=xcons) then traverse(objp)
                                           else cebit[objp]:=1;
                   i:=cell[i].decr;
                   if (cebit[i]=1) then exit;
                   cebit[i]:=1
            until false
      end
end;

procedure traverseidents;// kein onjump verwenden!
var i: cardinal;
begin i:=identlist;
      while (i<>xnil) do begin
            traverse(cell[cell[i].addr].pname);//schnellerer Code!
            traverse(cell[cell[i].addr].value);
            i:=cell[i].decr
      end
end;

procedure gc(a,d: cardinal);
var i,c: cardinal;
begin;//freelist,identlist,,,,,//
      try cebit[xnil]:=1;
          traverse(a);
          traverse(d);
          for c:=0 to 255 do cebit[cindex[c]]:=1;
          //
          traverse(freeid);
          traverse(cstack);
          traverse(stack);
          traverse(efun);
          traverse(estack);
          traverse(x);
          traverse(y);
          traverse(z);
          //
          traverse(trail);
          traverse(mstack);
          //
          traverse(identlist);
          traverseidents;
          freelist:=xnil;
          for i:=maxcell downto 1 do
              if (cebit[i]=0) then begin
                 if (typeof[i]=xstring) then dispose(cell[i].pstr);//wenn xstring ->pstr dann disposen
                 typeof[i]:=xcons;
                 with cell[i] do begin addr:=xnil; decr:=freelist end;
                 freelist:=i//
              end
              else cebit[i]:=0//;
      except //quitunit=?
             raise exception.create(egcerror)
             //
      end;
      if (freelist=xnil) then begin //quitunit=?
                                    raise exception.create(ecellnotfree)
                              end;
end;

function cons(a,d: cardinal): cardinal;
begin if (freelist=xnil) then gc(a,d);
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xcons;
      with cell[freetop] do begin addr:=a; decr:=d end;
      cons:=freetop
end;

function newstring(s: ustring): cardinal;
var ps: pustring;//global?
begin if (freelist=xnil) then gc(xnil,xnil);
      try new(ps);
          ps^:=s
      except//quitunit=...
             raise exception.create(enostringmemerror);////
      end;
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xstring;
      cell[freetop].pstr:=ps;
      newstring:=freetop
end;

function newident(s: ustring;v: cardinal): cardinal;
begin freeid:=newstring(s);
      if (freelist=xnil) then gc(xnil,v);
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xident;
      with cell[freetop] do begin pname:=freeid; value:=v end;
      freeid:=xnil;
      newident:=freetop;
      identlist:=cons(freetop,identlist)
end;

function newint(x: int64): cardinal;
begin if (freelist=xnil) then gc(xnil,xnil);
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xint;
      cell[freetop].inum:=x;
      newint:=freetop
end;

function newfloat(x: double): cardinal;
begin if (freelist=xnil) then gc(xnil,xnil);
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xfloat;
      cell[freetop].fnum:=x;
      newfloat:=freetop
end;

function newchar(x: char): cardinal;
begin if (freelist=xnil) then gc(xnil,xnil);
      freetop:=freelist;
      freelist:=cell[freelist].decr;
      typeof[freetop]:=xchar;
      cell[freetop].ch:=x;
      newchar:=freetop
end;

function newcharseq(s: ustring): cardinal;
var i: cardinal;
begin freeid:=xnil;
      for i:=length(s) downto 1 do
          if (s[i]<=#255) then freeid:=cons(cindex[ord(s[i])],freeid)
                          else freeid:=cons(newchar(s[i]),freeid);
      newcharseq:=freeid;
      freeid:=xnil
end;

{procedure newexc(s: string);
begin stack:=cons(newstring(s),stack);
      stack:=cons(idbottom,stack);
end;}

function seqtostring(i: cardinal): ustring;  //   i muss xcons sein!
var s: ustring; obj: cardinal;
begin s:='';
      //vllt auch für xident, xchar und xcons+xnull
      while (typeof[i]<>xnull) do begin
            obj:=cell[i].addr;
            if (typeof[obj]<>xchar) then break;
            s:=s+cell[obj].ch;
            i:=cell[i].decr
      end;
      seqtostring:=s
end;

// ---------------------------- Initialisierung --------------------------------

procedure initcindex;
var c: char;
begin for c:=#0 to #255 do cindex[ord(c)]:=newchar(c)
end;

procedure initapi(mc: int64);
begin //
      maxcell:=mc;
      freelist:=xnil;
      identlist:=xnil;
      freeid:=xnil;
      idmark:=xnil;
      cstack:=xnil;
      stack:=xnil;
      efun:=xnil;
      estack:=xnil;
      x:=xnil;
      y:=xnil;
      z:=xnil;
      iddef:=xnil;
      //idmonad:=xnil;
      //idquote:=xnil;
      //idbottom:=xnil;
      trail:=xnil;
      try setlength(cell,maxcell+1);
          setlength(typeof,maxcell+1);
          setlength(cebit,maxcell+1)
      except //quitunit=...
             raise exception.create(enomemoryerror);//errorquit()//
      end;
      initfreelist;
      initcindex;
      //
end;

procedure freepstrings;   //und pstrs aufsammeln wie in gc
var i: cardinal;
begin for i:=1 to maxcell do
          if (typeof[i]=xstring) then dispose(cell[i].pstr)//
end;

procedure finalapi;
begin freepstrings;//freeidentlist;//nach entsorgung (freeidentlist): identlist:=xnil   ^
      trail:=xnil;   //...
      cell:=nil;
      typeof:=nil;
      cebit:=nil;
      //idmonadxnil
end;

end.


// (CC BY 3.0) metazip
