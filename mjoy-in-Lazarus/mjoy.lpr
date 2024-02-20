program mjoy;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, guiunit, errorunit, initunit, 
  apiunit, serveunit, vmunit, primunit, actunit, typeunit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TmjoyForm, mjoyForm);
  Application.CreateForm(TerrorForm, errorForm);
  Application.CreateForm(TinitForm, initForm);
  Application.Run;
end.

