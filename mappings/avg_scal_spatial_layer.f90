!########################################################################
!# Tool/Library
!#
!########################################################################
!# HISTORY
!#
!# 2000/09/25 - J.P. Mellado
!#              Created
!# 2008/01/11 - J.P. Mellado
!#              Cleaned
!#
!########################################################################
!# DESCRIPTION
!#
!# Post-processing statistical data accumulated in mean1d. Based on 
!# mappings define in file avgij_map.h
!#
!########################################################################
!# ARGUMENTS 
!#
!# itxc    In     size of array stat
!#
!########################################################################
#include "types.h"
#include "dns_error.h"
#include "dns_const.h"
#include "avgij_map.h"

SUBROUTINE AVG_SCAL_SPATIAL_LAYER(is, itxc, jmin_loc,jmax_loc, x,y,dy, mean1d, mean1d_sc, stat, wrk1d)

  USE DNS_CONSTANTS, ONLY : efile
  USE DNS_GLOBAL

  IMPLICIT NONE

#include "integers.h"

  TINTEGER is, itxc, jmin_loc,jmax_loc
  TREAL, DIMENSION(*)                :: x, y, dy, wrk1d
  TREAL, DIMENSION(nstatavg,jmax,*)  :: mean1d, mean1d_sc, stat

! -------------------------------------------------------------------
#define rU(A,B)     stat(A,B,1)
#define rV(A,B)     stat(A,B,2)
#define rW(A,B)     stat(A,B,3)
#define rR(A,B)     stat(A,B,4)
#define rS(A,B)     stat(A,B,5)
#define rSf2(A,B)   stat(A,B,6)
#define rUfSf(A,B)  stat(A,B,7)
#define rVfSf(A,B)  stat(A,B,8)
#define rWfSf(A,B)  stat(A,B,9)

#define fU(A,B)     stat(A,B,10)
#define fV(A,B)     stat(A,B,11)
#define fW(A,B)     stat(A,B,12)
#define fS(A,B)     stat(A,B,13)
#define fRss(A,B)   stat(A,B,14)
#define fRus(A,B)   stat(A,B,15)
#define fRvs(A,B)   stat(A,B,16)
#define fRws(A,B)   stat(A,B,17)

#define Conv_ss(A,B)     stat(A,B,18)
#define Prod_ss(A,B)     stat(A,B,19)
#define Diss_ss(A,B)     stat(A,B,20)
#define Tran_ss(A,B)     stat(A,B,21)
#define MnFl_ss(A,B)     stat(A,B,22)
#define Resi_ss(A,B)     stat(A,B,23)

#define SimS(A,B)        stat(A,B,24)
#define SimRss(A,B)      stat(A,B,25)

#define dRssdx(A,B)      stat(A,B,26)
#define dRssdy(A,B)      stat(A,B,27)
#define dRdx(A,B)        stat(A,B,28)
#define dRdy(A,B)        stat(A,B,29)
#define fdSdx(A,B)       stat(A,B,30)
#define fdSdy(A,B)       stat(A,B,31)

#define Tuss(A,B)        stat(A,B,32)
#define Tvss(A,B)        stat(A,B,33)
#define Twss(A,B)        stat(A,B,34)
#define dTussdx(A,B)     stat(A,B,35)
#define dTvssdy(A,B)     stat(A,B,36)
#define fdUdx(A,B)       stat(A,B,37)
#define fdVdy(A,B)       stat(A,B,38)
#define Tsfx(A,B)        stat(A,B,39)
#define Tsfy(A,B)        stat(A,B,40)
#define Tran_ss_vis(A,B) stat(A,B,41)

#define dRusdx(A,B)      stat(A,B,42)
#define dRusdy(A,B)      stat(A,B,43)
#define dRvsdx(A,B)      stat(A,B,44)
#define dRvsdy(A,B)      stat(A,B,45)
#define dRwsdx(A,B)      stat(A,B,46)
#define dRwsdy(A,B)      stat(A,B,47)

#define Conv_us(A,B)     stat(A,B,48)
#define Prod_us(A,B)     stat(A,B,49)
#define Diss_us(A,B)     stat(A,B,50)
#define Tran_us(A,B)     stat(A,B,51)
#define MnFl_us1(A,B)    stat(A,B,52)
#define Resi_us(A,B)     stat(A,B,53)

#define Conv_vs(A,B)     stat(A,B,54)
#define Prod_vs(A,B)     stat(A,B,55)
#define Diss_vs(A,B)     stat(A,B,56)
#define Tran_vs(A,B)     stat(A,B,57)
#define MnFl_vs1(A,B)    stat(A,B,58)
#define Resi_vs(A,B)     stat(A,B,59)

#define Conv_ws(A,B)     stat(A,B,60)
#define Prod_ws(A,B)     stat(A,B,61)
#define Diss_ws(A,B)     stat(A,B,62)
#define Tran_ws(A,B)     stat(A,B,63)
#define MnFl_ws1(A,B)    stat(A,B,64)
#define Resi_ws(A,B)     stat(A,B,65)

#define fdUdy(A,B)       stat(A,B,66)
#define fdVdx(A,B)       stat(A,B,67)
#define fdWdx(A,B)       stat(A,B,68)
#define fdWdy(A,B)       stat(A,B,69)

#define fRuu(A,B)        stat(A,B,70)
#define fRvv(A,B)        stat(A,B,71)
#define fRww(A,B)        stat(A,B,72)
#define fRuv(A,B)        stat(A,B,73)
#define fRuw(A,B)        stat(A,B,74)
#define fRvw(A,B)        stat(A,B,75)

#define SimRus(A,B)      stat(A,B,76)
#define SimRvs(A,B)      stat(A,B,77)
#define SimRws(A,B)      stat(A,B,78)

#define Press_us(A,B)    stat(A,B,79)
#define Press_vs(A,B)    stat(A,B,80)
#define Press_ws(A,B)    stat(A,B,81)

