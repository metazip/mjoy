unit guiunit;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
     Buttons, Menus,
     IniFiles,
     clipbrd, ExtDlgs;

type

  { TmjoyForm }

  TmjoyForm = class(TForm)
    banner: TPanel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    joyfontdialog: TFontDialog;
    logoimage: TImage;
    backpanel: TPanel;
    iopanel: TPanel;
    iopaintbox: TPaintBox;
    iomemo: TMemo;
    JoyPopupMenu: TPopupMenu;
    doititem: TMenuItem;
    dumpitem: TMenuItem;
    opendialog: TOpenDialog;
    savepictdialog: TSaveDialog;
    savememodialog: TSaveDialog;
    undoitem: TMenuItem;
    cutitem: TMenuItem;
    copyitem: TMenuItem;
    delitem: TMenuItem;
    inititem: TMenuItem;
    fontitem: TMenuItem;
    dochelpitem: TMenuItem;
    refhelpitem: TMenuItem;
    favoritem: TMenuItem;
    quititem: TMenuItem;
    Separator3: TMenuItem;
    toolitem: TMenuItem;
    guideitem: TMenuItem;
    websiteitem: TMenuItem;
    savepictitem: TMenuItem;
    savememoitem: TMenuItem;
    reloaditem: TMenuItem;
    openitem: TMenuItem;
    Separator2: TMenuItem;
    selallitem: TMenuItem;
    pasteitem: TMenuItem;
    Separator1: TMenuItem;
    stopactitem: TMenuItem;
    pstackitem: TMenuItem;
    reloadbutton: TSpeedButton;
    runbutton: TSpeedButton;
    dumpbutton: TSpeedButton;
    openbutton: TSpeedButton;
    pstackbutton: TSpeedButton;
    cutbutton: TSpeedButton;
    copybutton: TSpeedButton;
    pastebutton: TSpeedButton;
    delbutton: TSpeedButton;
    favorbutton: TSpeedButton;
    helpbutton: TSpeedButton;
    iosplitter: TSplitter;
    toolpanel: TPanel;
    procedure copybuttonClick(Sender: TObject);
    procedure copyitemClick(Sender: TObject);
    procedure cutbuttonClick(Sender: TObject);
    procedure cutitemClick(Sender: TObject);
    procedure delbuttonClick(Sender: TObject);
    procedure delitemClick(Sender: TObject);
    procedure dochelpitemClick(Sender: TObject);
    procedure doititemClick(Sender: TObject);
    procedure dumpbuttonClick(Sender: TObject);
    procedure dumpitemClick(Sender: TObject);
    procedure favorbuttonClick(Sender: TObject);
    procedure favoritemClick(Sender: TObject);
    procedure fontitemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure helpbuttonClick(Sender: TObject);
    procedure inititemClick(Sender: TObject);
    procedure iomemoDblClick(Sender: TObject);
    procedure iomemoKeyPress(Sender: TObject; var Key: char);
    procedure iopaintboxPaint(Sender: TObject);
    procedure JoyPopupMenuPopup(Sender: TObject);
    procedure logoimageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure logoimageMouseEnter(Sender: TObject);
    procedure logoimageMouseLeave(Sender: TObject);
    procedure openbuttonClick(Sender: TObject);
    procedure openitemClick(Sender: TObject);
    procedure pastebuttonClick(Sender: TObject);
    procedure pasteitemClick(Sender: TObject);
    procedure pstackbuttonClick(Sender: TObject);
    procedure pstackitemClick(Sender: TObject);
    procedure guideitemClick(Sender: TObject);
    procedure quititemClick(Sender: TObject);
    procedure refhelpitemClick(Sender: TObject);
    procedure reloadbuttonClick(Sender: TObject);
    procedure reloaditemClick(Sender: TObject);
    procedure runbuttonClick(Sender: TObject);
    procedure savememoitemClick(Sender: TObject);
    procedure savepictitemClick(Sender: TObject);
    procedure selallitemClick(Sender: TObject);
    procedure stopactitemClick(Sender: TObject);
    procedure toolitemClick(Sender: TObject);
    procedure undoitemClick(Sender: TObject);
    procedure websiteitemClick(Sender: TObject);
    procedure FormIdle(Sender: TObject; var Done: Boolean);
  private

  public

  end;

