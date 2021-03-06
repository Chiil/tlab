#include "types.h"
#include "dns_error.h"
#include "dns_const.h"
#ifdef USE_MPI
#include "dns_const_mpi.h"
#endif

!########################################################################
!# Tool/Library
!#
!########################################################################
!# HISTORY
!#
!# 2014/02 - L. Muessle
!#              Created
!#
!########################################################################
!# DESCRIPTION
!#
!# Taking care of Particle routines in time_substep_incompressible_explicit 
!#
!########################################################################
!# ARGUMENTS 
!#
!# 
!#
!########################################################################
SUBROUTINE PARTICLE_TIME_SUBSTEP(dte, x, z, l_q, l_hq,&
                                l_tags, l_comm )    



  USE DNS_GLOBAL, ONLY : imax,jmax,kmax, isize_field, isize_txc_field, imax_total, kmax_total
  USE DNS_GLOBAL, ONLY: isize_particle, scalex, scalez, inb_particle
  USE LAGRANGE_GLOBAL
#ifdef USE_MPI
  USE DNS_MPI
#endif

  IMPLICIT NONE
#ifdef USE_MPI
#include "mpif.h"
#endif



  TREAL dte, dx_grid, dz_grid
  TREAL, DIMENSION(*)                 :: x,z
  TREAL, DIMENSION(isize_particle,inb_particle) :: l_q
  TREAL, DIMENSION(isize_particle,inb_particle) :: l_hq
  TREAL, DIMENSION(isize_l_comm) :: l_comm
  TARGET :: l_comm

  TINTEGER is, i

  INTEGER(8), DIMENSION(isize_particle)  :: l_tags
#ifdef USE_MPI
  TREAL, DIMENSION(:), POINTER :: p_buffer_1, p_buffer_2
  TINTEGER nzone_grid, nzone_west, nzone_east, nzone_south, nzone_north
#endif
 
 
#ifdef USE_MPI
  
  p_buffer_1(1:isize_pbuffer)=> l_comm(isize_max_hf+1:isize_max_hf+isize_pbuffer)
  p_buffer_2(1:isize_pbuffer)=> l_comm(isize_max_hf+isize_pbuffer+1:isize_max_hf+isize_pbuffer*2)

  dx_grid=scalex/imax_total  
  dz_grid=scalez/kmax_total  
  
  !#######################################################################
  ! Particle new postion here!
  !#######################################################################
   
    DO i = 1,particle_vector(ims_pro+1)
      DO is = 1,inb_particle_evolution !coordinaes 1=x 2=y 3=z
      
        !Particle update
        l_q(i,is) = l_q(i,is) + dte*l_hq(i,is)
  
      ENDDO
    END DO
  !#####################################################################
  !Particle sorting for Send/Recv X-Direction
  !#####################################################################        

    CALL PARTICLE_SORT(x,z,nzone_grid, nzone_west, nzone_east,nzone_south, nzone_north,1,&
                       l_hq, l_tags,l_q )

    IF (ims_pro_i .EQ. 0) THEN
      IF (nzone_west .NE. 0) THEN
        l_q(nzone_grid+1:nzone_grid+nzone_west,1) = l_q(nzone_grid+1:nzone_grid+nzone_west,1) + x(imax_total)+ dx_grid
      END IF
    END IF

    !Take care of periodic boundary conditions east-west
    IF( ims_pro_i .EQ. (ims_npro_i-1)) THEN
      IF (nzone_east .NE. 0) THEN
        l_q(nzone_grid+nzone_west+1:nzone_grid+nzone_west+nzone_east,1) =&
          l_q(nzone_grid+nzone_west+1:nzone_grid+nzone_west+nzone_east,1)-x(imax_total)- dx_grid
      END IF
    END IF

  !#####################################################################
  ! Send/Recv of particles X-Direction
  !#####################################################################
      

    CALL PARTICLE_SEND_RECV(nzone_grid, nzone_west, nzone_east,nzone_south, nzone_north, 1,& 
                            p_buffer_1, p_buffer_2, l_hq, l_tags, l_q) 


  !#####################################################################
  !Particle sorting for Send/Recv Z-Direction
  !#####################################################################        

    CALL PARTICLE_SORT(x,z,nzone_grid, nzone_west, nzone_east,nzone_south,nzone_north,3,&
                         l_hq, l_tags, l_q)


!Take care of periodic boundary conditions north-south
    IF (ims_pro_k .EQ. 0) THEN
      IF (nzone_south .NE. 0) THEN
        l_q(nzone_grid+1:nzone_grid+nzone_south,3) = l_q(nzone_grid+1:nzone_grid+nzone_south,3) + z(kmax_total)+ dz_grid 
      END IF
    END IF


    IF( ims_pro_k .EQ. (ims_npro_k-1)) THEN
      IF (nzone_north .NE. 0) THEN
        l_q(nzone_grid+nzone_south+1:nzone_grid+nzone_south+nzone_north,3) =&
          l_q(nzone_grid+nzone_south+1:nzone_grid+nzone_south+nzone_north,3)-z(kmax_total)- dz_grid
      END IF
    END IF


  !#####################################################################
      ! Send/Recv of particles Z-Direction
  !#####################################################################
      

    CALL PARTICLE_SEND_RECV(nzone_grid, nzone_west, nzone_east,nzone_south, nzone_north, 3,& 
                            p_buffer_1, p_buffer_2, l_hq, l_tags, l_q)


#else

  !#######################################################################
  ! Particle new postion here!
  !#######################################################################
      
  DO i = 1,particle_number
    DO is = 1,inb_particle_evolution !coordinaes 1=x 2=y 3=z
     
      !Particle update
      l_q(i,is) = l_q(i,is) + dte*l_hq(i,is)
  
    ENDDO
  END DO
  !#######################################################################
  ! Move particle to other side of x-grid
  !#######################################################################
  dx_grid=scalex/imax_total  
  dz_grid=scalez/kmax_total  
  DO i = 1,particle_number
    IF (l_q(i,1) .GT. x(imax_total)+dx_grid) THEN
      l_q(i,1) = l_q(i,1) - x(imax_total) - dx_grid
    
    ELSEIF(l_q(i,1) .LT. x(1)) THEN
      l_q(i,1) = l_q(i,1) + x(imax_total) + dx_grid
    
    END IF
  
    IF (l_q(i,3) .GT. z(kmax_total)+dz_grid) THEN
      l_q(i,3) = l_q(i,3) - z(kmax_total) - dz_grid

    ELSEIF(l_q(i,3) .LT. z(1)) THEN
      l_q(i,3) = l_q(i,3) + z(kmax_total) + dz_grid

    END IF
  END DO
 
#endif
  RETURN
END SUBROUTINE PARTICLE_TIME_SUBSTEP
