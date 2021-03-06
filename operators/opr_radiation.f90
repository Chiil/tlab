#include "types.h"
#include "dns_const.h"

!########################################################################
!# HISTORY
!#
!# 2011/08/29 - A de Lozar
!#              Created
!# 2013/12/20 - J.P. Mellado
!#              Cleaned
!#
!########################################################################
!# DESCRIPTION
!#
!# Calculate the radiation term assuming the 1D approximation and
!# using compact schemes to calculate the integral term.
!# 
!# It is supossed homogeneity in x,z directions and that field varies only in Oy direction
!# It needs one scalar array corresponding to the tracer field (smoke hypotesis) 
!# or to the liquid water concerntration field. 
!# Cloud is suposed to be on the bottom and infinitely large.
!# 
!# The transposition of arrays is case 2 (as in partial_y) is not used
!# because it would require an additional 3d auxiliary array.
!# The third case should be written in terms of flow_buoyancy to set
!# the nonlinear mapping between the scalar and the radiatively active
!# scalar. This would imply breaking this subroutine into two, one doing the
!# integral operation and a wrapper above; similar to the other operators,
!# like burgers.
!#
!########################################################################
SUBROUTINE OPR_RADIATION(iradiation, nx,ny,nz, dy, s1, param, &
     av_s, opt_path, wrk1d, rad)

  IMPLICIT NONE

#include "integers.h"

  TINTEGER,                   INTENT(IN)    :: iradiation, nx,ny,nz
  TREAL, DIMENSION(ny,*),     INTENT(IN)    :: dy
  TREAL, DIMENSION(nx,ny,nz), INTENT(IN)    :: s1       !Optically active scalar
  TREAL, DIMENSION(*),        INTENT(IN)    :: param    !Radiation Parameters
  TREAL, DIMENSION(ny),       INTENT(INOUT) :: av_s     !Averaged scalar (Working 1D array)
  TREAL, DIMENSION(ny),       INTENT(INOUT) :: opt_path !Optical path (Working 1D array)
  TREAL, DIMENSION(ny,5),     INTENT(INOUT) :: wrk1d    !Working array
  TREAL, DIMENSION(nx,ny,nz), INTENT(OUT)   :: rad      !Radiation in 3D

! -----------------------------------------------------------------------
  TINTEGER i,j,k, ibc
  TREAL delta_inv, dummy, dummy2

! #######################################################################
  ibc = 2 !Boundary condition at the top for integral calulation 

! Prepare the pentadiagonal system
  CALL INT_C1N6_LHS(ny,    ibc,     wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5))
  CALL PENTADFS(ny-1,               wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5))

  delta_inv = C_1_R/param(2)

! #######################################################################
! Averaged model (as described in de Lozar and Mellado JAS2013) 
! #######################################################################
  IF      ( iradiation .EQ. EQNS_RAD_BULK1D_GLOBAL ) THEN
!Step 1
     CALL AVG1V2D_V(nx,ny,nz, i1, s1, av_s, opt_path) !Calculate the averaged scalar. opt_path is only sent as working array. 

!Step 2. Calculate (negative) integral path.
     CALL INT_C1N6_RHS(ny,i1, ibc, dy, av_s, opt_path)
     CALL PENTADSS(ny-1,i1, wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5), opt_path)
     opt_path(ny) = C_0_R !BCs

!Step 3: Calculate radiation and put it onto the 3D array
     opt_path(1:ny) = param(1)*av_s(1:ny)*exp(opt_path(1:ny)*delta_inv)
     DO j = 1,ny
        rad(:,j,:) = opt_path(j)
     ENDDO

! #######################################################################
! Local columns, as in LES. 
! #######################################################################
  ELSE IF ( iradiation .EQ. EQNS_RAD_BULK1D_LOCAL ) THEN

!Step 2. Calculate (negative) integral path.
     DO k = 1,nz; DO i = 1,nx 
        av_s(1:ny) =  s1(i,1:ny,k)
        CALL INT_C1N6_RHS(ny,i1, ibc, dy, av_s, opt_path)
        CALL PENTADSS(ny-1,i1, wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5), opt_path)
        opt_path(ny) = C_0_R
        rad(i,1:ny,k) = opt_path(1:ny)
     ENDDO; ENDDO

