C The following line defines the number of bodies:
      integer nbody,nstepmax,ntransmax,nrvmax
      parameter (nbody=3,nstepmax=40000,ntransmax=1370,nrvmax=50000)

C The following format statement should have 6*nbody+1 numbers:
200   format (19e23.15)
C The following format statement should have nbody-1 numbers:
300   format (2e23.15)
