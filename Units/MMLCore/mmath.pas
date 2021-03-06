{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

    Mufasa Math Unit for the Mufasa Macro Library
}

unit mmath;
// mufasa math

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,MufasaTypes;

function RotatePoints(const P: TPointArray;const A, cx, cy: Extended): TPointArray;
function RotatePoint(const p: TPoint;const angle, mx, my: Extended): TPoint;
function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;
function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;
function RiemannGauss(Xstart,StepSize,Sigma : extended; AmountSteps : integer) : extended;
function DiscreteGauss(Xstart,Xend : integer; sigma : extended) : TExtendedArray;
function GaussMatrix(N : integer; sigma : extended) : T2DExtendedArray;
function MinA(a: TIntegerArray): Integer;
function MaxA(a: TIntegerArray): Integer;
function fixRad(rad: Extended): Extended; 
function InAbstractBox(x1, y1, x2, y2, x3, y3, x4, y4: Integer; x, y: Integer): Boolean;
function MiddleBox(b : TBox): TPoint;


implementation
uses
  math;
{/\
  Returns a GaussianMatrix with size of X*X, where X is Nth odd-number.
/\}
function GaussMatrix(N:Integer; Sigma:Extended): T2DExtendedArray;
var
  hkernel:Array of Extended;
  Size,i,x,y:Integer;
  sum:Extended;
begin
  Size := 2*N+1;
  SetLength(hkernel, Size);
  for i:=0 to Size-1 do
    hkernel[i] := Exp(-(Sqr((i-N) / Sigma)) / 2.0);

  SetLength(Result, Size, Size);
  sum:=0;
  for y:=0 to Size-1 do
    for x:=0 to Size-1 do
    begin
      Result[y][x] := hkernel[x]*hkernel[y];
      Sum := Sum + Result[y][x];
    end;

  for y := 0 to Size-1 do
    for x := 0 to Size-1 do
      Result[y][x] := Result[y][x] / sum;
end;

{/\
  Returns the discrete Gaussian values, uses RiemanGauss with 100 steps.
/\}
function DiscreteGauss(Xstart,Xend : integer; sigma : extended) : TExtendedArray;
var
  i : integer;
begin
  setlength(Result,Xend-xstart+1);
  for i := xstart to xend do
    result[i-xstart] :=  RiemannGauss(i-0.5,0.01,Sigma,100);
end;

{/\
  RiemannGauss integrates the Gaussian function using the Riemann method.
/\}
function RiemannGauss(Xstart,StepSize,Sigma : extended; AmountSteps : integer) : extended;
var
  i : integer;
  x : extended;
begin
  result := 0;
  x := xstart - 0.5 * stepsize;
  for i := 1 to AmountSteps do
  begin
    x := x + stepsize; //Get the middle value
    result := Result + exp(-x*x/(2*sigma*sigma)); //Better accuracy to do the sig^2 here?
  end;
  result := result * stepsize * 1 / (Sqrt(2 * pi) * sigma);
end;

{/\
  Rotates the given points (P) by A (in radians) around the point defined by cx, cy.
/\}

function RotatePoints(const P: TPointArray;const A, cx, cy: Extended): TPointArray;

var
   I, L: Integer;

begin
  L := High(P);
  SetLength(Result, L + 1);
  for I := 0 to L do
  begin
    Result[I].X := Round(cx + cos(A) * (p[i].x - cx) - sin(A) * (p[i].y - cy));
    Result[I].Y := Round(cy + sin(A) * (p[i].x - cx) + cos(A) * (p[i].y - cy));
  end;
end;

{/\
  Rotates the given point (p) by A (in radians) around the point defined by cx, cy.
/\}

function RotatePoint(const p: TPoint;const angle, mx, my: Extended): TPoint;

begin
  Result.X := Round(mx + cos(angle) * (p.x - mx) - sin(angle) * (p.y - my));
  Result.Y := Round(my + sin(angle) * (p.x - mx) + cos(angle) * (p.y- my));
end;

function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;
var
  angle : extended;
begin
  angle := ArcTan2(pt.y-my,pt.x-mx);
  result.x := round(cos(angle) * newdist) + mx;
  result.y := round(sin(angle) * newdist) + my;
end;

function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;
var
  angle : extended;
  i : integer;
begin
  result := false;
  if length(TPA) < 1 then
    exit;
  result := true;
  try
    for i := high(TPA) downto 0 do
    begin
      angle := ArcTan2(TPA[i].y-my,TPA[i].x-mx);
      TPA[i].x := round(cos(angle) * newdist) + mx;
      TPA[i].y := round(sin(angle) * newdist) + my;
    end;
  except
    result := false;
  end;
end;

function MinA(a: TIntegerArray): Integer;
var
  L, i: Integer;
begin
  L := High(a);
  if (L < 0) then
    Exit(0);

  Result := a[0];

  for i := 1 to L do
    if (a[i] < Result) then
      Result := a[i];
end;

function MaxA(a: TIntegerArray): Integer;
var
  L, i: Integer;
begin
  L := High(a);
  if (L < 0) then
    exit(0);

  Result := a[0];

  for i := 1 to L do
    if (a[i] > Result) then
      Result := a[i];
end;

function FixRad(rad: Extended): Extended;
begin
  result := rad;

  while (result >= (3.14159265358979320 * 2.0)) do
    result := result - (3.14159265358979320 * 2.0);

  while (result < 0) do
    result := result + (3.14159265358979320 * 2.0);
end;

function InAbstractBox(x1, y1, x2, y2, x3, y3, x4, y4: Integer; x, y: Integer): Boolean;
var
  U, D, R, L: Boolean;
  UB, DB, LB, RB, UM, DM, LM, RM, PI: Extended;
begin
  PI := 3.14159265358979320;
  UM := (-y1 - -y2) div (x1 - x2);
  DM := (-y4 - -y3) div (x4 - x3);
  if x1 - x4 <> 0 then
  begin
    LM := (-y1 - -y4) div (x1 - x4);
  end else
  begin
    LM := Pi;
  end;
  if x2 - x3 <> 0 then
  begin
    RM := (-y2 - -y3) div (x2 - x3);
  end else
  begin
    RM := Pi;
  end;
  UB := -(UM * x1) + -y1;
  RB := -(RM * x2) + -y2;
  DB := -(DM * x3) + -y3;
  LB := -(LM * x4) + -y4;
  if (UM * x + UB >= -y) then U := True;
  if (DM * x + DB <= -y) then D := True;
  if (RM <> Pi) and (RM >= 0) and (RM * x + RB <= -y) then R := True;
  if (RM <> Pi) and (RM < 0) and (RM * x + RB >= -y) then R := True;
  if (RM = Pi) and (x < x2) then R := True;
  if (LM <> Pi) and (LM >= 0) and (LM * x + LB >= -y) then L := True;
  if (LM <> Pi) and (LM < 0) and (LM * x + LB <= -y) then L := True;
  if (LM = Pi) and (x > x1) then L := True;
  if U and D and L and R then Result := True;
end;

function MiddleBox(b : TBox): TPoint;
begin
  result := point((b.x2+b.x1) div 2,(b.y2+b.y1) div 2);
end;

end.

