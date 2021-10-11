//  Aspect Ratio:  Show how to display a given picture in a variety of
//  TImages while maintaining the original aspect ratio.
//
//  efg, October 2000.  Updated February/March 2001.
//  www.efg2.com/Lab

program AspectRatio;

uses
  Forms,
  ScreenAspectRatio in 'ScreenAspectRatio.pas' {FormAspectRatio};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormAspectRatio, FormAspectRatio);
  Application.Run;
end.
