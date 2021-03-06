! $Id$
!
! Example/test code which shows User Component calls.

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

!
! !DESCRIPTION:
!  User-supplied Component, most recent interface revision.
!
!
!\begin{verbatim}

module user_model1

  ! ESMF Framework module
  use ESMF

  implicit none
    
  public userm1_register

  ! variable data arrays
  integer(ESMF_KIND_I4), allocatable, save :: tmp_data(:,:,:)
  integer(ESMF_KIND_I4), allocatable, save :: hum_data(:,:,:)
  integer(ESMF_KIND_I4), allocatable, save :: prs_data(:,:,:)

  ! index lists
  integer :: index_list0(4) = (/1,3,5,7/)
  integer :: index_list1(6) = (/2,4,6,8,9,10/)
  integer :: index_list2(0)
  integer :: index_list3(6) = (/11,12,13,14,15,18/)
!  integer :: index_list0(4) = (/1,2,3,5/)
!  integer :: index_list1(6) = (/5,6,7,8,9,10/)
!  integer :: index_list2(0)
!  integer :: index_list3(6) = (/11,12,13,14,15,16/)

  contains

  subroutine userm1_register(comp, rc)
    type(ESMF_GridComp) :: comp
    integer, intent(out) :: rc

    ! Initialize return code
    rc = ESMF_SUCCESS

    print *, "User Comp1 Register starting"

    ! Register the callback routines.

    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_INITIALIZE, userRoutine=user_init, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_RUN, userRoutine=user_run, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return
    call ESMF_GridCompSetEntryPoint(comp, ESMF_METHOD_FINALIZE, userRoutine=user_final, &
      rc=rc)
    if (rc/=ESMF_SUCCESS) return

    print *, "Registered Initialize, Run, and Finalize routines"
    print *, "User Comp1 Register returning"
    
  end subroutine

