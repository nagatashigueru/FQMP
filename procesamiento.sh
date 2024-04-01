#!/bin/bash

# =================================
# FUNCIONES
# =================================


# Funcion para obtener informacion
# -----------------------------------

GetInformation (){
case $4 in
    s) local data=$(grep "$1" "$2" | tail -n 1 | awk -v p="$3" '{print $p}') ;;
    c) local data=$(grep -A 6 "CV" "$2" | grep "$1" | awk -v p="$3" '{print $p}') ;;
esac
echo "$data"
}

# Funcion de asignacion de variables
# -------------------------------------

AssignInformation (){
energia=$(GetInformation "SCF Done" $1 5 s)
temperatura=$(GetInformation "Temperature" $1 2 s)
presion=$(GetInformation "Pressure" $1 5 s)
zpe=$(GetInformation "Zero-point correction" $1 3 s)
u=$(GetInformation "Thermal correction to Energy" $1 5 s)
entalpia_h=$(GetInformation "Thermal correction to Enthalpy" $1 5 s)
gibbs=$(GetInformation "Thermal correction to Gibbs Free Energy" $1 7 s)
entropia_s=$(GetInformation "Total" $1 4 c)
capacidad_calor_cv=$(GetInformation "Total" $1 3 c)
e_tot=$(GetInformation "Total" $1 2 c)
cv_tot=$(GetInformation "Total" $1 3 c)
s_tot=$(GetInformation "Total" $1 4 c)
e_elect=$(GetInformation "Electronic" $1 2 c)
cv_elect=$(GetInformation "Electronic" $1 3 c)
s_elect=$(GetInformation "Electronic" $1 4 c)
e_trans=$(GetInformation "Translational" $1 2 c)
cv_trans=$(GetInformation "Translational" $1 3 c)
s_trans=$(GetInformation "Translational" $1 4 c)
e_rot=$(GetInformation "Rotational" $1 2 c)
cv_rot=$(GetInformation "Rotational" $1 3 c)
s_rot=$(GetInformation "Rotational" $1 4 c)
e_vib=$(GetInformation "Vibrational" $1 2 c)
cv_vib=$(GetInformation "Vibrational" $1 3 c)
s_vib=$(GetInformation "Vibrational" $1 4 c)
metodo=$(grep "SCF Done" $1 | tail -n 1 | awk '{print $3}' | awk -F "(" '{print $2}' | awk -F ")" '{print $1}')
informacion=$(grep -A 8 "Gaussian 09:" $1 | tail -n 8 | grep "#p")
}

# Funciones de metodos de escritura
# ------------------------------------

# <<< metodo 1 >>>
MetodoUnoCabecera (){
printf "File: $archivo
%8s %8s %8s %16s %16s %16s %16s %16s %16s %16s" "Method" "T (k)" "P (atm)" "E(SCF) (au/p)" "E(ZPE) (au/p)" "U(corr) (au/p)" "H(corr) (au/p)" "G(corr) (au/p)" "S (cal/[mol k])" "Cv (cal/[mol k])"
}
MetodoUnoCuerpo (){
printf "
%8s %8s %8s %16s %16s %16s %16s %16s %16s %16s" "$metodo" "$temperatura" "$presion" "$energia" "$zpe" "$u" "$entalpia_h" "$gibbs" "$entropia_s" "$capacidad_calor_cv"
}

# <<< metodo 2 >>>
MetodoDos (){
printf "
%21s %8s %8s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s \n%21s %8s %16s %16s" "calculation details" ":" "$metodo" "$archivo" "temperature" "(T):" "$temperatura" "k" "pressure" "(p):" "$presion" "atm" "electr. en." "(E):" "$energia" "hartree" "zero-point corr." "(ZPE):" "$zpe" "hartree/particle" "thermal corr." "(U):" "$u" "hartree/particle" "ther. corr. enthalpy" "(H):" "$entalpia_h" "hartree/particle" "ther. corr. Gibbs en." "(G):" "$gibbs" "hartree/particle" "entropy (total)" "(S tot):" "$entropia_s" "cal/(mol K)" "heat capacity (total)" "(Cv t):" "$capacidad_calor_cv" "cal/(mol K)"
}

