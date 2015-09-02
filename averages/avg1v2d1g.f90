!########################################################################
!# Tool/Library STATISTICS
!#
!########################################################################
!# HISTORY
!#
!# 2008/04/10 - J.P. Mellado
!#              Created
!#
!########################################################################
!# DESCRIPTION
!#
!# Calculate the average of the plane j in array a conditioned on the
!# intermittency signal given by array gate
!#
!########################################################################
!# ARGUMENTS 
!#
!# igate    In    Level of the gate signal to use as intermittency function
!# imom     In    Moment order
!#
!########################################################################
FUNCTION AVG1V2D1G(nx, ny, nz, j, igate, imom, a, gate)

  IMPLICIT NONE

#include "types.h"
#ifdef USE_MPI
#include "mpif.h"
#endif

  TINTEGER nx, ny, nz, j, imom
  TREAL a(nx, ny, nz)
  INTEGER(1) gate(nx,ny,nz), igate

! -------------------------------------------------------------------
  TINTEGER i, k, nsample
  TREAL AVG1V2D1G
#ifdef USE_MPI
  TINTEGER nsample_mpi
  TREAL sum_mpi
  INTEGER ims_err
#endif

! ###################################################################
  AVG1V2D1G = C_0_R
  nsample = 0
  DO k = 1,nz
     DO i = 1,nx
        IF ( gate(i,j,k) .EQ. igate ) THEN 
           AVG1V2D1G = AVG1V2D1G + a(i,j,k)**imom
           nsample = nsample+1
        ENDIF
     ENDDO
  ENDDO

#ifdef USE_MPI
  nsample_mpi = nsample
  CALL MPI_ALLREDUCE(nsample_mpi, nsample, 1, MPI_INTEGER4, MPI_SUM, MPI_COMM_WORLD, ims_err)

  sum_mpi = AVG1V2D1G
  CALL MPI_ALLREDUCE(sum_mpi, AVG1V2D1G, 1, MPI_REAL8, MPI_SUM, MPI_COMM_WORLD, ims_err)
#endif

  IF ( nsample .GT. 0 ) AVG1V2D1G = AVG1V2D1G/M_REAL(nsample)

  RETURN
END FUNCTION AVG1V2D1G