var mjoyForm: TmjoyForm;

implementation

{$R *.lfm}

{ TmjoyForm }

uses serveunit,errorunit,initunit,typeunit;

// -----------------------------------------------------------------------------

const pixelinpopupmenu = 12;
      precap: es       = '   ';
      redefine: es     = 'redefine';
      corefiledef: es  = 'core.txt';
      inifiledef: es   = 'mjoy.ini';
      memofiledef: es  = 'Document.txt';
      pictfiledef: es  = 'Image.bmp';
      guidefiledef: es = 'QuickStartGuide.pdf';
      docufiledef: es  = 'Dokumentation.pdf';
      helpfiledef: es  = 'Referenz.pdf';//bitte .pdf
      websitedef: es   = 'https://github.com/metazip/mjoy';// for test
      filenotfound: es    = 'File not found.';
      noparamfilename: es = 'No parameter file.';//param?
      noinifilename: es = 'No inifile name.';
      guisection = 'mjoyForm';//?;
      x0 = 'x0';
      y0 = 'y0';
      dx = 'dx';
      dy = 'dy';
      x0def = 80;
      y0def = 9;
      dxdef = 390;
      dydef = 340;
      tbdef = true;
      toolbar = 'toolbar';
      mcs = 'maxcell';
      fontname    = 'fontname';
      fontcharset = 'fontcharset';
      fontcolor   = 'fontcolor';
      fontheight  = 'fontheight';
      fontpitch   = 'fontpitch';
      fontsize    = 'fontsize';

var formcaption,
    exefilename,paramfilename,corefilename,inifilename,
    memofilename,pictfilename: ustring;
    intxtfile: tstringlist = nil;
    joyinifile: tinifile;

procedure errordialog(s: ustring);
begin with errorForm do begin
           beep;
           show;
           errormemo.SetFocus;
           errormemo.lines.append(s);
           okButton.SetFocus
      end
end;

procedure readinifile(var mc: int64);
var fname: ustring;
begin if (inifilename='') then exit;
      try joyinifile:=tinifile.create(inifilename);
          with joyinifile,mjoyForm do begin
               left:=readinteger(guisection,x0,x0def);
               top:=readinteger(guisection,y0,y0def);
               width:=readinteger(guisection,dx,dxdef);
               height:=readinteger(guisection,dy,dydef);
               //guiForm.iomemo.lines.append('ReadIniFile="'+inifilename+'"');//for test
               toolpanel.visible:=readbool(guisection,toolbar,tbdef);
               toolitem.checked:=toolpanel.visible;//tauschen?
               mc:=readinteger(guisection,mcs,mc);
               fname:=readstring(guisection,fontname,'');
               if (fname<>'') then with iomemo.font do begin
                  charset:=readinteger(guisection,fontcharset,charset);
                  color:=readinteger(guisection,fontcolor,color);
                  //fontadapter
                  //handle
                  height:=readinteger(guisection,fontheight,height);
                  name:=readstring(guisection,fontname,name);
                  //orientation
                  //ownercriticalsection
                  pitch:=tfontpitch(readinteger(guisection,fontpitch,ord(pitch)));
                  //pixelsperinch
                  //quality
                  size:=readinteger(guisection,fontsize,size);
                  //style
               end;
          end;
          joyinifile.free//
      except on e: exception do begin joyinifile.free;
                                      inifilename:='';
                                      errordialog(e.message);
                                end
      end
end;

procedure writeinifile;
begin if (inifilename='') then exit;
      try joyinifile:=tinifile.create(inifilename);
          with joyinifile,mjoyForm do begin
               writeinteger(guisection,x0,left);
               writeinteger(guisection,y0,top);
               writeinteger(guisection,dx,width);
               writeinteger(guisection,dy,height);
               writebool(guisection,toolbar,toolpanel.visible);
               with iomemo.font do begin
                    writeinteger(guisection,fontcharset,charset);
                    writeinteger(guisection,fontcolor,color);
                    //fontadapter
                    //handle
                    writeinteger(guisection,fontheight,height);
                    writestring (guisection,fontname,name);
                    //orientation
                    //ownercriticalsection
                    writeinteger(guisection,fontpitch,ord(pitch));
                    //pixelsperinch
                    //quality
                    writeinteger(guisection,fontsize,size);
                    //style;
               end;
               updatefile
          end;
      finally joyinifile.free
      end
