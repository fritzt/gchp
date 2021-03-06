! $Id$

#ifdef NAME_
#undef NAME_
#endif

#ifdef NAMESTR_
#undef NAMESTR_
#endif

#define NAME_ MAPL_CommsScatterV_
#define NAMESTR_ 'MAPL_CommsScatterV_'

#include "overload.macro"

  subroutine SUB_ (layout, sendbuf, sendcnts, displs, &
                   recvbuf, recvcnt, root, RC)
    type (ESMF_DELayout)                         :: layout
    TYPE_(kind=EKIND_), intent(IN   )            :: sendbuf (:)
    integer,            intent(IN   )            :: sendcnts(:)
    TYPE_(kind=EKIND_), intent(  OUT)            :: recvbuf DIMENSIONS_
    integer,            intent(IN   )            :: recvcnt
    integer,            intent(IN   )            :: displs(:)
    integer,            intent(IN   )            :: root
    integer         ,   intent(  OUT),  optional :: RC

    character(len=ESMF_MAXSTR), parameter :: IAM='MAPL_CommsScatterV'
    integer                               :: status
    type(ESMF_VM)                         :: vm
    integer                               :: comm

    call ESMF_DELayoutGet(layout, vm=vm, rc=status)
    _VERIFY(STATUS)
#if 1
    call ESMF_VMGet(vm, mpiCommunicator = comm, rc=status)
    _VERIFY(STATUS)

    call mpi_scatterv( sendbuf, sendcnts, displs,  MPITYPE_, &
                       recvbuf, recvcnt, MPITYPE_,           &
                       root, comm, status )
    _VERIFY(STATUS)
#else
    call ESMF_VMScatterv( vm, sendbuf, sendcnts, displs,  &
                       recvbuf, recvcnt,                  &
                       root, status )
    _VERIFY(STATUS)
#endif
    _RETURN(ESMF_SUCCESS)
  END SUBROUTINE SUB_

#undef NAME_
#undef NAMESTR_

#undef DIMENSIONS_
#undef RANK_
#undef RANKSTR_
#undef VARTYPE_

