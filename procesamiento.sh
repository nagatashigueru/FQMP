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
# -------------------------

GetInformation (){
case $4 in
    s) local data=$(grep "$1" "$2" | tail -n 1 | awk -v p="$3" '{print $p}') ;;
    c) local data=$(grep -A 6 "CV" "$2" | grep "$1" | awk -v p="$3" '{print $p}') ;;
esac
echo "$data"
}

energia=$(GetInformation "SCF Done" $archivo 5 s)
temperatura=$(GetInformation "Temperature" $archivo 2 s)
presion=$(GetInformation "Pressure" $archivo 5 s)
zpe=$(GetInformation "Zero-point correction" $archivo 3 s)
u=$(GetInformation "Thermal correction to Energy" $archivo 5 s)
entalpia_h=$(GetInformation "Thermal correction to Enthalpy" $archivo 5 s)
gibbs=$(GetInformation "Thermal correction to Gibbs Free Energy" $archivo 7 s)
entropia_s=$(GetInformation "Total" $archivo 4 c)
capacidad_calor_cv=$(GetInformation "Total" $archivo 3 c)
e_tot=$(GetInformation "Total" $archivo 2 c)
cv_tot=$(GetInformation "Total" $archivo 3 c)
s_tot=$(GetInformation "Total" $archivo 4 c)
e_elect=$(GetInformation "Electronic" $archivo 2 c)
cv_elect=$(GetInformation "Electronic" $archivo 3 c)
s_elect=$(GetInformation "Electronic" $archivo 4 c)
e_trans=$(GetInformation "Translational" $archivo 2 c)
cv_trans=$(GetInformation "Translational" $archivo 3 c)
s_trans=$(GetInformation "Translational" $archivo 4 c)
e_rot=$(GetInformation "Rotational" $archivo 2 c)
cv_rot=$(GetInformation "Rotational" $archivo 3 c)
s_rot=$(GetInformation "Rotational" $archivo 4 c)
e_vib=$(GetInformation "Vibrational" $archivo 2 c)
cv_vib=$(GetInformation "Vibrational" $archivo 3 c)
s_vib=$(GetInformation "Vibrational" $archivo 4 c)
metodo=$(grep "SCF Done" $archivo | tail -n 1 | awk '{print $3}' | awk -F "(" '{print $2}' | awk -F ")" '{print $1}')
informacion=$(grep -A 8 "Gaussian 09:" $archivo | tail -n 8 | grep "#p")
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