end;

// ------------------------------- Joy-Scriptor --------------------------------

procedure initgui;
var mc: int64; txt: ustring;
begin with mjoyForm do
      try toolpanel.visible:=toolitem.checked;
          iopaintbox.height:=0;
          //
          banner.color:=RGBToColor(240,240,240);
          toolpanel.color:=RGBToColor(240,240,240);
          iosplitter.color:=RGBToColor(240,240,240);
          iomemo.setfocus;
          formcaption:=caption;
          exefilename:=paramstr(0);
          paramfilename:=paramstr(1);
          corefilename:=extractslashpath(exefilename)+corefiledef;
          inifilename :=extractslashpath(exefilename)+inifiledef;
          memofilename:=extractslashpath(exefilename)+memofiledef;
          pictfilename:=extractslashpath(exefilename)+pictfiledef;
          //
          mc:=servemaxcell;
          readinifile(mc);
          if (mc<servemincell) then mc:=servemincell;
          //
          initserve(mc,iomemo,iopaintbox,toolpanel,mjoyForm);
          redef:=false;
          Application.OnIdle:=@FormIdle;
          intxtfile:=tstringlist.create;
          if fileexists(corefilename) then begin
             intxtfile.loadfromfile(corefilename);
             txt:=intxtfile.text;
             intxtfile.clear;
             tellserve(txt);
             caption:=precap+extractslashname(corefilename)+' - '+formcaption
          end;
          if (paramfilename<>'') then if fileexists(paramfilename) then begin
             intxtfile.loadfromfile(paramfilename);
             txt:=intxtfile.text;
             intxtfile.clear;
             tellserve(txt);
             caption:=precap+extractslashname(paramfilename)+' - '+formcaption
          end;
          //
      except on e: exception do begin
                // quelltext ausgeben ...
                errordialog(e.message)
             end
      end
end;

procedure finalgui;
begin intxtfile.free;
      finalserve;
      writeinifile
end;

procedure doit;
var txt: ustring;
begin with mjoyForm do begin
           if (iomemo.sellength>0) then txt:=iomemo.seltext
           else txt:=selectline(unicodestring(iomemo.text),iomemo.selstart);
           redef:=true;
           tellserve(txt);
           //mjoyForm.iomemo.lines.append('['+txt+']');
           caption:=precap+redefine+' - '+formcaption
      end
end;

procedure openjoyfile;
var txt: ustring;
begin with mjoyForm do
      try //imports müssen erst (?)
          opendialog.initialdir:=extractslashpath(paramfilename);
          opendialog.filename:=extractslashname(paramfilename);
          if not(opendialog.execute) then exit;
          paramfilename:=opendialog.filename;
          if not(fileexists(paramfilename)) then
             raise exception.create('"'+paramfilename+'" - '+filenotfound);
          //setserveuserpath(extractslashpath(paramfilename));
          intxtfile.loadfromfile(paramfilename);
          txt:=intxtfile.text;
          intxtfile.clear;
          tellserve(txt);
          //redef:=true;//? ,wird per Button erstmalig geladen (cr für redefine)
          caption:=precap+extractslashname(paramfilename)+' - '+formcaption//
      except on e: exception do begin
                //ausgeben?...
                errordialog(e.message)
             end
      end
end;

procedure reloadjoyfile;
var txt: ustring;
begin with mjoyForm do
      try //imports müssen erst (?)
          if (paramfilename='') then raise exception.create(noparamfilename);
          if not(fileexists(paramfilename)) then
             raise exception.create('"'+paramfilename+'" - '+filenotfound);
          //setserveuserpath(extractslashpath(paramfilename));
          intxtfile.loadfromfile(paramfilename);
          txt:=intxtfile.text;
          intxtfile.clear;
          tellserve(txt);
          redef:=true;//? ,war schon im Speicher
          caption:=precap+extractslashname(paramfilename)+' - '+formcaption//
      except on e: exception do begin
                //ausgeben?...
                errordialog(e.message)
             end
      end
end;

