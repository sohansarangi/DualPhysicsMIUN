#!/bin/bash


# "name" and "dirout" are named according to the testcase

name=CaseMovingSquare
dirout=${name}_NoShifting_out


# "executables" are renamed and called from their directory

gencase="../../EXECS/GenCase4_linux64"
dualsphysics="../../EXECS/DualSPHysics4_linux64"
partvtk="../../EXECS/PartVTK4_linux64"
partvtkout="../../EXECS/PartVTKOut4_linux64"
boundaryvtk="../../EXECS/BoundaryVTK4_linux64"
measuretool="../../EXECS/MeasureTool4_linux64"

# Library path must be indicated properly

current=$(pwd)
cd ../../EXECS
path_so=$(pwd)
cd $current
export LD_LIBRARY_PATH=$path_so


# "dirout" is created to store results or it is cleaned if it already exists

if [ -e $dirout ]; then
  rm -f -r $dirout
fi
mkdir $dirout


# CODES are executed according the selected parameters of execution in this testcase
errcode=0

if [ $errcode -eq 0 ]; then
  $gencase ${name}_Def $dirout/$name -save:all
  errcode=$?
fi

if [ $errcode -eq 0 ]; then
  $dualsphysics $dirout/$name $dirout -svres -gpu -shifting:none
  errcode=$?
fi

if [ $errcode -eq 0 ]; then
  $partvtk -dirin $dirout -filexml $dirout/${name}.xml -savevtk $dirout/PartFluid -onlytype:-all,fluid -vars:+idp,+vel,+rhop,+press,+vor
  errcode=$?
fi

if [ $errcode -eq 0 ]; then
  $partvtkout -dirin $dirout -filexml $dirout/${name}.xml -savevtk $dirout/PartFluidOut -SaveResume $dirout/ResumeFluidOut
  errcode=$?
fi
if [ $errcode -eq 0 ]; then
  $boundaryvtk -loadvtk $dirout/${name}__Dp.vtk -filexml $dirout/${name}.xml -motiondata $dirout -savevtkdata $dirout/Tank.vtk -onlymk:11
  errcode=$?
fi
if [ $errcode -eq 0 ]; then
  $boundaryvtk -loadvtk $dirout/${name}__Dp.vtk -filexml $dirout/${name}.xml -motiondata $dirout -savevtkdata $dirout/Square -onlymk:21
  errcode=$?
fi

if [ $errcode -eq 0 ]; then
  echo All done
else
  echo Execution aborted
fi

read -n1 -r -p "Press any key to continue..." key
echo

:end
pause

