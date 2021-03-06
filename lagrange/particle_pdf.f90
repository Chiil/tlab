#include "types.h"
#include "dns_error.h"
#include "dns_const.h"
#ifdef USE_MPI
#include "dns_const_mpi.h"
#endif


!########################################################################
!# Tool/Library DNS
!#
!########################################################################
!# HISTORY
!#
!#
!########################################################################
!# DESCRIPTION
!#
!# Calculate the pdf for a certain region
!# 
!########################################################################
!# ARGUMENTS 
!#
!#
!########################################################################
SUBROUTINE PARTICLE_PDF(fname,s,wrk1d,wrk2d,wrk3d,x,y,z,l_txc,l_tags,l_hq,l_q)

  USE DNS_GLOBAL, ONLY: isize_field,isize_particle, inb_particle, inb_scal_array
  USE DNS_GLOBAL, ONLY: scalex, scaley, scalez
  USE LAGRANGE_GLOBAL, ONLY :  particle_number
  USE LAGRANGE_GLOBAL, ONLY :  number_of_bins, y_particle_pdf_pos, y_particle_pdf_width
  USE LAGRANGE_GLOBAL, ONLY :  y_particle_pdf_pos, y_particle_pdf_width
  USE LAGRANGE_GLOBAL, ONLY :  x_particle_pdf_pos, x_particle_pdf_width
  USE LAGRANGE_GLOBAL, ONLY :  z_particle_pdf_pos, z_particle_pdf_width
  USE LAGRANGE_GLOBAL, ONLY :  particle_pdf_interval, particle_pdf_max
  USE THERMO_GLOBAL, ONLY : imixture
#ifdef USE_MPI
  USE DNS_MPI
#endif


  IMPLICIT NONE
#ifdef USE_MPI
#include "mpif.h"
#endif  
  TREAL, DIMENSION(*)             :: x,y,z
  TREAL, DIMENSION(isize_field,*) :: s
  TREAL, DIMENSION(*)             :: wrk1d, wrk2d, wrk3d

  TREAL, DIMENSION(isize_particle,inb_particle) :: l_q, l_hq 
  TREAL, DIMENSION(isize_particle,1)                :: l_txc
  INTEGER(8), DIMENSION(*)           :: l_tags


  TLONGINTEGER, DIMENSION(:,:),   ALLOCATABLE         :: particle_bins
  TREAL, DIMENSION(:),   ALLOCATABLE         :: counter_interval
  CHARACTER(*)  ::  fname
  TREAL y_pdf_max, y_pdf_min
  TREAL x_pdf_max, x_pdf_min
  TREAL z_pdf_max, z_pdf_min
  TINTEGER i,j, is, particle_pdf_min
#ifdef USE_MPI
  TLONGINTEGER, DIMENSION(:,:),   ALLOCATABLE         :: particle_bins_local
  ALLOCATE(particle_bins_local(number_of_bins,3)) 
#endif 
  
  ALLOCATE(particle_bins(number_of_bins,3)) 
  ALLOCATE(counter_interval(number_of_bins)) 

  y_pdf_max=y_particle_pdf_pos+0.5*y_particle_pdf_width
  y_pdf_min=y_particle_pdf_pos-0.5*y_particle_pdf_width
  particle_bins=int(0,KIND=8)

  IF (x_particle_pdf_width .NE. 0) THEN
    x_pdf_max=x_particle_pdf_pos+0.5*x_particle_pdf_width
    x_pdf_min=x_particle_pdf_pos-0.5*x_particle_pdf_width
  ENDIF
  IF (z_particle_pdf_width .NE. 0) THEN
    z_pdf_max=z_particle_pdf_pos+0.5*z_particle_pdf_width
    z_pdf_min=z_particle_pdf_pos-0.5*z_particle_pdf_width
  ENDIF


