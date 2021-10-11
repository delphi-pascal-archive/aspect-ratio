//  Aspect Ratio:  Show how to display a given picture in a variety of
//  TImages while maintaining the original aspect ratio.
//
//  efg, October 2000.  Updated February/March 2001.
//  www.efg2.com/Lab

unit ScreenAspectRatio;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs;

type
  TFormAspectRatio = class(TForm)
    ImageLandscape: TImage;
    ImagePortrait: TImage;
    ImageSquare: TImage;
    LabelLandscape: TLabel;
    LabelPortrait: TLabel;
    LabelSquare: TLabel;
    ButtonLoadPicture: TButton;
    OpenPictureDialog: TOpenPictureDialog;
    ImageLandscapeNarrow: TImage;
    ImagePortraitNarrow: TImage;
    ImageSquareSmall: TImage;
    ShapeFill: TShape;
    LabelFill: TLabel;
    ColorDialog: TColorDialog;
    LabelLab1: TLabel;
    LabelLab2: TLabel;
    LabelFilename: TLabel;
    procedure ButtonLoadPictureClick(Sender: TObject);
    procedure ShapeFillMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LabelLab2Click(Sender: TObject);
  private
    Bitmap:  TBitmap;

    PROCEDURE DisplayBitmap(CONST Bitmap:  TBitmap;
                            CONST Image:  TImage);
    PROCEDURE UpdateAllImages;
  public
    { Public declarations }
  end;

var
  FormAspectRatio: TFormAspectRatio;

implementation
{$R *.DFM}

USES
  JPEG,
  ShellAPI;    // ShellExecute

// Based on suggestions from Anders Melander.  See Magnifier Lab Report
// www.efg2.com/Lab/ImageProcessing/Magnifier.htm
FUNCTION LoadGraphicsFile(CONST Filename: STRING):  TBitmap;
  VAR
    Picture: TPicture;
BEGIN
  RESULT := NIL;

  IF   FileExists(Filename)
  THEN BEGIN

    RESULT := TBitmap.Create;
    TRY
      Picture := TPicture.Create;
      TRY
        Picture.LoadFromFile(Filename);
        // Try converting picture to bitmap
        TRY
          Result.Assign(Picture.Graphic);
        EXCEPT
          // Picture didn't support conversion to TBitmap.
          // Draw picture on bitmap instead.
          RESULT.Width  := Picture.Graphic.Width;
          RESULT.Height := Picture.Graphic.Height;
          RESULT.PixelFormat := pf24bit;
          RESULT.Canvas.Draw(0, 0, Picture.Graphic);
        END
      FINALLY
        Picture.Free
      END
    EXCEPT
      RESULT.Free;
      RAISE
    END

  END
END {LoadGraphicFile};


// Display Bitmap in Image.  Keep the TBitmap as large as possible
// in the TImage while maintaining the correct aspect ratio.
PROCEDURE TFormAspectRatio.DisplayBitmap(CONST Bitmap:  TBitmap;
                                         CONST Image :  TImage);
  VAR
    Half      :  INTEGER;
    Height    :  INTEGER;
    NewBitmap :  TBitmap;
    TargetArea:  TRect;
    Width     :  INTEGER;
BEGIN
  NewBitmap := TBitmap.Create;
  TRY
    NewBitmap.Width  := Image.Width;
    NewBitmap.Height := Image.Height;
    NewBitmap.PixelFormat := pf24bit;

    NewBitmap.Canvas.Brush := ShapeFill.Brush;
    NewBitmap.Canvas.FillRect(NewBitmap.Canvas.ClipRect);

    // "equality" (=) case can go either way in this comparison

    IF   Bitmap.Width / Bitmap.Height  <  Image.Width / Image.Height
    THEN BEGIN

      // Stretch Height to match.
      TargetArea.Top    := 0;
      TargetArea.Bottom := NewBitmap.Height;

      // Adjust and center Width.
      Width := MulDiv(NewBitmap.Height, Bitmap.Width, Bitmap.Height);
      Half := (NewBitmap.Width - Width) DIV 2;

      TargetArea.Left  := Half;
      TargetArea.Right := TargetArea.Left + Width;
    END
    ELSE BEGIN
      // Stretch Width to match.
      TargetArea.Left    := 0;
      TargetArea.Right   := NewBitmap.Width;

      // Adjust and center Height.
      Height := MulDiv(NewBitmap.Width, Bitmap.Height, Bitmap.Width);
      Half := (NewBitmap.Height - Height) DIV 2;

      TargetArea.Top    := Half;
      TargetArea.Bottom := TargetArea.Top + Height
    END;

    NewBitmap.Canvas.StretchDraw(TargetArea, Bitmap);
    Image.Picture.Graphic := NewBitmap
  FINALLY
    NewBitmap.Free
  END
END {DisplayBitmap};


PROCEDURE TFormAspectRatio.UpdateAllImages;
BEGIN
  DisplayBitmap(Bitmap, ImageLandscape);
  DisplayBitmap(Bitmap, ImageSquare);
  DisplayBitmap(Bitmap, ImagePortrait);

  DisplayBitmap(Bitmap, ImageLandscapeNarrow);
  DisplayBitmap(Bitmap, ImageSquareSmall);
  DisplayBitmap(Bitmap, ImagePortraitNarrow);
END {UpdateAllImages};


procedure TFormAspectRatio.ButtonLoadPictureClick(Sender: TObject);
begin
  IF   OpenPictureDialog.Execute
  THEN BEGIN
    Bitmap.Free;  // get rid of old bitmap

    Bitmap := LoadGraphicsFile(OpenPictureDialog.Filename);
    LabelFilename.Caption := OpenPictureDialog.Filename +  '  (' +
                             IntToStr(Bitmap.Width) + ' by ' +
                             IntToStr(Bitmap.Height) + ' pixels)';
    UpdateAllImages
  END
end;


procedure TFormAspectRatio.ShapeFillMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  IF   ColorDialog.Execute
  THEN ShapeFill.Brush.Color := ColorDialog.Color;

  UpdateAllImages
end;


procedure TFormAspectRatio.FormCreate(Sender: TObject);
begin
  // Default bitmap is red square
  Bitmap := TBitmap.Create;
  Bitmap.Width  := ImageSquare.Width;
  Bitmap.Height := ImageSquare.Height;
  Bitmap.PixelFormat := pf24bit;   // avoid using palettes

  Bitmap.Canvas.Brush.Color := clRed;
  Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);

  UpdateAllImages;
end;


procedure TFormAspectRatio.FormDestroy(Sender: TObject);
begin
  IF   Assigned(Bitmap)
  THEN Bitmap.Free
end;



procedure TFormAspectRatio.LabelLab2Click(Sender: TObject);
begin
  ShellExecute(0, 'open', pchar('http://www.efg2.com/lab'),
               NIL, NIL, SW_NORMAL)
end;

end.
