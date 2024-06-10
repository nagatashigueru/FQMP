! ----
! Nombre      : load.f90
! Autor       : Shigueru Nagata
! Descripcion : Programa para leer informacion
!               de archivos de gaussian 16
! ----

program load
implicit none

! <<< constantes >>>

character(len=11), parameter :: InputFile = "Agua_MO.log" ! archivo de entrada
!character(len=11), parameter :: InputFile = "prueba.txt" ! archivo de entrada

! <<< variables >>>

integer :: NumberBasis

! <<< main >>>

call FindBasis(InputFile,NumberBasis)

contains

! <<< funciones >>>


! <<< sub-rutinas >>>

subroutine FileCheckerOpen(IError, FileName)
  ! ++++++++
  ! Verifica si hubo algun error al abrir el archivo
  ! ++++++++
  implicit none

  integer :: IError
  character(len=11) :: FileName

  if (IError .ne. 0) then
    write(*,*) "Falla al abrir el archivo :: ",FileName
    stop
  end if

end subroutine FileCheckerOpen

subroutine FileCheckerRead(IError, FileName, ReadFlag)
  ! ++++++++
  ! Verifica si se ha llegado al final de archivo
  ! o si hubo algun error al leer la linea
  ! ++++++++
  implicit none

  integer :: IError
  integer :: ReadFlag
  character(len=11) :: FileName

  if (IError < 0) then
    write(*,*) "Se llego al final del archivo :: ",FileName
    ReadFlag = 0
  else if (IError > 0) then
    write(*,*) "Error durante lectura del archivo :: ",FileName
    ReadFlag = 0
  end if
end subroutine FileCheckerRead

subroutine FindBasis(FileName,Basis)
  implicit none
  
  character(len=6), parameter :: FmtRead = '(a200)'            ! Formato de lectura de linea
  character(len=16), parameter :: Frase = "basis functions,"   ! Cadena de caracteres distintiva

  integer, parameter :: UnitFile = 23                          ! Numero de unidad asignado al input file
  integer, parameter :: LineLength = 200                       ! Longitud maxima de linea

  integer :: IError
  integer :: ReadFlag
  integer :: IndexValue
  integer :: Basis

  character(len=11) :: FileName                               ! archivo de entrada
  character(len=LineLength) :: Line

  open(unit=UnitFile,file=FileName,status="old",action="read",iostat=IError)

  call FileCheckerOpen(IError,FileName)

  ReadFlag = 1

  do while (ReadFlag > 0)
    read(unit=UnitFile,fmt=FmtRead, iostat=IError) Line
    call FileCheckerRead(IError,FileName,ReadFlag)

    IndexValue = index(Line,Frase)

    if (IndexValue > 0) then
      read(Line,'(i6)')Basis
      write(*,*) "El numero de bases es :: ",Basis
      ReadFlag = 0
    end if

  end do
  
  close(unit=UnitFile)

end subroutine FindBasis

end program load