!Step 3: Calculate radiation and put it onto the 3D array
     rad(1:nx,1:ny,1:nz) = param(1)*s1(1:nx,1:ny,1:nz)*exp(rad(1:nx,1:ny,1:nz)*delta_inv)

! #######################################################################
! Case 3. Mixed LES-av case. The optical path is an averaged value but the smoke is local.
! #######################################################################
  ELSE IF ( iradiation .EQ. EQNS_RAD_BULK1D_MIXED ) THEN
!Step 1
     CALL AVG1V2D_V(nx,ny,nz, i1, s1, av_s, opt_path) !Calculate the averaged scalar. opt_path is only sent as working array. 

!Step 2. Calculate (negative) integral path.
     CALL INT_C1N6_RHS(ny,i1, ibc, dy, av_s, opt_path)
     CALL PENTADSS(ny-1,i1, wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5), opt_path)
     opt_path(ny) = C_0_R

!Step 3: Calculate radiation and put it onto the 3D array
     opt_path(1:ny) = param(1)*exp(opt_path(1:ny)*delta_inv)
     DO j = 1,ny
        rad(:,j,:) = s1(:,j,:)*opt_path(j)
     ENDDO

! #######################################################################
! Same as case 2 but using only high concentrations of the smoke field for radiation (as the liquid)
! #######################################################################
  ELSE IF ( iradiation .EQ. EQNS_RAD_BULK1D_LOCAL_MAP ) THEN
     dummy = param(3)
     dummy2 = C_1_R-C_1_R/dummy

!Calculate optical path into rad using compact schemes at each column. It is calculated the negative integral path.
     DO  k = 1,nz  !Loop over x and z
        DO i = 1,nx 
           DO j = 1, ny
              av_s(j) =  MAX(dummy2+s1(i,j,k)/dummy,C_0_R)
           ENDDO
           CALL INT_C1N6_RHS(ny,i1, ibc, dy, av_s,opt_path)
           CALL PENTADSS(ny-1,i1, wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5), opt_path(1))
           opt_path(ny) = C_0_R
           rad(i,1:ny,k) = param(1)*av_s(1:ny)*exp(opt_path(1:ny)*delta_inv)
        ENDDO
     ENDDO

! #######################################################################
! Same as case 3 but using only high concentrations of the smoke field for radiation (as the liquid)
! #######################################################################
  ELSE IF ( iradiation .EQ. EQNS_RAD_BULK1D_MIXED_MAP ) THEN
     dummy = param(3)
     dummy2 = C_1_R-C_1_R/dummy
!Step 0. Remap the field into the working array
     DO i = 1,nx
        DO j = 1,ny
           DO k = 1,nz
              rad(i,j,k) = MAX(dummy2+ s1(i,j,k)/dummy,C_0_R)
           ENDDO
        ENDDO
     ENDDO

!Step 1
     CALL AVG1V2D_V(nx,ny,nz, i1, rad, av_s, opt_path) !Calculate the averaged scalar. opt_path is only sent as working array. 

!Step 2. Calculate optical path using compact schemes. It is calculated the negative integral path.
     CALL INT_C1N6_RHS(ny,i1, ibc, dy, av_s,opt_path)
!Set the boundary condition
     CALL PENTADSS(ny-1,i1, wrk1d(1,1),wrk1d(1,2),wrk1d(1,3),wrk1d(1,4),wrk1d(1,5), opt_path(1))
     opt_path(ny) = C_0_R; !w_n   = w_n + u(imax) ! BCs

!Step 3: Calculate radiation and put it onto the 3D array
     DO j = 1,ny
        rad(:,j,:) = param(1)*rad(:,j,:)*exp(opt_path(j)*delta_inv)
     ENDDO

  ENDIF

  RETURN
END SUBROUTINE OPR_RADIATION