#ifdef USE_MPI
  
  particle_bins_local=0.0

  CALL FIELD_TO_PARTICLE (s(1,inb_scal_array),wrk1d,wrk2d,wrk3d,x ,y, z, l_txc, l_tags, l_hq, l_q) !Update the liquid function  

  !#######################################################################
  !Start counting of particles in bins per processor
  !#######################################################################
  particle_pdf_min = 0  !if needed for future 

  IF (x_particle_pdf_width .EQ. 0) THEN !ONLY PART OF Y
    DO i=1,particle_vector(ims_pro+1)
      IF ( l_q(i,2)/scaley .GE. y_pdf_min .AND. l_q(i,2)/scaley .LE. y_pdf_max) THEN
          j = 1 + int( (l_txc(i,1) - particle_pdf_min) / particle_pdf_interval )
          particle_bins_local(j,1)=particle_bins_local(j,1)+1
  
        DO is=4,5
            j = 1 + int( (l_q(i,is) - particle_pdf_min) / particle_pdf_interval )
            particle_bins_local(j,is-2)=particle_bins_local(j,is-2)+1
        ENDDO
      ENDIF
    ENDDO
  ELSE !3D BOX
     DO i=1,particle_vector(ims_pro+1)
      IF ( l_q(i,1)/scalex .GE. x_pdf_min .AND. l_q(i,1)/scalex .LE. x_pdf_max) THEN
        IF ( l_q(i,2)/scaley .GE. y_pdf_min .AND. l_q(i,2)/scaley .LE. y_pdf_max) THEN
          IF ( l_q(i,3)/scalez .GE. z_pdf_min .AND. l_q(i,3)/scalez .LE. z_pdf_max) THEN
              j = 1 + int( (l_txc(i,1) - particle_pdf_min) / particle_pdf_interval )
              particle_bins_local(j,1)=particle_bins_local(j,1)+1
      
            DO is=4,5
                j = 1 + int( (l_q(i,is) - particle_pdf_min) / particle_pdf_interval )
                particle_bins_local(j,is-2)=particle_bins_local(j,is-2)+1
            ENDDO
          ENDIF
        ENDIF
      ENDIF
    ENDDO
  ENDIF

  !#######################################################################
  !Reduce all information to root
  !#######################################################################

  CALL MPI_BARRIER(MPI_COMM_WORLD,ims_err) 
  CALL MPI_REDUCE(particle_bins_local, particle_bins, number_of_bins*3, MPI_INTEGER8, MPI_SUM,0, MPI_COMM_WORLD, ims_err)
 
  !#######################################################################
  !Create interval for writing
  !#######################################################################
  IF(ims_pro .EQ. 0) THEN
    counter_interval(1)=0
    counter_interval(2)=particle_pdf_interval
    DO i=3,number_of_bins
      counter_interval(i)=counter_interval(i-1)+particle_pdf_interval
    ENDDO

    !#######################################################################
    !Write data to file
    !#######################################################################
    OPEN(unit=116, file=fname)
    DO i=1,number_of_bins
      WRITE (116,'(F6.3, I20.1, I20.1, I20.1)') counter_interval(i), particle_bins(i,1), particle_bins(i,2), particle_bins(i,3)
    END DO
    CLOSE(116)
  END IF


  CALL MPI_BARRIER(MPI_COMM_WORLD,ims_err) 
  DEALLOCATE(particle_bins_local)
#else

  IF ( imixture .EQ. MIXT_TYPE_BILAIRWATERSTRAT ) THEN !Update the liquid function
    CALL FIELD_TO_PARTICLE (s(1,4),wrk1d,wrk2d,wrk3d,x ,y, z, l_txc, l_tags, l_hq, l_q)  
  ELSE
    CALL FIELD_TO_PARTICLE (s(1,3),wrk1d,wrk2d,wrk3d,x ,y, z, l_txc, l_tags, l_hq, l_q)  
  ENDIF

  particle_pdf_min = 0

  DO i=1,particle_number
    IF ( l_q(i,2)/scaley .GE. y_pdf_min .AND. l_q(i,2)/scaley .LE. y_pdf_max) THEN
        j = 1 + int( (l_txc(i,1) - particle_pdf_min) / particle_pdf_interval )
        particle_bins(j,1)=particle_bins(j,1)+1

      DO is=4,5
          j = 1 + int( (l_q(i,is) - particle_pdf_min) / particle_pdf_interval )
          particle_bins(j,is-2)=particle_bins(j,is-2)+1
     ENDDO

    ENDIF
  ENDDO

  counter_interval(1)=0
  counter_interval(2)=particle_pdf_interval
  DO i=3,number_of_bins
    counter_interval(i)=counter_interval(i-1)+particle_pdf_interval
  ENDDO

  OPEN(unit=116, file=fname)
  DO i=1,number_of_bins
    WRITE (116,'(F6.3, I20.1, I20.1, I20.1)') counter_interval(i), particle_bins(i,1), particle_bins(i,2), particle_bins(i,3)
  END DO
  CLOSE(116)


#endif 

  DEALLOCATE(particle_bins)
  DEALLOCATE(counter_interval)
 
  RETURN
END SUBROUTINE PARTICLE_PDF