#define Tuus(A,B)        stat(A,B,82)
#define Tvvs(A,B)        stat(A,B,83)
#define Twws(A,B)        stat(A,B,84)
#define Tuvs(A,B)        stat(A,B,85)
#define Tuws(A,B)        stat(A,B,86)
#define Tvws(A,B)        stat(A,B,87)

#define dTuusdx(A,B)     stat(A,B,88)
#define dTuvsdx(A,B)     stat(A,B,89)
#define dTuwsdx(A,B)     stat(A,B,90)
#define dTuvsdy(A,B)     stat(A,B,91)
#define dTvvsdy(A,B)     stat(A,B,92)
#define dTvwsdy(A,B)     stat(A,B,93)

#define Tran_us_vis(A,B) stat(A,B,94)
#define Tran_vs_vis(A,B) stat(A,B,95)
#define Tran_ws_vis(A,B) stat(A,B,96)
#define rdUdx(A,B)       stat(A,B,97)
#define rdUdy(A,B)       stat(A,B,98)
#define rdVdx(A,B)       stat(A,B,99)
#define rdVdy(A,B)       stat(A,B,100)
#define rdWdx(A,B)       stat(A,B,101)
#define rdWdy(A,B)       stat(A,B,102)

#define Tran_us_p(A,B)   stat(A,B,103)
#define Tran_vs_p(A,B)   stat(A,B,104)
#define Tran_ws_p(A,B)   stat(A,B,105)
#define rdSdx(A,B)       stat(A,B,106)
#define rdSdy(A,B)       stat(A,B,107)

#define MnFl_us2(A,B)     stat(A,B,108)
#define MnFl_vs2(A,B)     stat(A,B,109)
#define MnFl_ws2(A,B)     stat(A,B,110)

#define Conv_s(A,B)       stat(A,B,111)
#define Tran_s(A,B)       stat(A,B,112)
#define Reyn_s(A,B)       stat(A,B,113)
#define Resi_s(A,B)       stat(A,B,114)

#define Gamma_s(A,B)      stat(A,B,115)
#define S_s(A,B)          stat(A,B,116)
#define F_s(A,B)          stat(A,B,117)

#define LAST_INDEX 118

#define delta_s_u(A)      stat(A,1,LAST_INDEX)
#define delta_s_d(A)      stat(A,2,LAST_INDEX)
#define SimSC(A)          stat(A,3,LAST_INDEX)
#define delta_s_center(A) stat(A,4,LAST_INDEX)
#define delta_05_u(A)     stat(A,5,LAST_INDEX)
#define delta_05_d(A)     stat(A,6,LAST_INDEX)
#define IntExcScaS(A)     stat(A,7,LAST_INDEX)
#define IntExcScaRsu(A)   stat(A,8,LAST_INDEX)

#define VARMX1D 8

  TINTEGER i, j, k, n
  TREAL pts, c13, eps
  TREAL SIMPSON_NU
  TREAL S2, DS, aux1, U2, DU
  TREAL y_center, r05
  TREAL delta_s, delta_05
  TINTEGER jloc_max(1)

  TREAL  VAUXPRE(4), VAUXPOS(6)
  TINTEGER ivauxpre, ivauxpos, ivauxdum
  CHARACTER*32 name, str
  CHARACTER*250 line1
  CHARACTER*2750 line2

! ###################################################################
#ifdef TRACE_ON
  CALL IO_WRITE_ASCII(tfile, 'ENTERING AVG_SCAL_SPATIAL_LAYER' )
#endif

  c13 = C_1_R/C_3_R
  r05 = C_05_R

  if ( nstatavg_points .EQ. 0 ) then
     CALL IO_WRITE_ASCII(efile,'AVG_SCAL_SPATIAL_LAYER: Zero number of points')
     CALL DNS_STOP(DNS_ERROR_STATZERO)
  ELSE
     pts = C_1_R/M_REAL(nstatavg_points)
  endif

  eps = visc/schmidt(is)

  IF ( itxc .LT. nstatavg*jmax*LAST_INDEX ) THEN
     CALL IO_WRITE_ASCII(efile,'AVG_SCAL_SPATIAL_LAYER: Not enough space in stat')
     CALL DNS_STOP(DNS_ERROR_WRKSIZE)
  ENDIF

! ###################################################################
! Main loop
! ###################################################################
  DO j = 1,jmax*nstatavg

! ###################################################################
! Reynolds Averages
! ###################################################################
     rU(j,1) = MA_U(j)*pts
     rV(j,1) = MA_V(j)*pts
     rW(j,1) = MA_W(j)*pts
     rR(j,1) = MA_R(j)*pts
     rS(j,1) = MS_S(j)*pts

     rSf2(j,1) = MS_S2(j)*pts - rS(j,1)*rS(j,1)
     rUfSf(j,1)= MS_SU(j)*pts - rU(j,1)*rS(j,1)
     rVfSf(j,1)= MS_SV(j)*pts - rV(j,1)*rS(j,1)
     rWfSf(j,1)= MS_SW(j)*pts - rW(j,1)*rS(j,1)

