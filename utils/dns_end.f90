#include "types.h"

SUBROUTINE DNS_END(ic)
  
  USE DNS_CONSTANTS, ONLY : lfile, efile

#ifdef USE_MPI
  USE DNS_MPI
#endif

  IMPLICIT NONE
  
#ifdef USE_MPI
#include "mpif.h"
#endif
  
  INTEGER ic

#ifdef USE_MPI
  CHARACTER*64 line
#endif
  
  IF ( ic .EQ. 0 ) THEN; CALL IO_WRITE_ASCII(lfile, 'Finalizing program.')
  ELSE;                  CALL IO_WRITE_ASCII(lfile, 'Finalizing program abnormaly. Check'//TRIM(ADJUSTL(efile)) ); ENDIF
  CALL IO_WRITE_ASCII(lfile, '########################################')
  
#ifdef USE_MPI
  ims_time_max = MPI_WTIME()
  WRITE(line,'(E12.5E3)') ims_time_max-ims_time_min
  line = 'Time elapse ....................: '//TRIM(ADJUSTL(line))
  CALL IO_WRITE_ASCII(lfile, line)
 
#ifdef PROFILE_ON 
  WRITE(line,'(E12.5E3)') ims_time_trans
  line = 'Time in array transposition ....: '//TRIM(ADJUST(line))
  CALL IO_WRITE_ASCII(lfile, line)
#endif

#endif
      
#ifdef USE_MPI
  CALL MPI_FINALIZE(ims_err)
#endif
  
  RETURN
END SUBROUTINE DNS_END