# <<< metodo 3 >>>
MetodoTres (){
printf "%s \n----\n" "$informacion"
MetodoDos
}

# <<< metodo 4 >>>
MetodoCuatro (){
MetodoTres
printf "\n----\n %s\n %11s %5s %7s %7s %7s %7s %7s %11s \n%11s %5s %7s %7s %7s %7s %7s %11s \n%11s %5s %7s %7s %7s %7s %7s %11s \n%11s %5s %7s %7s %7s %7s %7s %11s" "Details of the composition" "Contrib." ":" "tot" "Ele" "Tra" "Rot" "Vib" "Unit" "thermal en." "(U):" "$e_tot" "$e_elect" "$e_trans" "$e_rot" "$e_vib" "kcal/mol" "heat cap." "(Cv):" "$cv_tot" "$cv_elect" "$cv_trans" "$cv_rot" "$cv_vib" "cal/(mol k)" "entropy" "(S):" "$s_tot" "$s_elect" "$s_trans" "$s_rot" "$s_vib" "cal/(mol k)"
}

# <<< metodo 5 >>>
MetodoCincoCabecera (){
printf "File: $archivo
%8s %8s %8s %16s %16s %16s %16s %16s %16s %16s" "Method" "T (k)" "P (atm)" "E(SCF) (au/p)" "E(ZPE) (au/p)" "U(corr) (au/p)" "H(corr) (au/p)" "G(corr) (au/p)" "S (cal/[mol k])" "Cv (cal/[mol k])"
}
MetodoCincoCuerpo (){
printf "
%8s, %8s, %8s, %16s, %16s, %16s, %16s, %16s, %16s, %16s" "$metodo" "$temperatura" "$presion" "$energia" "$zpe" "$u" "$entalpia_h" "$gibbs" "$entropia_s" "$capacidad_calor_cv"
}

# Funciones para escribir en pantalla y archivo
# ------------------------------------------------
# <<< cabecera metodo 1 y 5 >>>
CabeceraUnoCincoPantalla () {
case $1 in
    1) MetodoUnoCabecera ;;
    5) MetodoCincoCabecera ;;
esac
}

CabeceraUnoCincoArchivo () {
case $1 in
    1) MetodoUnoCabecera | tee -a $2 ;;
    5) MetodoCincoCabecera | tee -a $2 ;;
esac
}

# <<< pantalla >>>
EscribirPantalla (){
case $1 in
    1) MetodoUnoCuerpo ;;
    2) MetodoDos ;;
    3) MetodoTres ;;
    4) MetodoCuatro ;;
    5) MetodoCincoCuerpo ;;
esac
}

# <<< archivo >>>
EscribirArchivo (){
case $1 in
    1) MetodoUnoCuerpo | tee -a $2 ;;
    2) MetodoDos | tee -a $2 ;;
    3) MetodoTres | tee -a $2 ;;
    4) MetodoCuatro | tee -a $2 ;;
    5) MetodoCincoCuerpo | tee -a $2 ;;
esac
}

# -----------------------
# obtencion de parametros por linea de comandos
# -----------------------

# <variables opciones>
Metodo=""
#archivo=""
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
            #archivo=($(ls ${OPTARG} | awk -F " " '{print $NF}'))
            archivo=(${OPTARG})
            ;;
        w)
            escribe=${OPTARG}
            ;;
        o)
            Salida=${OPTARG}
            ;;
    esac
done

contador=1
for arch in ${archivo[@]}
do
AssignInformation $arch
if [ $contador = 1 ]
then
    if [[ $escribe = "y" ]]
    then
        CabeceraUnoCincoArchivo $Metodo $Salida
        EscribirArchivo $Metodo $Salida
        (( contador++ ))
    else
        CabeceraUnoCincoPantalla $Metodo
        EscribirPantalla $Metodo
        (( contador++ ))
    fi
else
    if [[ $escribe = "y" ]]
    then
        EscribirArchivo $Metodo $Salida
    else
        EscribirPantalla $Metodo
    fi
fi
done