! ###################################################################
! Favre Averages
! ###################################################################
     fU(j,1) = MA_RU(j)*pts/rR(j,1)
     fV(j,1) = MA_RV(j)*pts/rR(j,1)
     fW(j,1) = MA_RW(j)*pts/rR(j,1)
     fS(j,1) = MS_RS(j)*pts/rR(j,1)

     fRss(j,1) = MS_RSS(j)*pts/rR(j,1) - fS(j,1)*fS(j,1)

     fRus(j,1)= MS_RSU(j)*pts/rR(j,1) - fU(j,1)*fS(j,1)
     fRvs(j,1)= MS_RSV(j)*pts/rR(j,1) - fV(j,1)*fS(j,1)
     fRws(j,1)= MS_RSW(j)*pts/rR(j,1) - fW(j,1)*fS(j,1)

     fRuu(j,1)= MA_RUU(j)*pts/rR(j,1) - fU(j,1)*fU(j,1)
     fRvv(j,1)= MA_RVV(j)*pts/rR(j,1) - fV(j,1)*fV(j,1)
     fRww(j,1)= MA_RWW(j)*pts/rR(j,1) - fW(j,1)*fW(j,1)
     fRuv(j,1)= MA_RUV(j)*pts/rR(j,1) - fU(j,1)*fV(j,1)
     fRuw(j,1)= MA_RUW(j)*pts/rR(j,1) - fU(j,1)*fW(j,1)
     fRvw(j,1)= MA_RVW(j)*pts/rR(j,1) - fW(j,1)*fV(j,1)

     Tuss(j,1) = ( MS_RUSS(j)-C_2_R*MS_RSU(j)*fS(j,1)-MS_RSS(j)*fU(j,1) )*pts&
          + C_2_R*rR(j,1)*fU(j,1)*fS(j,1)**2
     Tvss(j,1) = ( MS_RVSS(j)-C_2_R*MS_RSV(j)*fS(j,1)-MS_RSS(j)*fV(j,1) )*pts&
          + C_2_R*rR(j,1)*fV(j,1)*fS(j,1)**2
     Twss(j,1) = ( MS_RWSS(j)-C_2_R*MS_RSW(j)*fS(j,1)-MS_RSS(j)*fW(j,1) )*pts&
          + C_2_R*rR(j,1)*fW(j,1)*fS(j,1)**2

     Tsfx(j,1) = eps*C_2_R*(MS_SFx(j)-MS_S(j)*MS_Fx(j)*pts)*pts
     Tsfy(j,1) = eps*C_2_R*(MS_SFy(j)-MS_S(j)*MS_Fy(j)*pts)*pts

! ###################################################################
! First derivative terms (Reynolds)
! ###################################################################
     dRdx(j,1) = MA_Rx(j)*pts
     dRdy(j,1) = MA_Ry(j)*pts

     rdSdx(j,1) = MS_Sx(j)*pts
     rdSdy(j,1) = MS_Sy(j)*pts

     rdUdx(j,1) = MA_Ux(j)*pts
     rdUdy(j,1) = MA_Uy(j)*pts
     rdVdx(j,1) = MA_Vx(j)*pts
     rdVdy(j,1) = MA_Vy(j)*pts
     rdWdx(j,1) = MA_Wx(j)*pts
     rdWdy(j,1) = MA_Wy(j)*pts

! ###################################################################
! First derivative terms (Favre)
! ###################################################################
     fdSdx(j,1) = ((MS_RSx(j) + MS_SRx(j))*pts - fS(j,1)*dRdx(j,1))/rR(j,1)
     fdSdy(j,1) = ((MS_RSy(j) + MS_SRy(j))*pts - fS(j,1)*dRdy(j,1))/rR(j,1)

     fdUdx(j,1) = ((MA_RUx(j) + MA_URx(j))*pts - fU(j,1)*dRdx(j,1))/rR(j,1)
     fdUdy(j,1) = ((MA_RUy(j) + MA_URy(j))*pts - fU(j,1)*dRdy(j,1))/rR(j,1)
     fdVdx(j,1) = ((MA_RVx(j) + MA_VRx(j))*pts - fV(j,1)*dRdx(j,1))/rR(j,1)
     fdVdy(j,1) = ((MA_RVy(j) + MA_VRy(j))*pts - fV(j,1)*dRdy(j,1))/rR(j,1)
     fdWdx(j,1) = ((MA_RWx(j) + MA_WRx(j))*pts - fW(j,1)*dRdx(j,1))/rR(j,1)
     fdWdy(j,1) = ((MA_RWy(j) + MA_WRy(j))*pts - fW(j,1)*dRdy(j,1))/rR(j,1)

! ###################################################################
! Derivatives of the Reynolds stresses
! ###################################################################
     dRssdx(j,1) = (MS_RSSx(j) - MS_RSS(j)/rR(j,1)*dRdx(j,1))*pts/rR(j,1) &
          - C_2_R*fS(j,1)*fdSdx(j,1)
     dRssdy(j,1) = (MS_RSSy(j) - MS_RSS(j)/rR(j,1)*dRdy(j,1))*pts/rR(j,1) &
          - C_2_R*fS(j,1)*fdSdy(j,1)
     dRusdx(j,1) = (MS_RSUx(j) - MS_RSU(j)/rR(j,1)*dRdx(j,1))*pts/rR(j,1) &
          - fdUdx(j,1)*fS(j,1) - fU(j,1)*fdSdx(j,1)
     dRusdy(j,1) = (MS_RSUy(j) - MS_RSU(j)/rR(j,1)*dRdy(j,1))*pts/rR(j,1) &
          - fdUdy(j,1)*fS(j,1) - fU(j,1)*fdSdy(j,1)
     dRvsdx(j,1) = (MS_RSVx(j) - MS_RSV(j)/rR(j,1)*dRdx(j,1))*pts/rR(j,1) &
          - fdVdx(j,1)*fS(j,1) - fV(j,1)*fdSdx(j,1)
     dRvsdy(j,1) = (MS_RSVy(j) - MS_RSV(j)/rR(j,1)*dRdy(j,1))*pts/rR(j,1) &
          - fdVdy(j,1)*fS(j,1) - fV(j,1)*fdSdy(j,1)
     dRwsdx(j,1)=  (MS_RSWx(j) - MS_RSW(j)/rR(j,1)*dRdx(j,1))*pts/rR(j,1) &
          - fdWdx(j,1)*fS(j,1) - fW(j,1)*fdSdx(j,1)
     dRwsdy(j,1) = (MS_RSWy(j) - MS_RSW(j)/rR(j,1)*dRdy(j,1))*pts/rR(j,1) &
          - fdWdy(j,1)*fS(j,1) - fW(j,1)*fdSdy(j,1)