procedure initmaxcell;
var max: int64;
begin if (inifilename='') then begin errordialog(noinifilename); exit end;
      try joyinifile:=tinifile.create(inifilename);
          max:=joyinifile.readinteger(guisection,mcs,servemaxcell);
          initForm.celledit.text:=inttostr(max);
          if (initForm.showmodal=mrok) then begin
             joyinifile.writestring(guisection,mcs,initForm.celledit.text);
             joyinifile.updatefile
          end;
          joyinifile.free
      except on e: exception do begin
                joyinifile.free;
                inifilename:='';//???
                errordialog(e.message)
             end//
      end//
end;

// ----------------------------- Fundamental Loop ------------------------------

procedure TmjoyForm.FormIdle(Sender: TObject; var Done: Boolean);
begin try servereaction; Done:=serveidledone;
      except //quelltexte ausgeben?
             on e: exception do begin
                if onquit then mjoyForm.close
                else errordialog(e.message)
                //
             end//
      end// fios mit idle
end;

// ----------------------------- Service Functions -----------------------------

procedure TmjoyForm.FormCreate(Sender: TObject);
begin //
end;

procedure TmjoyForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin finalgui
end;

procedure TmjoyForm.dumpitemClick(Sender: TObject);
begin serveidentdump
end;

procedure TmjoyForm.favorbuttonClick(Sender: TObject);
begin servetogglepaintbox
end;

procedure TmjoyForm.favoritemClick(Sender: TObject);
begin servetogglepaintbox
end;

procedure TmjoyForm.fontitemClick(Sender: TObject);
begin joyfontdialog.font:=iomemo.font;
      if joyfontdialog.execute then iomemo.font:=joyfontdialog.font
end;

procedure TmjoyForm.doititemClick(Sender: TObject);
begin doit
end;

procedure TmjoyForm.dumpbuttonClick(Sender: TObject);
begin serveidentdump
end;

procedure TmjoyForm.cutitemClick(Sender: TObject);
begin iomemo.cuttoclipboard
end;

procedure TmjoyForm.delbuttonClick(Sender: TObject);
begin iomemo.clearselection
end;

procedure TmjoyForm.delitemClick(Sender: TObject);
begin iomemo.clearselection
end;

procedure TmjoyForm.dochelpitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+docufiledef)
      except on e: exception do errordialog(e.message)
      end
end;

procedure TmjoyForm.copyitemClick(Sender: TObject);
begin iomemo.copytoclipboard
end;

procedure TmjoyForm.cutbuttonClick(Sender: TObject);
begin iomemo.cuttoclipboard
end;

procedure TmjoyForm.copybuttonClick(Sender: TObject);
begin iomemo.copytoclipboard
end;

procedure TmjoyForm.FormShow(Sender: TObject);
begin initgui
end;

procedure TmjoyForm.helpbuttonClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+helpfiledef)
      except on e: exception do errordialog(e.message)
      end
end;

procedure TmjoyForm.inititemClick(Sender: TObject);
begin initmaxcell
end;

procedure TmjoyForm.iomemoDblClick(Sender: TObject);
begin iomemo.lines.add('')
end;

procedure TmjoyForm.iomemoKeyPress(Sender: TObject; var Key: char);
begin if (key=#13) then begin doit;
                              key:=#27;
                              exit
                        end
end;

procedure TmjoyForm.iopaintboxPaint(Sender: TObject);
begin try if (iopaintbox.height>1) then servedrawtrail
      except on e: exception do begin
                // quelltext ausgeben
                errordialog(e.message)
                //
             end//raise
      end
end;

procedure TmjoyForm.JoyPopupMenuPopup(Sender: TObject);
begin undoitem.enabled:=iomemo.canundo;
      cutitem.enabled :=(iomemo.sellength>0);
      copyitem.enabled:=(iomemo.sellength>0);
      pasteitem.enabled:=clipboard.hasformat(CF_TEXT);
      delitem.enabled:=(iomemo.sellength>0);
      //
      reloaditem.enabled:=(paramfilename<>'');
end;

procedure TmjoyForm.logoimageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var t: tpoint;
begin t:=logoimage.clienttoscreen(point(x,y));
      JoyPopupMenu.Popup(t.x-pixelinpopupmenu,t.y{-pixelinpopupmenu})
end;

procedure TmjoyForm.logoimageMouseEnter(Sender: TObject);
begin banner.color:=RGBToColor(255,202,20)//rgb(26,170,33)
end;

procedure TmjoyForm.logoimageMouseLeave(Sender: TObject);
begin banner.color:=RGBToColor(240,240,240)//clBtnFace      //anpassen!
end;

procedure TmjoyForm.openbuttonClick(Sender: TObject);
begin openjoyfile
end;

procedure TmjoyForm.openitemClick(Sender: TObject);
begin openjoyfile
end;

procedure TmjoyForm.pastebuttonClick(Sender: TObject);
begin iomemo.pastefromclipboard
end;

procedure TmjoyForm.pasteitemClick(Sender: TObject);
begin iomemo.pastefromclipboard
end;

procedure TmjoyForm.pstackbuttonClick(Sender: TObject);
begin serveprintstack
end;

procedure TmjoyForm.pstackitemClick(Sender: TObject);
begin serveprintstack
end;

procedure TmjoyForm.guideitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+guidefiledef)
      except on e: exception do errordialog(e.message)
      end