!-------------------------------------------------------------------------
!   !  User Comp Component created by higher level calls, here is the
!   !   Initialization routine.
 
    
  subroutine user_init(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    type(ESMF_VM)          :: vm
    integer                :: de_id, npets
    integer, allocatable   :: indexList(:)
    type(ESMF_DistGrid)    :: distgrid
    type(ESMF_LocStream)   :: locs
    type(ESMF_Field)       :: field(3)
    type(ESMF_FieldBundle) :: fieldbundle
    integer                :: icount
    
    ! Initialize return code
    rc = ESMF_SUCCESS

    ! Query component for VM and create a layout with the right breakdown
    call ESMF_GridCompGet(comp, vm=vm, rc=rc)
    if(rc/=ESMF_SUCCESS) return
    call ESMF_VMGet(vm, localPet=de_id, petCount=npets, rc=rc)
    if(rc/=ESMF_SUCCESS) return

    print *, de_id, "User Comp 1 Init starting"

    ! Check for correct number of PETs
    if ( npets .ne. 4 ) then
        call ESMF_LogSetError(ESMF_RC_ARG_BAD,&
            msg="This component must run on 4 PETs.",&
            line=__LINE__, file=__FILE__, rcToReturn=rc)
        return
    endif

    if ( de_id .eq. 0 ) then
        icount = size(index_list0)
        allocate(indexList(icount))
        allocate(tmp_data(2,icount,4))
        allocate(hum_data(1,icount,4))
        allocate(prs_data(2,icount,4))
        indexList = index_list0
    elseif ( de_id .eq. 1 ) then
        icount = size(index_list1)
        allocate(indexList(icount))
        allocate(tmp_data(2,icount,4))
        allocate(hum_data(1,icount,4))
        allocate(prs_data(2,icount,4))
        indexList = index_list1
    elseif ( de_id .eq. 2 ) then
        icount = size(index_list2)
        allocate(indexList(icount))
        allocate(tmp_data(2,icount,4))
        allocate(hum_data(1,icount,4))
        allocate(prs_data(2,icount,4))
        indexList = index_list2
    elseif ( de_id .eq. 3 ) then
        icount = size(index_list3)
        allocate(indexList(icount))
        allocate(tmp_data(2,icount,4))
        allocate(hum_data(1,icount,4))
        allocate(prs_data(2,icount,4))
        indexList = index_list3
    endif

    print *, de_id, "indexList = ", indexList

    if (icount .gt. 0) then
        tmp_data(1,:,1) = indexList(:)*1*1
        tmp_data(1,:,2) = indexList(:)*1*2
        tmp_data(1,:,3) = indexList(:)*1*3
        tmp_data(1,:,4) = indexList(:)*1*4
        hum_data(1,:,1) = indexList(:)*10*1
        hum_data(1,:,2) = indexList(:)*10*2
        hum_data(1,:,3) = indexList(:)*10*3
        hum_data(1,:,4) = indexList(:)*10*4
        prs_data(1,:,1) = indexList(:)*100*1
        prs_data(1,:,2) = indexList(:)*100*2
        prs_data(1,:,3) = indexList(:)*100*3
        prs_data(1,:,4) = indexList(:)*100*4
        tmp_data(2,:,1) = 1*1
        tmp_data(2,:,2) = 1*2
        tmp_data(2,:,3) = 1*3
        tmp_data(2,:,4) = 1*4
        prs_data(2,:,1) = 100*1
        prs_data(2,:,2) = 100*2
        prs_data(2,:,3) = 100*3
        prs_data(2,:,4) = 100*4
    endif

    ! Add "temperature" "humidity" "pressure" fields to the export state.
    distgrid = ESMF_DistGridCreate(arbSeqIndexList=indexList, rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    deallocate(indexList)

    locs = ESMF_LocStreamCreate(distgrid=distgrid, &
        indexflag=ESMF_INDEX_DELOCAL, coordSys=ESMF_COORDSYS_CART, &
        name="Test LocStream", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    field(1) = ESMF_FieldCreate(locs, tmp_data, &
        indexflag=ESMF_INDEX_DELOCAL, gridToFieldMap=(/2/), &
        name="temperature", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    field(2) = ESMF_FieldCreate(locs, hum_data, &
        indexflag=ESMF_INDEX_DELOCAL, gridToFieldMap=(/2/), &
        name="humidity", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    field(3) = ESMF_FieldCreate(locs, prs_data, &
        indexflag=ESMF_INDEX_DELOCAL, gridToFieldMap=(/2/), &
        name="pressure", rc=rc)
    if (rc .ne. ESMF_SUCCESS) return

    fieldbundle = ESMF_FieldBundleCreate(fieldList=field, &
        name="fieldbundle data", rc=rc)
    if (rc/=ESMF_SUCCESS) return

    call ESMF_StateAdd(exportState, fieldbundleList=(/fieldbundle/), rc=rc)
    if (rc/=ESMF_SUCCESS) return
   
    print *, de_id, "User Comp1 Init returning"

  end subroutine user_init


!-------------------------------------------------------------------------
!   !  The Run routine where data is computed.
!   !
 
  subroutine user_run(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    type(ESMF_VM)          :: vm
    integer                :: de_id
   
    ! Initialize return code
    rc = ESMF_SUCCESS

    call ESMF_GridCompGet(comp, vm=vm, rc=rc)
    if(rc/=ESMF_SUCCESS) return
    call ESMF_VMGet(vm, localPet=de_id, rc=rc)
    if(rc/=ESMF_SUCCESS) return

    print *, de_id, "User Comp1 Run starting"
 
    print *, de_id, "User Comp1 Run returning"

  end subroutine user_run


!-------------------------------------------------------------------------
!   !  The Finalization routine where things are deleted and cleaned up.
!   !
 
  subroutine user_final(comp, importState, exportState, clock, rc)
    type(ESMF_GridComp) :: comp
    type(ESMF_State) :: importState, exportState
    type(ESMF_Clock) :: clock
    integer, intent(out) :: rc

    ! Local variables
    type(ESMF_VM)          :: vm
    integer                :: de_id
    type(ESMF_Field)       :: field
    type(ESMF_FieldBundle) :: fieldbundle
    integer                :: k
    type(ESMF_LocStream)   :: locs
    
    ! Initialize return code
    rc = ESMF_SUCCESS

    call ESMF_GridCompGet(comp, vm=vm, rc=rc)
    if(rc/=ESMF_SUCCESS) return
    call ESMF_VMGet(vm, localPet=de_id, rc=rc)
    if(rc/=ESMF_SUCCESS) return

    print *, de_id, "User Comp1 Final starting"

    call ESMF_StateGet(exportState, "fieldbundle data", fieldbundle, rc=rc)
    if (rc/=ESMF_SUCCESS) return
    call ESMF_FieldBundleGet(fieldbundle, locstream=locs, rc=rc)
    if (rc/=ESMF_SUCCESS) return
    do k = 1, 3
        call ESMF_FieldBundleGet(fieldbundle, fieldIndex=k, field=field, rc=rc)
        if (rc/=ESMF_SUCCESS) return
        call ESMF_FieldDestroy(field, rc=rc)
        if (rc/=ESMF_SUCCESS) return
    enddo
    call ESMF_FieldBundleDestroy(fieldbundle, rc=rc)
    if (rc/=ESMF_SUCCESS) return
    call ESMF_LocStreamDestroy(locs, rc=rc)
    if(rc/=ESMF_SUCCESS) return

    deallocate(tmp_data)
    deallocate(hum_data)
    deallocate(prs_data)

    print *, de_id, "User Comp1 Final returning"

  end subroutine user_final


end module user_model1
    
!\end{verbatim}
