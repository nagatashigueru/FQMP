#!/bin/bash

# -----------------------
# obtencion de parametros por linea de comandos
# -----------------------

# <variables opciones>
Metodo=""
archivo=""
Salida=""
escribe=""

# <parametros>
parametros=":m:f:w:o:"

# <procesar opciones>
while getopts $parametros opt; do
    case "$opt" in
        m)
            Metodo=${OPTARG}
            ;;
        f)
            archivo=${OPTARG}
            ;;
        w)
            escribe=${OPTARG}
            ;;
        o)
            Salida=${OPTARG}
            ;;
    esac
done

# ------------------------
# Obtencion de informacion
# ------------------------
energia=$(grep "SCF Done" $archivo | tail -n1 | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f6)
temperatura=$(grep "Temperature" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
presion=$(grep "Pressure" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f6)
zpe=$(grep "Zero-point correction" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
u=$(grep "Thermal correction to Energy" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f6)
entalpia_h=$(grep "Thermal correction to Enthalpy" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f6)
gibbs=$(grep "Thermal correction to Gibbs Free Energy" $archivo | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f8)
entropia_s=$(grep -A 6 "CV" $archivo | grep "Total" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
capacidad_calor_cv=$(grep -A 6 "CV" $archivo | grep "Total" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
e_tot=$(grep -A 6 "CV" $archivo | grep "Total" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
cv_tot=$(grep -A 6 "CV" $archivo | grep "Total" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
s_tot=$(grep -A 6 "CV" $archivo | grep "Total" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
e_elect=$(grep -A 6 "CV" $archivo | grep "Electronic" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
cv_elect=$(grep -A 6 "CV" $archivo | grep "Electronic" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
s_elect=$(grep -A 6 "CV" $archivo | grep "Electronic" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
e_trans=$(grep -A 6 "CV" $archivo | grep "Translational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
cv_trans=$(grep -A 6 "CV" $archivo | grep "Translational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
s_trans=$(grep -A 6 "CV" $archivo | grep "Translational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
e_rot=$(grep -A 6 "CV" $archivo | grep "Rotational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
cv_rot=$(grep -A 6 "CV" $archivo | grep "Rotational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
s_rot=$(grep -A 6 "CV" $archivo | grep "Rotational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
e_vib=$(grep -A 6 "CV" $archivo | grep "Vibrational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f3)
cv_vib=$(grep -A 6 "CV" $archivo | grep "Vibrational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4)
s_vib=$(grep -A 6 "CV" $archivo | grep "Vibrational" | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f5)
metodo=$(grep "SCF Done" $archivo | tail -n1 | tr " \t" "\n" | tr -s "\n" | tr "\n" " " | cut -d " " -f4 | cut -d "(" -f2 | cut -d ")" -f1)
informacion=$(grep -A 7 "Gaussian 09:  ES64L-G09RevE.01 30-Nov-2015" $archivo | tail -n1)
# ------------------------

# -----------------------
# Funciones para escribir en los formatos asignados a los diferentes metodos
# -----------------------

# metodo 1
MetodoUnoSimple (){
echo "
File: $archivo
Method T (K)   P (atm) E(SCF) (au/p)  E(ZPE) (au/p) U(corr) (au/p) H(corr) (au/p) G(corr) (au/p) S (cal/[mol k]) Cv (cal/[mol k])
$metodo $temperatura $presion $energia $zpe      $u       $entalpia_h       $gibbs       $entropia_s         $capacidad_calor_cv
"
}

# metodo 2
MetodoDos (){
echo "calculation details             : $metodo             $archivo
temperature                  (T):            $temperatura k
pressure                     (p):            $presion atm
electr. en.                  (E):     $energia hartree
zero-point corr.           (ZPE):           $zpe hartree/particle
thermal corr.                (U):           $u hartree/particle
ther. corr. enthalpy         (H):           $entalpia_h hartree/particle
ther. corr. Gibbs en.        (G):           $gibbs hartree/particle
entropy (total)          (S tot):            $entropia_s cal/(mol K)
heat capacity (total)     (Cv t):            $capacidad_calor_cv cal/(mol K)
"
}

# metodo 3
MetodoTres (){
echo "
$informacion
----"
MetodoDos
}

# metodo 4
MetodoCuatro (){
MetodoTres
echo "----
Details of the composition
Contrib.        : tot     Ele   Tra    Rot    Vib     Unit
thermal en.  (U): $e_tot $e_elect $e_trans  $e_rot  $e_vib kcal/mol
heat cap.   (Cv): $cv_tot $cv_elect $cv_trans  $cv_rot  $cv_vib  cal/(mol k)
entropy      (S): $s_tot $s_elect $s_trans $s_rot $s_vib cal/(mol k)
"
}

# metodo 5
MetodoCincoSimple (){
echo "
File: $archivo
Method , T (K) ,   P (atm) , E(SCF) (au/p) ,  E(ZPE) (au/p) , U(corr) (au/p) , H(corr) (au/p) , G(corr) (au/p) , S (cal/[mol k]) , Cv (cal/[mol k])
$metodo , $temperatura , $presion , $energia , $zpe ,      $u ,       $entalpia_h ,       $gibbs ,       $entropia_s ,         $capacidad_calor_cv
"
}

if [ "$Metodo" = "1" ]
then
MetodoUnoSimple
    if [ "$escribe" = "y" ]
    then
        data=$(MetodoUnoSimple)
        echo "$data" > $Salida
    fi
elif [ "$Metodo" = "2" ]
then
MetodoDos
    if [ "$escribe" = "y" ]
    then
        data=$(MetodoDos)
        echo "$data" > $Salida
    fi
elif [ "$Metodo" = "3" ]
then
MetodoTres
    if [ "$escribe" = "y" ]
    then
        data=$(MetodoTres)
        echo "$data" > $Salida
    fi
elif [ "$Metodo" = "4" ]
then
MetodoCuatro
    if [ "$escribe" = "y" ]
    then
        data=$(MetodoCuatro)
        echo "$data" > $Salida
    fi
elif [ "$Metodo" = "5" ]
then
MetodoCincoSimple
    if [ "$escribe" = "y" ]
    then
        data=$(MetodoCincoSimple)
        echo "$data" > $Salida
    fi
fi