! ###################################################################
! Transport equations
! ###################################################################
! -------------------------------------------------------------------
! Mean equation budget
! -------------------------------------------------------------------
     Conv_s(j,1) = -fU(j,1)*fdSdx(j,1) - fV(j,1)*fdSdy(j,1)
     Tran_s(j,1) = eps*(MS_Fxx(j)+ MS_Fyy(j))/MA_R(j)
     Reyn_s(j,1) =-dRusdx(j,1)-dRvsdy(j,1)-&
          ( fRus(j,1)*dRdx(j,1) + fRvs(j,1)*dRdy(j,1) )/rR(j,1)

     Resi_s(j,1) = Conv_s(j,1) + Tran_s(j,1) + Reyn_s(j,1)

! -------------------------------------------------------------------
! Rss Reynolds stress equation
! -------------------------------------------------------------------
! Convective element of transport term of Reynolds equations
     dTussdx(j,1) = ( MS_RSSUx(j)-C_2_R*MS_RSUx(j)*fS(j,1)-C_2_R*MS_RSU(j)*fdSdx(j,1)&
          -MS_RSSx(j)*fU(j,1)-MS_RSS(j)*fdUdx(j,1) )*pts&
          + C_2_R*dRdx(j,1)*fU(j,1)*fS(j,1)**2&
          + C_2_R*rR(j,1)*fdUdx(j,1)*fS(j,1)**2&
          + C_4_R*rR(j,1)*fU(j,1)*fS(j,1)*fdSdx(j,1)

     dTvssdy(j,1) = (MS_RSSVy(j)-C_2_R*MS_RSVy(j)*fS(j,1)-C_2_R*MS_RSV(j)*fdSdy(j,1)&
          -MS_RSSy(j)*fV(j,1)-MS_RSS(j)*fdVdy(j,1) )*pts&
          + C_2_R*dRdy(j,1)*fV(j,1)*fS(j,1)**2&
          + C_2_R*rR(j,1)*fdVdy(j,1)*fS(j,1)**2&
          + C_4_R*rR(j,1)*fV(j,1)*fS(j,1)*fdSdy(j,1)

! Viscous element of transport term of Reynolds equations
     Tran_ss_vis(j,1) = eps*C_2_R*( MS_FkdkS(j)+MS_SEPS(j) -&
          ( rdSdx(j,1)*MS_Fx(j) + rS(j,1)*MS_Fxx(j) &
          + rdSdy(j,1)*MS_Fy(j) + rS(j,1)*MS_Fyy(j)) )*pts/rR(j,1)

     Conv_ss(j,1) =-fU(j,1)*dRssdx(j,1)-fV(j,1)*dRssdy(j,1)
     Prod_ss(j,1) =-C_2_R*(fRus(j,1)*fdSdx(j,1) + fRvs(j,1)*fdSdy(j,1))
     Tran_ss(j,1) =-(dTussdx(j,1) + dTvssdy(j,1))/rR(j,1) + Tran_ss_vis(j,1)
     Diss_ss(j,1) =-eps*C_2_R*( MS_SEPS(j)-(MS_Fx(j)*rdSdx(j,1)+MS_Fy(j)*rdSdy(j,1)) )*pts/rR(j,1)
     MnFl_ss(j,1) = C_2_R*(rS(j,1)-fS(j,1))*eps*(MS_Fxx(j)+MS_Fyy(j))*pts/rR(j,1)

     Resi_ss(j,1) = Conv_ss(j,1) + Prod_ss(j,1) + Tran_ss(j,1) + Diss_ss(j,1) + MnFl_ss(j,1)

! -------------------------------------------------------------------
! Ris Reynolds stress equation
! -------------------------------------------------------------------
     Conv_us(j,1) = -fU(j,1)*dRusdx(j,1) - fV(j,1)*dRusdy(j,1)
     Conv_vs(j,1) = -fU(j,1)*dRvsdx(j,1) - fV(j,1)*dRvsdy(j,1)
     Conv_ws(j,1) = -fU(j,1)*dRwsdx(j,1) - fV(j,1)*dRwsdy(j,1)

     Prod_us(j,1) = -(fRuu(j,1)*fdSdx(j,1)+fRuv(j,1)*fdSdy(j,1)&
          +fRus(j,1)*fdUdx(j,1)+fRvs(j,1)*fdUdy(j,1))
     Prod_vs(j,1) = -(fRuv(j,1)*fdSdx(j,1)+fRvv(j,1)*fdSdy(j,1)&
          +fRus(j,1)*fdVdx(j,1)+fRvs(j,1)*fdVdy(j,1))
     Prod_ws(j,1) = -(fRuw(j,1)*fdSdx(j,1)+fRvw(j,1)*fdSdy(j,1)&
          +fRus(j,1)*fdWdx(j,1)+fRvs(j,1)*fdWdy(j,1))

     Diss_us(j,1) =-( eps*(MS_FkUk(j) -(MS_Fx(j)*rdUdx(j,1) +  MS_Fy(j)*rdUdy(j,1)))&
          + (MS_TAUxkSk(j) - (MA_TAUxx(j)*rdSdx(j,1) +  MA_TAUxy(j)*rdSdy(j,1))) )*pts/rR(j,1)
     Diss_vs(j,1) =-( eps*(MS_FkVk(j) -(MS_Fx(j)*rdVdx(j,1) +  MS_Fy(j)*rdVdy(j,1))) &
          + (MS_TAUykSk(j) - (MA_TAUxy(j)*rdSdx(j,1) +  MA_TAUyy(j)*rdSdy(j,1))) )*pts/rR(j,1)
     Diss_ws(j,1) =-( eps*( MS_FkWk(j) -(MS_Fx(j)*rdWdx(j,1) +  MS_Fy(j)*rdWdy(j,1))) &
          + (MS_TAUzkSk(j) - (MA_TAUxz(j)*rdSdx(j,1) +  MA_TAUyz(j)*rdSdy(j,1))) )*pts/rR(j,1)

     Press_us(j,1) = ( MS_PSx(j) - MA_P(j)*rdSdx(j,1) )*pts/rR(j,1)
     Press_vs(j,1) = ( MS_PSy(j) - MA_P(j)*rdSdy(j,1) )*pts/rR(j,1)
     Press_ws(j,1) = MS_PSz(j)*pts/rR(j,1)

