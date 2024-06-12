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
character(len=11), parameter :: TempFileBlocks = "Blocks.temp"
character(len=16), parameter :: TempFileBlocksClear = "BlocksClear.temp"

! <<< variables >>>

integer :: NumberBasis

! <<< main >>>

call FindBasis(InputFile,NumberBasis)
call GetBlocks(InputFile,TempFileBlocks,NumberBasis)
call ClearBlocks(TempFileBlocks,TempFileBlocksClear,NumberBasis)


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

subroutine GetBlocks(FileNameInput,FileNameTemp,Basis)
  implicit none

  character(len=6), parameter :: FmtRead = '(a200)'
  character(len=30), parameter :: Frase = "Molecular Orbital Coefficients"   ! Cadena de caracteres distintiva


  integer, parameter :: LineLength = 200
  integer, parameter :: UnitFileTemp = 24                          ! Numero de unidad asignado al input file
  integer, parameter :: UnitFileInput = 23                          ! Numero de unidad asignado al input file

  integer :: ReadFlag
  integer :: IndexValue
  integer :: NumberLines
  integer :: NumberBlocks
  integer :: Basis
  integer :: IErrorInput
  integer :: IErrorTemp
  integer :: LineCount

  character(len=LineLength) :: Line
  character(len=11) :: FileNameTemp
  character(len=11) :: FileNameInput

  ReadFlag = 1
  LineCount = 0

  NumberBlocks = (Basis / 5) + 1
  NumberLines = NumberBlocks * (Basis + 3)

  open(unit=25, iostat=IErrorTemp, file=FileNameTemp, status='old')
  if (IErrorTemp == 0) then
    close(25, status='delete')
  end if

  open(unit=UnitFileInput,file=FileNameInput,status="old",action="read",iostat=IErrorInput)
  open(unit=UnitFileTemp,file=FileNameTemp,status="new",action="write",iostat=IErrorTemp)

  call FileCheckerOpen(IErrorInput,FileNameInput)
  call FileCheckerOpen(IErrorTemp,FileNameTemp)

  do while (ReadFlag > 0 .or. LineCount < NumberLines)
    read(unit=UnitFileInput,fmt=FmtRead, iostat=IErrorInput) Line
    call FileCheckerRead(IErrorInput,FileNameInput,ReadFlag)

    IndexValue = index(Line,Frase)

    if (IndexValue > 0) then
      do while (LineCount < NumberLines)
        read(unit=UnitFileInput,fmt=FmtRead, iostat=IErrorInput) Line
        write(unit=UnitFileTemp,fmt=FmtRead) Line
        LineCount = LineCount + 1
      end do
    end if

  end do

  close(unit=UnitFileInput)
  close(unit=UnitFileTemp)

end subroutine GetBlocks

subroutine ClearBlocks(FileNameInput,FileNameTemp,Basis)
  implicit none

  character(len=6), parameter :: FmtRead = '(a200)'
!  character(len=42), parameter :: FmtRead = '(A22,F9.5,F9.5,F9.5,F9.5,F9.5)'
!  character(len=42), parameter :: FmtWrite = '(A22,F9.5,1X,F9.5,1X,F9.5,1X,F9.5,1X,F9.5)'

  integer, parameter :: LineLength = 200
  integer, parameter :: UnitFileTemp = 24                          ! Numero de unidad asignado al input file
  integer, parameter :: UnitFileInput = 23                          ! Numero de unidad asignado al input file

  integer :: IErrorInput
  integer :: IErrorTemp
  integer :: LineCount
  integer :: State
  integer :: NumberLines
  integer :: Basis
  integer :: ReadFlag

  real :: Col1
  real :: Col2
  real :: Col3
  real :: Col4
  real :: Col5

  character(len=LineLength) :: Line
  character(len=16) :: FileNameTemp
  character(len=11) :: FileNameInput

  ReadFlag = 1
  LineCount = 1
  State = 2

  NumberLines = Basis + 1

  open(unit=25, iostat=IErrorTemp, file=FileNameTemp, status='old')
  if (IErrorTemp == 0) then
    close(25, status='delete')
  end if

  open(unit=UnitFileInput,file=FileNameInput,status="old",action="read",iostat=IErrorInput)
  open(unit=UnitFileTemp,file=FileNameTemp,status="new",action="write",iostat=IErrorTemp)

  call FileCheckerOpen(IErrorInput,FileNameInput)
  call FileCheckerOpen(IErrorTemp,FileNameTemp)

  do while (ReadFlag > 0)
    read(unit=UnitFileInput,fmt=FmtRead, iostat=IErrorInput) Line
    call FileCheckerRead(IErrorInput,FileNameInput,ReadFlag)
    if (LineCount > State .and. LineCount < State + NumberLines + 1) then
      write(unit=UnitFileTemp,fmt=FmtRead) Line
      LineCount = LineCount + 1
    else if (LineCount == State + NumberLines + 2) then
      State = LineCount
      LineCount = LineCount + 1
    else
      LineCount = LineCount + 1
    end if
  end do

  close(unit=UnitFileInput)
  close(unit=UnitFileTemp)

end subroutine

end program load

