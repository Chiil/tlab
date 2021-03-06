#include "types.h"
#include "dns_const.h"

!########################################################################
!# Tool/Library
!#
!########################################################################
!# HISTORY
!#
!# 2010/11/03 - J.P. Mellado
!#              Created
!#
!########################################################################
!# DESCRIPTION
!#
!# Calculate the boundary values of a field s.t. the normal derivative
!# is zero
!#
!# Routine format extracted from PARTIAL_Y
!#
!########################################################################
!# ARGUMENTS 
!#
!# ibc  In  BCs at jmin/jmax: 1, for Neumann/-
!#                            2, for -      /Neumann   
!#                            3, for Neumann/Neumann
!#
!########################################################################
SUBROUTINE BOUNDARY_BCS_NEUMANN_Y(imode_fdm,ibc, nx,ny,nz, dy, u, bcs_hb,bcs_ht, wrk1d,tmp1,tmp2)

  USE DNS_GLOBAL, ONLY : jmax_total

  IMPLICIT NONE

#include "integers.h"

  TINTEGER imode_fdm, nx,ny,nz, ibc
  TREAL, DIMENSION(jmax_total,*)                      :: dy
  TREAL, DIMENSION(nx*nz,ny),     TARGET, INTENT(IN)  :: u         ! they are transposed below
  TREAL, DIMENSION(nx*nz,ny),     TARGET              :: tmp1,tmp2 ! they are transposed below
  TREAL, DIMENSION(jmax_total,3), TARGET              :: wrk1d
  TREAL, DIMENSION(nx*nz),        TARGET, INTENT(OUT) :: bcs_hb,bcs_ht

! -------------------------------------------------------------------
  TINTEGER nxz, nxy

  TREAL, DIMENSION(:,:), POINTER :: p_org,p_dst
  TREAL, DIMENSION(:),   POINTER :: p_bcs_hb,p_bcs_ht
  TREAL, DIMENSION(:),   POINTER :: a,b,c

! ###################################################################
  IF ( jmax_total .EQ. 1 ) THEN ! Set to zero in 2D case
  bcs_hb = C_0_R; bcs_ht = C_0_R 

  ELSE
! ###################################################################
  nxy = nx*ny 
  nxz = nx*nz

  a => wrk1d(:,1)
  b => wrk1d(:,2)
  c => wrk1d(:,3)

! -------------------------------------------------------------------
! Make y  direction the last one
! -------------------------------------------------------------------
  IF ( nz .EQ. 1 ) THEN
     p_org => u
     p_dst => tmp1
     p_bcs_hb => bcs_hb
     p_bcs_ht => bcs_ht
  ELSE
#ifdef USE_ESSL
     CALL DGETMO(u, nxy, nxy, nz, tmp1, nz)
#else
     CALL DNS_TRANSPOSE(u, nxy, nz, nxy, tmp1, nz)
#endif
     p_org => tmp1
     p_dst => tmp2
     p_bcs_hb => tmp1(:,1)
     p_bcs_ht => tmp1(:,2)
  ENDIF

! ###################################################################
  IF      ( imode_fdm .eq. FDM_COM4_JACOBIAN ) THEN; !not yet implemented
  ELSE IF ( imode_fdm .eq. FDM_COM6_JACOBIAN ) THEN; CALL FDM_C1N6_BCS_LHS(ny,     ibc, dy, a,b,c)
                                                 CALL FDM_C1N6_BCS_RHS(ny,nxz, ibc,     p_org,p_dst)
  ELSE IF ( imode_fdm .eq. FDM_COM6_DIRECT   ) THEN; CALL FDM_C1N6_BCS_LHS(ny,     ibc, dy, a,b,c) ! not yet implemented
                                                 CALL FDM_C1N6_BCS_RHS(ny,nxz, ibc,     p_org,p_dst)
  ELSE IF ( imode_fdm .eq. FDM_COM6_DIRECT   ) THEN; !not yet implemented
  ENDIF
     
  IF      ( ibc .EQ. 1 ) THEN
     CALL TRIDFS(ny-1,     a(2),b(2),c(2))
     CALL TRIDSS(ny-1,nxz, a(2),b(2),c(2), p_dst(1,2))
     p_bcs_hb(:) = p_dst(:,1 ) + c(1) *p_dst(:,2)   

  ELSE IF ( ibc .EQ. 2 ) THEN
     CALL TRIDFS(ny-1,     a,b,c)
     CALL TRIDSS(ny-1,nxz, a,b,c, p_dst)
     p_bcs_ht(:) = p_dst(:,ny) + a(ny)*p_dst(:,ny-1)

  ELSE IF ( ibc .EQ. 3 ) THEN
     CALL TRIDFS(ny-2,     a(2),b(2),c(2))
     CALL TRIDSS(ny-2,nxz, a(2),b(2),c(2), p_dst(1,2))
     p_bcs_hb(:) = p_dst(:,1 ) + c(1) *p_dst(:,2)   
     p_bcs_ht(:) = p_dst(:,ny) + a(ny)*p_dst(:,ny-1)

  ENDIF

! ###################################################################
! -------------------------------------------------------------------
! Put bcs arrays in correct order
! -------------------------------------------------------------------
  IF ( nz .GT. 1 ) THEN
#ifdef USE_ESSL
     IF ( ibc .EQ. 1 .OR. ibc .EQ. 3 ) CALL DGETMO(p_bcs_hb, nz, nz, nx, bcs_hb, nx)
     IF ( ibc .EQ. 2 .OR. ibc .EQ. 3 ) CALL DGETMO(p_bcs_ht, nz, nz, nx, bcs_ht, nx)
#else
     IF ( ibc .EQ. 1 .OR. ibc .EQ. 3 ) CALL DNS_TRANSPOSE(p_bcs_hb, nz, nx, nz, bcs_hb, nx)
     IF ( ibc .EQ. 2 .OR. ibc .EQ. 3 ) CALL DNS_TRANSPOSE(p_bcs_ht, nz, nx, nz, bcs_ht, nx)
#endif
  ENDIF
  NULLIFY(p_org,p_dst,p_bcs_hb,p_bcs_ht,a,b,c)

  ENDIF

  RETURN
END SUBROUTINE BOUNDARY_BCS_NEUMANN_Y