! Convective element of transport term of Reynolds equations
     Tuus(j,1) = ( MS_RUUS(j)-MS_RSU(j)*fU(j,1)-MA_RUU(j)*fS(j,1) - MS_RSU(j)*fU(j,1) )*pts &
          + C_2_R*rR(j,1)*fU(j,1)*fU(j,1)*fS(j,1)
     Tvvs(j,1) = ( MS_RVVS(j)-MS_RSV(j)*fV(j,1)-MA_RVV(j)*fS(j,1) - MS_RSV(j)*fV(j,1) )*pts &
          + C_2_R*rR(j,1)*fV(j,1)*fV(j,1)*fS(j,1)
     Twws(j,1) = ( MS_RWWS(j)-MS_RSW(j)*fW(j,1)-MA_RWW(j)*fS(j,1) - MS_RSW(j)*fW(j,1) )*pts &
          + C_2_R*rR(j,1)*fW(j,1)*fW(j,1)*fS(j,1)
     Tuvs(j,1) = (MS_RUVS(j)-MS_RSU(j)*fV(j,1)-MA_RUV(j)*fS(j,1)  - MS_RSV(j)*fU(j,1) )*pts &
          + C_2_R*rR(j,1)*fU(j,1)*fV(j,1)*fS(j,1)
     Tuws(j,1) = (MS_RUWS(j)-MS_RSU(j)*fW(j,1)-MA_RUW(j)*fS(j,1)  - MS_RSW(j)*fU(j,1) )*pts &
          + C_2_R*rR(j,1)*fU(j,1)*fW(j,1)*fS(j,1)
     Tvws(j,1) = (MS_RVWS(j)-MS_RSV(j)*fW(j,1)-MA_RVW(j)*fS(j,1)  - MS_RSW(j)*fV(j,1) )*pts &
          + C_2_R*rR(j,1)*fV(j,1)*fW(j,1)*fS(j,1)

     dTuusdx(j,1) = ( MS_RUUSx(j)-MS_RSUx(j)*fU(j,1)-MS_RSU(j)*fdUdx(j,1)&
          -MA_RUUx(j)*fS(j,1)-MA_RUU(j)*fdSdx(j,1)-MS_RSUx(j)*fU(j,1)&
          -MS_RSU(j)*fdUdx(j,1) )*pts&
          +C_2_R*dRdx(j,1)*fU(j,1)*fU(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdUdx(j,1)*fU(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fdUdx(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fU(j,1)*fdSdx(j,1)
     dTuvsdx(j,1) = ( MS_RUVSx(j)-MS_RSUx(j)*fV(j,1)-MS_RSU(j)*fdVdx(j,1)&
          -MA_RUVx(j)*fS(j,1)-MA_RUV(j)*fdSdx(j,1)-MS_RSVx(j)*fU(j,1)&
          -MS_RSV(j)*fdUdx(j,1) )*pts&
          +C_2_R*dRdx(j,1)*fU(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdUdx(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fdVdx(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fV(j,1)*fdSdx(j,1)
     dTuwsdx(j,1) = ( MS_RUWSx(j)-MS_RSUx(j)*fW(j,1)-MS_RSU(j)*fdWdx(j,1)&
          -MA_RUWx(j)*fS(j,1)-MA_RUW(j)*fdSdx(j,1)-MS_RSWx(j)*fU(j,1)&
          -MS_RSW(j)*fdUdx(j,1) )*pts&
          +C_2_R*dRdx(j,1)*fU(j,1)*fW(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdUdx(j,1)*fW(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fdWdx(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fW(j,1)*fdSdx(j,1)
     dTuvsdy(j,1) = ( MS_RUVSy(j)-MS_RSUy(j)*fV(j,1)-MS_RSU(j)*fdVdy(j,1)&
          -MA_RUVy(j)*fS(j,1)-MA_RUV(j)*fdSdy(j,1)-MS_RSVy(j)*fU(j,1)&
          -MS_RSV(j)*fdUdy(j,1) )*pts&
          +C_2_R*dRdy(j,1)*fU(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdUdy(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fdVdy(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fU(j,1)*fV(j,1)*fdSdy(j,1)
     dTvvsdy(j,1) = ( MS_RVVSy(j)-MS_RSVy(j)*fV(j,1)-MS_RSV(j)*fdVdy(j,1)&
          -MA_RVVy(j)*fS(j,1)-MA_RVV(j)*fdSdy(j,1)-MS_RSVy(j)*fV(j,1)&
          -MS_RSV(j)*fdVdy(j,1) )*pts&
          +C_2_R*dRdy(j,1)*fV(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdVdy(j,1)*fV(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fV(j,1)*fdVdy(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fV(j,1)*fV(j,1)*fdSdy(j,1)
     dTvwsdy(j,1) = ( MS_RVWSy(j)-MS_RSVy(j)*fW(j,1)-MS_RSV(j)*fdWdy(j,1)&
          -MA_RVWy(j)*fS(j,1)-MA_RVW(j)*fdSdy(j,1)-MS_RSWy(j)*fV(j,1)&
          -MS_RSW(j)*fdVdy(j,1) )*pts&
          +C_2_R*dRdy(j,1)*fV(j,1)*fW(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fdVdy(j,1)*fW(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fV(j,1)*fdWdy(j,1)*fS(j,1)&
          +C_2_R*rR(j,1)*fV(j,1)*fW(j,1)*fdSdy(j,1)

! Viscous element of transport term of Reynolds equations
     Tran_us_vis(j,1)= (eps*(MS_FkUk(j)-rdUdx(j,1)*MS_Fx(j)-rdUdy(j,1)*MS_Fy(j)&
          +MS_FkdkU(j)-rU(j,1)*(MS_Fxx(j)+MS_Fyy(j)))*pts)/rR(j,1)
     Tran_vs_vis(j,1)= (eps*(MS_FkVk(j)-rdVdx(j,1)*MS_Fx(j)-rdVdy(j,1)*MS_Fy(j)&
          +MS_FkdkV(j)-rV(j,1)*(MS_Fxx(j)+MS_Fyy(j)))*pts)/rR(j,1)
     Tran_ws_vis(j,1)= (eps*(MS_FkWk(j)-rdWdx(j,1)*MS_Fx(j)-rdWdy(j,1)*MS_Fy(j)&
          +MS_FkdkW(j)-rW(j,1)*(MS_Fxx(j)+MS_Fyy(j)))*pts)/rR(j,1)

     Tran_us_vis(j,1) = Tran_us_vis(j,1) + (&
          ( MS_TAUxkSk(j) - (MA_TAUxx(j)*rdSdx(j,1) +  MA_TAUxy(j)*rdSdy(j,1))&
          + MS_STAUxkk(j)  - rS(j,1)*(MS_TAUxxx(j) +  MS_TAUxyy(j)) )*pts )/rR(j,1)

     Tran_vs_vis(j,1) = Tran_vs_vis(j,1) + (&
          ( MS_TAUykSk(j) - (MA_TAUxy(j)*rdSdx(j,1) +  MA_TAUyy(j)*rdSdy(j,1))&
          + MS_STAUykk(j) - rS(j,1)*(MS_TAUxyx(j) +  MS_TAUyyy(j)) )*pts )/rR(j,1)

     Tran_ws_vis(j,1) = Tran_ws_vis(j,1) + (&
          ( MS_TAUzkSk(j) - (MA_TAUxz(j)*rdSdx(j,1) +  MA_TAUyz(j)*rdSdy(j,1))&
          + MS_STAUzkk(j) - rS(j,1)*(MS_TAUxzx(j) +  MS_TAUyzy(j)) )*pts )/rR(j,1)

     Tran_us_p(j,1) = ( (MS_PSx(j)-MA_P(j)*rdSdx(j,1)&
          + MS_SPx(j)-rS(j,1)*MA_Px(j))*pts)/rR(j,1)
     Tran_vs_p(j,1) = ( (MS_PSy(j)-MA_P(j)*rdSdy(j,1)&
          + MS_SPy(j)-rS(j,1)*MA_Py(j))*pts)/rR(j,1)
     Tran_ws_p(j,1) = C_0_R

! transport term of Reynolds equations
     Tran_us(j,1) =-( (dTuusdx(j,1) + dTuvsdy(j,1))/rR(j,1) - Tran_us_vis(j,1) + Tran_us_p(j,1) )
     Tran_vs(j,1) =-( (dTuvsdx(j,1) + dTvvsdy(j,1))/rR(j,1) - Tran_vs_vis(j,1) + Tran_vs_p(j,1) )
     Tran_ws(j,1) =-( (dTuwsdx(j,1) + dTvwsdy(j,1))/rR(j,1) - Tran_ws_vis(j,1) + Tran_ws_p(j,1) )

! mean flux terms
     aux1 = (eps*(MS_Fxx(j)+MS_Fyy(j))*pts)/rR(j,1)

     MnFl_us1(j,1) = (rS(j,1)-fS(j,1))*(-MA_Px(j)+MA_TAUXkk(j))*pts/rR(j,1)
     MnFl_us2(j,1) = (rU(j,1)-fU(j,1))*aux1

     MnFl_vs1(j,1) = (rS(j,1)-fS(j,1))*(-MA_Py(j)+MA_TAUYkk(j))*pts/rR(j,1)
     MnFl_vs2(j,1) = (rV(j,1)-fV(j,1))*aux1

     MnFl_ws1(j,1) = (rS(j,1)-fS(j,1))*(MA_TAUZkk(j))*pts/rR(j,1)
     MnFl_ws2(j,1) = (rW(j,1)-fW(j,1))*aux1

! residual terms
     Resi_us(j,1) = Conv_us(j,1) + Prod_us(j,1) + Tran_us(j,1)&
          + Diss_us(j,1) + Press_us(j,1) + MnFl_us1(j,1) + MnFl_us2(j,1)

     Resi_vs(j,1) = Conv_vs(j,1) + Prod_vs(j,1) + Tran_vs(j,1)&
          + Diss_vs(j,1) + Press_vs(j,1) + MnFl_vs1(j,1) + MnFl_vs2(j,1)

     Resi_ws(j,1) = Conv_ws(j,1) + Prod_ws(j,1) + Tran_ws(j,1) &
          + Diss_ws(j,1) + Press_ws(j,1) + MnFl_ws1(j,1) + MnFl_ws2(j,1)

! ###################################################################
! Intermittency
! ###################################################################
     Gamma_s(j,1) = MS_GAMMA(j)*pts

! ###################################################################
! Skewness and flatness
! ###################################################################
     S_s(j,1) = MS_S3(j)*pts-rS(j,1)**C_3_R-C_3_R*rS(j,1)*rSf2(j,1)
     F_s(j,1) = MS_S4(j)*pts-rS(j,1)**C_4_R-C_4_R*rS(j,1)*S_s(j,1)-&
          C_6_R*rS(j,1)**C_2_R*rSf2(j,1)

! Normalization
     S_s(j,1) = S_s(j,1)/(rSf2(j,1)+C_1EM6_R)**(C_3_R/C_2_R)
     F_s(j,1) = F_s(j,1)/(rSf2(j,1)+C_1EM6_R)**C_2_R

  ENDDO

! ###################################################################
! Integral quantities shear layer
! ###################################################################
  IF ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN

! ###################################################################
! 1D quantities of the jet
! ###################################################################
  ELSE IF ( imode_flow .EQ. DNS_FLOW_JET ) THEN
     S2 = mean_i(inb_scal) - C_05_R*delta_i(inb_scal)
     U2 = mean_u - C_05_R*delta_u

! -------------------------------------------------------------------
! Integral balance of scalar
! -------------------------------------------------------------------
     DO n = 1,nstatavg
! mean scalar part
        DO j = jmin_loc,jmax_loc
           wrk1d(j) = rR(n,j)*fU(n,j)*(fS(n,j)-S2)
        ENDDO
        IntExcScaS(n) = SIMPSON_NU(jmax_loc-jmin_loc+1,wrk1d(jmin_loc),y(jmin_loc))
! Reynolds stress part
        DO j = jmin_loc,jmax_loc
           wrk1d(j) =rR(n,j)*fRus(n,j)
        ENDDO
        IntExcScaRsu(n) = SIMPSON_NU(jmax_loc-jmin_loc+1,wrk1d(jmin_loc), y(jmin_loc))
     ENDDO

! -------------------------------------------------------------------
! Jet thickness
! -------------------------------------------------------------------
! Jet half-width based on velocity
     CALL DELTA_X(nstatavg, jmax, y, fU(1,1), wrk1d, delta_05_d(1), delta_05_u(1), U2, r05)

! Jet half-width based on scalar
     CALL DELTA_X(nstatavg, jmax, y, fS(1,1), wrk1d, delta_s_d(1), delta_s_u(1), S2, r05)

! Jet center line based on scalar
     y_center = y(1) + ycoor_i(inb_scal)*scaley
     DO n = 1,nstatavg
        DO j = 1,jmax
           wrk1d(j) = fS(n,j)
        ENDDO
        jloc_max = MAXLOC(wrk1d(1:jmax)); j = jloc_max(1)
        IF ( wrk1d(j-1) .GT. wrk1d(j+1) ) THEN
           delta_s_center(n) = C_05_R*(y(j)+y(j-1))
        ELSE
           delta_s_center(n) = C_05_R*(y(j)+y(j+1))
        ENDIF
        delta_s_center(n) = delta_s_center(n) - y_center
     ENDDO

  ENDIF

! ###################################################################
! Scaling of the quatities
! ###################################################################
  DO n = 1,nstatavg

     IF ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN
     ELSE
        delta_05 = C_05_R*(delta_05_u(n)+delta_05_d(n))

        SimSC(n) = C_05_R*(fS(n,jmax/2)+fS(n,jmax/2+1)) - S2

        DU = C_05_R*(fU(n,jmax/2)+fU(n,jmax/2+1)) - U2
        DS = SimSC(n)
     ENDIF

     DO j = 1,jmax

        SimS(n,j) = (fS(n,j)-S2)/DS
        Conv_s(n,j) = Conv_s(n,j)/(DS*DU)*delta_05
        Tran_s(n,j) = Tran_s(n,j)/(DS*DU)*delta_05
        Reyn_s(n,j) = Reyn_s(n,j)/(DS*DU)*delta_05
        Resi_s(n,j) = Resi_s(n,j)/(DS*DU)*delta_05

        SimRss(n,j) = SQRT(fRss(n,j))/DS
        Conv_ss(n,j) = Conv_ss(n,j)/(DS*DS*DU)*delta_05
        Prod_ss(n,j) = Prod_ss(n,j)/(DS*DS*DU)*delta_05
        Diss_ss(n,j) = Diss_ss(n,j)/(DS*DS*DU)*delta_05
        Tran_ss(n,j) = Tran_ss(n,j)/(DS*DS*DU)*delta_05
        Tran_ss_vis(n,j) = Tran_ss_vis(n,j)/(DS*DS*DU)*delta_05
        MnFl_ss(n,j) = MnFl_ss(n,j)/(DS*DS*DU)*delta_05
        Resi_ss(n,j) = Resi_ss(n,j)/(DS*DS*DU)*delta_05

        SimRus(n,j) = fRus(n,j)/(DS*DU)
        SimRvs(n,j) = fRvs(n,j)/(DS*DU)
        SimRws(n,j) = fRws(n,j)/(DS*DU)

     ENDDO

  ENDDO

! ###################################################################
! Saving the data in TkStat format
! ###################################################################
  WRITE(name,*) is; WRITE(str,*) itime
  IF      ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN; name = 'shravg'//TRIM(ADJUSTL(name))//'s'//TRIM(ADJUSTL(str))
  ELSE IF ( imode_flow .EQ. DNS_FLOW_JET   ) THEN; name = 'jetavg'//TRIM(ADJUSTL(name))//'s'//TRIM(ADJUSTL(str))
  ENDIF

#ifdef USE_RECLEN
  OPEN(UNIT=i23,RECL=2580,FILE=name,STATUS='unknown')
#else
  OPEN(UNIT=i23,FILE=name,STATUS='unknown')
#endif

! -------------------------------------------------------------------
! Header
! -------------------------------------------------------------------
  WRITE(i23,'(A8,E14.7E3)') 'RTIME = ', rtime

! Independent variables
  line2='I J X Y SS SU'

! Dependent variables depending on y and x
  line1 = 'Xg Yg'
  WRITE(i23,1010) 'GROUP = Grid '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'rR rS rSf2 rUfSf rVfSf rWfSf'
  WRITE(i23,1010) 'GROUP = Reynolds_Avgs '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'fS fRss fRus fRvs fRws fdSdx fdSdy'
  WRITE(i23,1010) 'GROUP = Favre_Avgs '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'sRss Conv_ss Prod_ss Diss_ss Tran_ss Tran_ss_vis MnFl_ss Resi_ss '
  WRITE(i23,1010) 'GROUP =  Rss_Eqn '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'sRus Conv_us Prod_us Diss_us Tran_us Tran_us_vis Tran_us_p MnFl_us1 MnFl_us2 Press_us Resi_us'
  WRITE(i23,1010) 'GROUP =  Rus_Eqn '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'sRvs Conv_vs Prod_vs Diss_vs Tran_vs Tran_vs_vis Tran_vs_p MnFl_vs1 MnFl_vs2 Press_vs Resi_vs'
  WRITE(i23,1010) 'GROUP =  Rvs_Eqn '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'sRws Conv_ws Prod_ws Diss_ws Tran_ws Tran_ws_vis Tran_ws_p MnFl_ws1 MnFl_ws2 Press_ws Resi_ws'
  WRITE(i23,1010) 'GROUP =  Rws_Eqn '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'sS Conv_s Tran_s Reyn_s Resi_s'
  WRITE(i23,1010) 'GROUP =  S_Eqn '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'Gamma'
  WRITE(i23,1010) 'GROUP = Intermittency '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

  line1 = 'S_s F_s'
  WRITE(i23,1010) 'GROUP = Skewness_Flatness '//TRIM(ADJUSTL(line1))
  line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))

! dependent variables dependent on t only
  IF ( imode_flow .EQ. DNS_FLOW_JET ) THEN
     line1 = 'Del_Z_u Del_Z_d Del_Zmax Sim_Z Int_mom_Z Int_mom_RuZ'
     WRITE(i23,1010) 'GROUP = 1D_Quantities '//TRIM(ADJUSTL(line1))
     line2 = TRIM(ADJUSTL(line2))//' '//TRIM(ADJUSTL(line1))
  ELSE IF ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN
  ENDIF


  WRITE(i23,1010) TRIM(ADJUSTL(line2))

! -------------------------------------------------------------------
! Output
! -------------------------------------------------------------------
  DO n = 1,nstatavg
     i = statavg(n)

     IF ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN
     ELSE IF ( imode_flow .EQ. DNS_FLOW_JET ) THEN
        delta_s  = C_05_R*(delta_s_u(n)+delta_s_d(n))
        delta_05 = C_05_R*(delta_05_u(n)+delta_05_d(n))
     ENDIF

     IF ( imode_flow .EQ. DNS_FLOW_JET ) THEN
        ivauxpos = 6
        VAUXPOS(1)  = delta_s_u(n)
        VAUXPOS(2)  = delta_s_d(n)
        VAUXPOS(3)  = delta_s_center(n)
!        VAUXPOS(4)  = SimSC(n)
        VAUXPOS(4)  = (SimSC(1)/SimSC(n))**C_2_R
        VAUXPOS(5)  = IntExcScaS(n)
        VAUXPOS(6)  = IntExcScaRsu(n)
     ELSE IF ( imode_flow .EQ. DNS_FLOW_SHEAR ) THEN
     ENDIF

     DO j = 1,jmax
        ivauxpre = 4
        VAUXPRE(1) = x(i)/diam_u
        VAUXPRE(2) = y(j)/diam_u
        VAUXPRE(3) = (y(j)- y(1) - ycoor_i(inb_scal)*scaley)/delta_s
        VAUXPRE(4) = (y(j)- y(1) - ycoor_i(inb_scal)*scaley)/delta_05

        IF ( j .EQ. jmax/2 ) THEN
           ivauxdum = ivauxpos
        ELSE
           ivauxdum = 0
        ENDIF

        WRITE(i23,1100) i, j, (VAUXPRE(k), k=1,ivauxpre), &
! Grid&
             x(i), y(j), &
! Reynolds averages&
             rR(n,j), rS(n,j),&
             rSf2(n,j), rUfSf(n,j), &
             rVfSf(n,j), rWfSf(n,j), &
! Favre averages&
             fS(n,j), &
             fRss(n,j), fRus(n,j), &
             fRvs(n,j), fRws(n,j),&
             fdSdx(n,j), fdSdy(n,j),&
! Scalar equation Rss&
             SimRss(n,j), Conv_ss(n,j), &
             Prod_ss(n,j), Diss_ss(n,j), &
             Tran_ss(n,j), Tran_ss_vis(n,j),&
             MnFl_ss(n,j), Resi_ss(n,j),&
! Scalar equation Rus&
             SimRus(n,j), Conv_us(n,j), &
             Prod_us(n,j), Diss_us(n,j), &
             Tran_us(n,j), Tran_us_vis(n,j),&
             Tran_us_p(n,j), MnFl_us1(n,j),&
             MnFl_us2(n,j), &
             Press_us(n,j), Resi_us(n,j),&
! Scalar equation Rvs&
             SimRvs(n,j), Conv_vs(n,j), &
             Prod_vs(n,j), Diss_vs(n,j), &
             Tran_vs(n,j), Tran_vs_vis(n,j),&
             Tran_vs_p(n,j), MnFl_vs1(n,j),&
             MnFl_vs2(n,j),&
             Press_vs(n,j), Resi_vs(n,j),&
! Scalar equation Rws&
             SimRws(n,j), Conv_ws(n,j), &
             Prod_ws(n,j), Diss_ws(n,j), &
             Tran_ws(n,j), Tran_ws_vis(n,j),&
             Tran_ws_p(n,j), MnFl_ws1(n,j),&
             MnFl_ws2(n,j), &
             Press_ws(n,j), Resi_ws(n,j),&
! Scalar equation S&
             SimS(n,j), Conv_s(n,j),&
             Tran_s(n,j), Reyn_s(n,j), &
             Resi_s(n,j),&
! Intermittency&
             Gamma_s(n,j),&
! Skewness&Flatness&
             S_s(n,j), F_s(n,j),&
! 1D quantities&
             (VAUXPOS(k),k=1,ivauxdum)

     ENDDO
  ENDDO

  CLOSE(i23)

#ifdef TRACE_ON
  CALL IO_WRITE_ASCII(tfile, 'LEAVING AVG_SCAL_SPATIAL_LAYER' )
#endif

  RETURN

1010 FORMAT(A)
1100 FORMAT(I3,1X,I3,4(1X,E12.5E3),66(1X,E12.5E3),VARMX1D(1X,E12.5E3))

END SUBROUTINE AVG_SCAL_SPATIAL_LAYER
