#include "types.h" 
#include "dns_error.h"
#ifdef USE_MPI
#include "dns_const_mpi.h"
#endif

!########################################################################
!########################################################################
SUBROUTINE IO_WRITE_SUBARRAY4(idir, sizes, fname, varname, data, subarray, work)

#ifdef USE_MPI
  USE DNS_MPI, ONLY : ims_pro_i,ims_pro_k, ims_comm_x,ims_comm_z, ims_err
#endif

  IMPLICIT NONE

#ifdef USE_MPI 
#include "mpif.h"
#endif 

  TINTEGER,                                   INTENT(IN)    :: idir
  TINTEGER,                                   INTENT(IN)    :: sizes(4) ! total size, local size, stride, # variables
  CHARACTER*(*),                              INTENT(IN)    :: fname
  CHARACTER*32, DIMENSION(sizes(4)),          INTENT(IN)    :: varname
  TREAL,        DIMENSION(sizes(1),sizes(4)), INTENT(IN)    :: data
  TINTEGER,                                   INTENT(IN)    :: subarray
  REAL(4),      DIMENSION(sizes(2)),          INTENT(INOUT) :: work

! -----------------------------------------------------------------------
  TINTEGER iv
  CHARACTER*64 name

#ifdef USE_MPI
  TINTEGER :: mpio_status(MPI_STATUS_SIZE), mpio_fh
  INTEGER(KIND=MPI_OFFSET_KIND) mpio_offset
#endif

! #######################################################################
#define LOC_UNIT_ID 75
#define LOC_STATUS 'unknown'

#ifdef USE_MPI
  IF ( ( idir .EQ. 1 .AND. ims_pro_k .EQ. 0 ) .OR. &
       ( idir .EQ. 2 .AND. ims_pro_i .EQ. 0 ) .OR. &
         idir .EQ. 3                          ) THEN
#endif

  DO iv = 1,sizes(4)
     name = TRIM(ADJUSTL(fname))//'.'//TRIM(ADJUSTL(varname(iv)))
     
#ifdef USE_MPI
     work(1:sizes(2)) = SNGL(data(sizes(3)+1:sizes(3)+sizes(2),iv))
     mpio_offset = 0

     IF      ( idir .EQ. 1 ) THEN ! Ox data
        CALL MPI_File_open(ims_comm_x,    TRIM(ADJUSTL(name)),&
             IOR(MPI_MODE_WRONLY,MPI_MODE_CREATE),MPI_INFO_NULL,mpio_fh, ims_err) 
     ELSE IF ( idir .EQ. 2 ) THEN ! Oz data
        CALL MPI_File_open(ims_comm_z,    TRIM(ADJUSTL(name)),&
             IOR(MPI_MODE_WRONLY,MPI_MODE_CREATE),MPI_INFO_NULL,mpio_fh, ims_err) 
     ELSE IF ( idir .EQ. 3 ) THEN ! 3d data
        CALL MPI_File_open(MPI_COMM_WORLD,TRIM(ADJUSTL(name)),&
             IOR(MPI_MODE_WRONLY,MPI_MODE_CREATE),MPI_INFO_NULL,mpio_fh, ims_err) 
     ENDIF
     CALL MPI_File_set_view(mpio_fh, mpio_offset, MPI_REAL4, subarray, 'native', MPI_INFO_NULL, ims_err) 
     CALL MPI_File_write_all(mpio_fh, work, sizes(2), MPI_REAL4, mpio_status, ims_err) 
     CALL MPI_File_close(mpio_fh, ims_err)  
     
#else
     
#include "dns_open_file.h"
     WRITE(LOC_UNIT_ID) SNGL(data(sizes(3)+1:sizes(3)+sizes(2),iv))
     CLOSE(LOC_UNIT_ID)
     
#endif
     
  ENDDO

#ifdef USE_MPI
  ENDIF
#endif

  RETURN
END SUBROUTINE IO_WRITE_SUBARRAY4

