      program call_ttv_fast
C This routine gives an example of calling the Fortran
C version of TTVFast, ttv_fast.for.
C If you make use of this code, please cite:
C Deck, Agol, Holman & Nesvorny, 2014, ApJ, 787, 132, arXiv:1403.1895

      implicit none
      include 'nbody_include.for'
      integer istep,iplanet,nplanet,verbose

      integer itrans(0:nbody-2)
      integer*4 irv,nrv
      real*8  t0,dt,ttotal,trv,rv0,sigrv
      real*8  times_rv(0:nrvmax-1),rv(0:nrvmax-1)
      real*8  nbody_param_in(0:nbody-1,0:6)
      real*8  nbody_data_com(0:6,0:nbody-1)
      real*8  ttv_data_out(0:nbody-2,0:2,0:ntransmax-1)
      common /nbody_params/ t0,dt,ttotal,verbose

C reads in parameters, calls ttv_fast, writes output.
C 1) Open the input file for reading:
      open(unit=8,file='ttv_fast.in')
C Read in the global simulation parameters:
      read(8,*) nplanet,t0,dt,ttotal,verbose
C Create an array for storing the star+planet cartesian
C coordinates in the center-of-mass frame:
C 2) Read in the COM planet/star coordinates:
      if(nplanet.ne.nbody-1) then
        write(*,*) 'wrong number of planets'
      endif
      do iplanet=0,nplanet
        read(8,*) nbody_data_com(0:6,iplanet)
      enddo
C Close the file
      close(unit=8)

C Next, read in the radial velocity data:
      open(unit=8,file='rvdata.txt')
      read(8,*) nrv
      do irv=0,nrv-1
c        read(8,*) trv,rv0,sigrv
        read(8,*) trv
        times_rv(irv)=trv
      enddo
      close(unit=8)

      do iplanet=0,nplanet
        nbody_param_in(iplanet,0)=nbody_data_com(0,iplanet)
        nbody_param_in(iplanet,1:6)=nbody_data_com(1:6,iplanet)
      enddo

      call ttv_fast(nbody_param_in,ttv_data_out,
     &      itrans,times_rv,nrv,rv)
      if(verbose.ge.1) then
        open(unit=8,file='rvdata.out')
        do irv=0,nrv-1 
          write(8,'(2f25.17)') times_rv(irv),rv(irv)
        enddo
        close(unit=8)
      endif

500   format (i1,i4,3e25.17)
      return
      end