end;

procedure TmjoyForm.quititemClick(Sender: TObject);
begin mjoyForm.close
end;

procedure TmjoyForm.refhelpitemClick(Sender: TObject);
begin try serverun(extractslashpath(exefilename)+helpfiledef)
      except on e: exception do errordialog(e.message)
      end
end;

procedure TmjoyForm.reloadbuttonClick(Sender: TObject);
begin reloadjoyfile
end;

procedure TmjoyForm.reloaditemClick(Sender: TObject);
begin reloadjoyfile
end;

procedure TmjoyForm.runbuttonClick(Sender: TObject);
begin doit
end;

procedure TmjoyForm.savememoitemClick(Sender: TObject);
begin try savememodialog.initialdir:=extractslashpath(memofilename);
          savememodialog.filename:=extractslashname(memofilename);
          if not(savememodialog.execute) then exit;
          memofilename:=savememodialog.filename;
          //if fileexists... //bei save wird auch ohne nachfragen gespeichert
          //encoding einstellen...
          iomemo.lines.WriteBOM:=true;
          iomemo.lines.savetofile(memofilename,TEncoding.UTF8);// gerne UTF8BOM
          caption:=precap+extractslashname(memofilename)+' - '+formcaption
      except on e: exception do errordialog(e.message)
      end//
end;

procedure TmjoyForm.savepictitemClick(Sender: TObject);
var image: timage;
    h,w: longint;
begin savepictdialog.initialdir:=extractslashpath(pictfilename);
      savepictdialog.filename:=extractslashname(pictfilename);
      if not(savepictdialog.execute) then exit;
      // wie ist es mit überschreiben? nachfragen? ;
      pictfilename:=savepictdialog.filename;
      iopaintbox.repaint;                             //??? refresh? ,etc?
      image:=timage.create(self);
      h:=iopaintbox.height;
      w:=iopaintbox.width;
      try //
          image.height:=h;
          image.width:=w;
          image.canvas.copyrect(rect(0,0,w,h),iopaintbox.canvas,rect(0,0,w,h));
          image.picture.savetofile(pictfilename);// ,hier Baustelle !!!
          caption:=precap+extractslashname(pictfilename)+' - '+formcaption;
          //adpanel.caption:=prompt+'"'+pictfilename+'" gespeichert';
          image.free;
      except on e: exception do begin
                image.free;
                errordialog(e.message)
             end//genauer     errordialog?
      end//
end;

procedure TmjoyForm.selallitemClick(Sender: TObject);
begin iomemo.selectall
end;

procedure TmjoyForm.stopactitemClick(Sender: TObject);
begin servestopm
end;

procedure TmjoyForm.toolitemClick(Sender: TObject);
begin toolpanel.visible:=not(toolpanel.visible);
      toolitem.checked:=toolpanel.visible
end;

procedure TmjoyForm.undoitemClick(Sender: TObject);
begin if iomemo.canundo then iomemo.undo
end;

procedure TmjoyForm.websiteitemClick(Sender: TObject);
begin try serverun(websitedef)
      except on e: exception do errordialog(e.message)
      end
end;

end.


// (CC BY 3.0) metazip
