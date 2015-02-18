      subroutine ttv_fast(nbody_param_in,ttv_data_out,itrans,
     &                    times_rv,nrv,rv)
C This is the Fortran version of TTVFast.
C
C If you make use of this code, please cite:
C
C Deck, Agol, Holman & Nesvorny, 2014, ApJ, 787, 132, arXiv:1403.1895
C
C 1) Description:
C This subroutine carries out a fast, approximate computation
C of the times of transit of a nearly Keplerian system (typically
C a star orbited by multiple planets), and it returns the times
C of transit of the planets over a specified timescale.
C 
C 2) Author: Eric Agol (with advice and input from Matt Holman & Kat Deck)
C
C 3) Version: 1.0 (alpha version)  28 February, 2014
C
C 4) Inputs:
C    nbody_param_in:  a vector containing the G*mass (in units of AU^3/day^2),
C       cartesian coordinates (in barycentric AU),
C       and velocities (in barycentric AU/day).  Input units
C       are days (time), AU (length), and AU/day (velocity). 
C
C    times_rv: times at which to compute the radial velocity (size: nrvmax)
C        These should be in order.
C    nrv: Number of RV times.
C
C    t0,dt,ttotal,verbose: these are passed through a common block,
C       nbody_params.
C       t0: the starting time of the integration (in days)
C       dt: the symplectic time step
C       ttotal: the total amount of time of the integration
C       verbose: 0 = no output file; 1 = output transit times to
C          the file 'transit_times.txt'; 2 = output the positions
C          of the planets at each time step.
C
C 5) Outputs:
C    ttv_data_out: array of transit times, sky separation mid-transit (AU),
C           and sky velocity mid trnansit (AU/day).
C    itrans: vector containing the number of transit times of each planet
C    rv:  radial velocities at the times specified in times_rv (size: nrvmax)
C  
C 6) Other quantities that control the integration:
C    reps:  This specifies the precision at which the transit time
C        interpolation is truncated (currently set to 10^-7).
C    del (in step_fg): This specifies the precision at which the
C        solution to Kepler's equation is terminated (currently set
C        to 10^-4).
C 7) Required to compile: nbody_include.for
C      This file defines the parameters nbody, nstepmax, ntransmax &  nrvmax.
C      nbody:     Specifies the number of bodies (i.e. nbody=nplanet+1).
C      nstepmax:  Specifies the maximum number of (symplectic) steps
C        to store.
C      ntransmax: Specifies the maximum number of transits to store for
C        each planet.
C      nrvmax:    Specifies maximum number of RV data points.
C
      implicit none
      include 'nbody_include.for'
      integer nplanet,iplanet,kplanet,istep,nstep,verbose
      integer*4 irv,nrv
      real*8 mstar,mass(0:nbody-2)
      real*8 times_rv(0:nrvmax-1),rv(0:nrvmax-1),rv0,vstar
      common /masses/ mstar,mass,nplanet
      real*8 nbody_param_in(0:nbody-1,0:6)
      real*8 nbody_data_com(0:6,0:nbody-1)
      real(kind=8), dimension(0:nbody-2,0:12) :: nbody_data,
     &       nbody_data0, nbody_data1, nbody_data2
      real*8 nbody_data_store(0:nbody-2,0:12,0:nstepmax-1)
      real*8 mi,r0_vec(0:2),v0_vec(0:2)
      real*8 r_vec(0:2),v_vec(0:2),ttotal,dt,dekep,t0
      real*8 time(0:nstepmax-1)
      real*8 tz,tz0,tz1,tz2,vskyz0,vskyz1,vskyz2,ftz,dfdt,pi
      real*8 vskyz,rskyz
      real*8 at,bt,ct,qt
      real*8 r0_vec0(0:2),r0_vec1(0:2),r0_vec2(0:2),r0_vecz(0:2)
      real*8 v0_vec0(0:2),v0_vec1(0:2),v0_vec2(0:2),v0_vecz(0:2)
      real*8 r_vec0(0:2),r_vec1(0:2),r_vec2(0:2),r_vecz(0:2)
      real*8 v_vec0(0:2),v_vec1(0:2),v_vec2(0:2),v_vecz(0:2)
      real*8 accelz(0:2)
      real*8 reps,dt0,dt1,dt2,phi
      real*8 ttv_data_out(0:nbody-2,0:2,0:ntransmax-1)
      real*8 phi0,phi1,phi2,ntransest
      integer nnewt,nnmax,itrans(0:nbody-2),v
      character*1 char
      common /pie/ pi
      common /nbody_params/ t0,dt,ttotal,verbose
      v=verbose
      pi=acos(-1d0)
      nnmax=20

C Implements Wisdom (2006) integrator in 'canonical heliocentric coordinates'.
C
      nplanet=nbody-1
      itrans(0:nplanet-1)=0
C Start at the first radial velocity time:
      irv=0
      ttv_data_out(0:nplanet-1,0:2,0:ntransmax-1)=0d0
C 1) Open the input file for reading:
c      open(unit=8,file='ttv_fast.in')
C Read in the global simulation parameters:
C      read(8,*) nplanet,t0,dt,ttotal,verbose
      reps=1d-7
C Compute the number of time steps
      nstep=floor(ttotal/dt)
C Create an array for storing the star+planet cartesian
C coordinates in the center-of-mass frame:
C 2) Read in the COM planet/star coordinates:
      do iplanet=0,nplanet
        nbody_data_com(0,iplanet)=nbody_param_in(iplanet,0)
        nbody_data_com(1:6,iplanet)=nbody_param_in(iplanet,1:6)
c        write(*,*) iplanet,nbody_data_com(0:6,iplanet)
      enddo
C Close the file
C Extract the masses of the bodies:
      mstar=nbody_data_com(0,0)
      mass(0:nplanet-1)=nbody_data_com(0,1:nplanet)
C 3) Compute the planets' canonical heliocentric coordinates:
C   Simply subtract off the stellar position from each planet
       nbody_data(0:nplanet-1,0:12)=0d0
       do iplanet=0,nplanet-1
         nbody_data(iplanet,0:2)=
     &       nbody_data_com(1:3,iplanet+1)-nbody_data_com(1:3,0)
C   (leave the velocities in the COM frame):
         nbody_data(iplanet,3:5)=nbody_data_com(4:6,iplanet+1)
C        write(*,*) nbody_data(iplanet,0:5)
       enddo
C First, do a dt=0 step in order to compute the instantaneous period & eccentricity
C for each planet in heliocentric coordinates using the step_fg function:
C      nbody_data_tmp=nbody_data
C      call drift(0d0,nbody_data_tmp)
C      nbody_data_store(0:nplanet-1,0:12,0)=nbody_data_tmp
      
c Apply the symplectic corrector before getting started:
c      call drift(dt/2d0,nbody_data)
      call sympcorrect(dt,nbody_data)
c      call sympcorrect5(dt,nbody_data)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call kick(0d0,nbody_data,0)
      nbody_data_store(0:nplanet-1,0:12,0)=nbody_data(0:nplanet-1,0:12)
C Run some checks to prevent code from crashing:
      verbose=2
      call update(nbody_data)
      verbose=v
      if(nstep.gt.nstepmax) then
        write(*,*) 'You need to increase nstepmax to greater than',nstep
      endif
      ntransest=0
      do iplanet=0,nplanet-1
        ntransest=ntransest + ttotal/nbody_data(iplanet,6)
      enddo
      if(ntransest.gt.ntransmax) then 
        write(*,*) 'You should increase ntransmax to be greater than',
     &        ntransest
      endif
      if(nrv.gt.nrvmax) then 
        write(*,*) 'You should increase nrvmax to be greater than',nrv
      endif
C 4) Start loop over time steps:
c      time(0)=t0+dt/2d0
      time(0)=t0
C Make sure that the starting RV time is after the initial time:
      do while(t0.ge.times_rv(irv).and.irv.lt.nrv) 
        irv=irv+1
      enddo
c      write(*,*) 'Initial time: ',t0
      do istep=1,nstep-1
        if(istep.eq.1) then 
          nbody_data(0:nplanet-1,7)=0d0
          call drift(dt/2d0,nbody_data)
          call update(nbody_data)
C Reset delta E so that we don't have a mis-match:
          nbody_data(0:nbody-2,7)=0d0
        endif
        call sympstep(dt,nbody_data)
C 8) Save the results:
        nbody_data_store(0:nplanet-1,0:12,istep)=
     &              nbody_data(0:nplanet-1,0:12)
        time(istep)=time(istep-1)+dt
C 9) Compute the radial velocity, if necessary:
        if(time(istep).ge.times_rv(irv).and.irv.lt.nrv) then
c        if(time(istep).ge.times_rv(irv).and.time(istep-1).lt.
c     &    times_rv(irv)) then
          do while(time(istep).ge.times_rv(irv).and.irv.lt.nrv)
C Do a Keplerian drift for each planet to the time of RV:
            nbody_data0=nbody_data_store(0:nplanet-1,0:12,istep)
            nbody_data0(0:nplanet-1,7)=0d0
C We need to drift back a half-step since we overshot, plus
C the difference with the time of RV:
            call drift(-dt/2d0-time(istep)+times_rv(irv),nbody_data0)
            call update(nbody_data0)
C Compute the stellar radial velocity in the barycenter frame:
            vstar=0d0
C Loop over planet number to compute the star velocity:
            do iplanet=0,nplanet-1
C The line-of-sight is along the z-direction, so just use the
C z-velocity, linearly interpolated to the RV time:
              rv0=nbody_data0(iplanet,5)
C To compute the sky velocity we need add the star's
C velocity back in (eqn. 6 from Fabrycky 2010):
              vstar=vstar+mass(iplanet)*rv0
            enddo
C Okay, complete the computation of the stellar velocity
C wrt the barycenter of the system:
            rv(irv)=-vstar/mstar
C Advance the radial velocity time:
            irv=irv+1
          enddo
        endif
C 10) Determine if a transit has occured for any of the planets
C    over this time interval:
        do iplanet=0,nplanet-1
          if(istep.ge.2) then
            if((nbody_data_store(iplanet,9,istep)+
     &    nbody_data_store(iplanet,9,istep-1)).gt.0d0
c          if(istep.ge.2.and.nbody_data_store(iplanet,9,istep-1).gt.0d0
     &       .and.(nbody_data_store(iplanet,9,istep-1)+
     &       nbody_data_store(iplanet,9,istep-2)).lt.0d0.and.
     &       nbody_data_store(iplanet,2,istep-1).lt.0d0) then
C A transit has occurred.  Now estimate the time of transit: 
            tz0=time(istep-2)
            tz1=time(istep-1)
            tz2=time(istep)
c            tz1=time(istep-1)-dt/2d0
c            tz2=time(istep)+dt/2d0
            nbody_data0=nbody_data_store(0:nplanet-1,0:12,istep-2)
            nbody_data0(0:nplanet-1,7)=0d0
c We need to drift back a half-step since we overshot:
            call drift(-dt/2d0,nbody_data0)
c            call sympcorrectinv(dt,nbody_data0)
            call update(nbody_data0)
            nbody_data1=nbody_data_store(0:nplanet-1,0:12,istep-1)
            nbody_data1(0:nplanet-1,7)=0d0
c We need to drift back a half-step since we overshot:
            call drift(-dt/2d0,nbody_data1)
C Turns out the limiting TTV precision is due to Kepler interpolation
C so we don't need to include the inverse corrector (which nearly doubles
C the run time). But, this can be turned back on if higher precision
C is desired:
c            call sympcorrectinv(dt,nbody_data1)
            call update(nbody_data1)
            nbody_data2=nbody_data_store(0:nplanet-1,0:12,istep)
            nbody_data2(0:nplanet-1,7)=0d0
            call drift(-dt/2d0,nbody_data2)
c            call sympcorrectinv(dt,nbody_data2)
            call update(nbody_data2)
            vskyz0=nbody_data0(iplanet,9)
            vskyz1=nbody_data1(iplanet,9)
            vskyz2=nbody_data2(iplanet,9)
            tz=tz1-(tz2-tz1)/(vskyz2-vskyz1)*vskyz1
100         ftz  = 1d0
            dfdt = 1d0
            nnewt = 0
            mi=mass(iplanet)+mstar
            r0_vec0(0:2)=nbody_data0(iplanet,0:2)
            v0_vec0(0:2)=nbody_data0(iplanet,10:12)
            r0_vec1(0:2)=nbody_data1(iplanet,0:2)
            v0_vec1(0:2)=nbody_data1(iplanet,10:12)
            r0_vec2(0:2)=nbody_data2(iplanet,0:2)
            v0_vec2(0:2)=nbody_data2(iplanet,10:12)
C Now, drift nbody_data2 back a time step:
            dekep=0d0
            call step_fg(mi,-dt,r0_vec2,v0_vec2,r_vec2,v_vec2,dekep)
            r0_vec2(0:2)=r_vec2(0:2)
            v0_vec2(0:2)=v_vec2(0:2)
C Now, drift nbody_data0 forward a time step:
            dekep=0d0
            call step_fg(mi,dt,r0_vec0,v0_vec0,r_vec0,v_vec0,dekep)
            r0_vec0(0:2)=r_vec0(0:2)
            v0_vec0(0:2)=v_vec0(0:2)
C 11) If a transit has occured, then use Newton's method to
C    compute the time of transit.  Do this by applying heliocentric Keplerian drifts
C    from start & end of time step, taking the average position &
C    minimizing the planet-star projected separation.
            do while(abs(ftz/dfdt).gt.reps.and.nnewt.lt.nnmax)
C Integrate to new estimate for the zero of the sky velocity:
              dt1=tz-tz1
              phi0=(tz-tz1)/(tz0-tz1)*(tz-tz2)/(tz0-tz2)
              phi1=(tz-tz0)/(tz1-tz0)*(tz-tz2)/(tz1-tz2)
              phi2=(tz-tz0)/(tz2-tz0)*(tz-tz1)/(tz2-tz1)
              r0_vecz=phi0*r0_vec0+phi1*r0_vec1+phi2*r0_vec2
              v0_vecz=phi0*v0_vec0+phi1*v0_vec1+phi2*v0_vec2
              dekep=0d0
              call step_fg(mi,dt1,r0_vecz,v0_vecz,r_vecz,v_vecz,dekep)
              ftz=r_vecz(0)*v_vecz(0)+r_vecz(1)*v_vecz(1)
              accelz(0:2)=-mi*r_vecz(0:2)/sqrt(sum(r_vecz**2))**3
              dfdt=v_vecz(0)**2+v_vecz(1)**2+r_vecz(0)*accelz(0)
     &            +r_vecz(1)*accelz(1)
              tz=tz-ftz/dfdt
              nnewt=nnewt+1
            enddo
C Compute the sky separation in code coordinates:
            rskyz=sqrt(sum(r_vecz(0:1)**2))
            vskyz=sqrt(sum(v_vecz(0:1)**2))
201         continue
C Store the time of transit for the planet, as well as
C the impact parameter and sky velocity:
            ttv_data_out(iplanet,0,itrans(iplanet))=tz
            ttv_data_out(iplanet,1,itrans(iplanet))=rskyz
            ttv_data_out(iplanet,2,itrans(iplanet))=vskyz
            itrans(iplanet)=itrans(iplanet)+1
            endif
          endif
        enddo
C 12) Make a better prediction for the next dekep value:
        if(istep.ge.3) then
          nbody_data(0:nplanet-1,7)=
     &    3d0*nbody_data_store(0:nplanet-1,7,istep)
     &    -3d0*nbody_data_store(0:nplanet-1,7,istep-1)
     &    +nbody_data_store(0:nplanet-1,7,istep-2)
        endif
      enddo
C 13) Output the times of transit over the duration of the simulation
C    for all of the planets.  Optionally output the positions as a
C    function of time.
      if(verbose.ge.2) then
        open (unit=8,file='ttv_fast.out')
        do istep=0,nstep-1
          write(8,400) time(istep),
     &    (nbody_data_store(iplanet,0:8,istep),
     &     iplanet=0,nplanet-1)
        enddo
      endif
      if(verbose.ge.1) then
        close(unit=8)
        open (unit=8,file='transit_times.txt')
        do iplanet=0,nplanet-1
          if(itrans(iplanet).ge.1) then
            do istep=0,itrans(iplanet)-1
              write(8,500) iplanet,istep,ttv_data_out(iplanet,0:2,istep)
            enddo
          endif
        enddo
        close(unit=8)
      endif
      if(v.eq.3) write(*,*) 'Number of transits: ',itrans
      return
400   format (10e23.15)
500   format (i1,i4,3f25.17)
      end

      subroutine step_fg(gm,dt,r0_vec,v0_vec,r_vec,v_vec,x)
C This routine takes a Kepler step in position & velocity from 
C one time to another using the Danby implementation of the
C solution of Kepler's equation and uses Gauss f & g functions.
      implicit none
      real*8 gm,dt,r0_vec(0:2),v0_vec(0:2),r_vec(0:2),v_vec(0:2)
      real*8 semi,ecc,period,r0,v02,ainv,u,n,ec,es,dm,dmmod,pi,theta
      real*8 f,g,dfdt,dgdt,r,rinv
      real*8 ekepler_diff
      real*8 dx,del,y,sigma,x,fn,fp,fpp,fppp,s,c,fpr,x0
      complex*16 expx
      integer nc
      common /pie/ pi
C gm     = G*mass
C dt     = time step
C r0_vec = initial position vector
C v0_vec = initial velocity vector
C Compute semi-major axis:
      rinv=1d0/sqrt(sum(r0_vec(0:2)**2))
      v02=sum(v0_vec(0:2)**2)
      ainv=2d0*rinv-v02/gm
      u=sum(r0_vec(0:2)*v0_vec(0:2))
      n=sqrt(gm*ainv**3)
      semi=1d0/ainv
C Compute e*cos(E) & e*sin(E) for each planet:
      ec=1d0-ainv/rinv
      es=u/n*ainv**2
      period=2d0*pi/n
C Compute difference in time and in mean-motion (for each planet):
      dm=n*dt
      dmmod=dm-floor(dm/(2d0*pi))*2d0*pi
C Compute change in the eccentric anomaly using differenced
C version of Kepler's equation (following Danby, p. 167):
C If an initial guess for x = Delta E (the change in eccentric
C anomaly over the time step) is given, use it:
      x0=x
C If the initial guess is zero, then instead use the Danby guess:
      if(x.eq.0d0) then 
        ecc=sqrt(ec**2+es**2)
        y=dmmod-es
        sigma=sign(1d0,es*cos(y)+ec*sin(y))
        x=y+sigma*.85d0*ecc-es
      endif
      nc=0
C The convergence parameter is set to 10^-4 since the Danby
C method for solving Kepler's equation is fourth order, so
C when the difference is 10^-4, the next iteration would give
C an error of about 10^-16, which is much smaller than needed:
      del=1d-4
C dx is the correction to Delta E, the difference in eccentric
C anomaly:
      dx=1d0
C Compute sine(Delta E) and cosine(Delta E):
      s=sin(x)
      c=cos(x)
C Now iterate the root finder of Delta E:
      do while(abs(dx).gt.del)
        fpp=ec*s+es*c
        fppp=ec*c-es*s
        fn=x+es-dmmod-fpp
        fp=1d0-fppp
        dx=-fn/(fp-fn/fp*fpp*.5d0)
        dx=-fn/(fp+dx*.5d0*(fpp+dx*fppp/3d0))
        x=x+dx
        s=sin(x)
        c=cos(x)
        nc=nc+1
      enddo
c      if(x0.ne.0d0) write(*,*) nc,dt,x0,x,x0-x
      fp=1d0-(ec*c-es*s)
C Now, compute auxiliary quantities:
      f=(c-1d0)*semi*rinv+1d0
      g=(dmmod+(s-x))/n
C Compute the position at the end of the time step:
      r_vec(0:2)=f*r0_vec(0:2)+g*v0_vec(0:2)
      dfdt=-n*s*rinv/(ainv*fp)
      dgdt=(c-1d0)/fp+1d0
C Compute the velocity at the end of the time step:
      v_vec(0:2)=dfdt*r0_vec(0:2)+dgdt*v0_vec(0:2)
      return
      end

      subroutine update(nbody_data)
C This routine updates the auxiliary quantities (the heliocentric period,
C eccentricity, velocity, and half of the time derivative of the square
C of the sky velocity) in the nbody_data array, which should be done at 
C the end of each symplectic step to check for a transit occurrence:
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet,verbose
      real*8 mstar,mass(0:nbody-2),semi,ecc,period
      real*8 nbody_data(0:nbody-2,0:12)
      real*8 r_vec(0:2),v_vec(0:2),dekep,v2sky,vstar(0:2)
      real*8  gm, r0, v02, ainv, u, n, ec, es, pi, rinv
      real*8 ttotal,dt,t0
      common /masses/ mstar,mass,nplanet
      common /pie/ pi
      common /nbody_params/ t0,dt,ttotal,verbose
C The number of planets equals the number of bodies, minus one:
      nplanet=nbody-1
C Compute the stellar velocity in the barycenter frame (for
C conversion from canonical heliocentric to heliocentric coords):
      vstar(0:2)=0d0
C Loop over planet number to compute the star velocity:
      do iplanet=0,nplanet-1
        v_vec(0:2)=nbody_data(iplanet,3:5)
C To compute the sky velocity we need add the star's
C velocity back in (eqn. 6 from Fabrycky 2010):
        vstar(0:2)=vstar(0:2)+mass(iplanet)*v_vec(0:2)
      enddo
C Okay, complete the computation of the stellar velocity
C wrt the barycenter of the system:
      vstar(0:2)=-vstar(0:2)/mstar
C Now, use the stellar velocity to compute the heliocentric
C velocity for each of the planets:
      do iplanet=0,nplanet-1
C The positions are already in heliocentric coordinates:
        r_vec(0:2)=nbody_data(iplanet,0:2)
C Subtract off the stellar velocity to convert from barycentric
C velocity to heliocentric velocity:
        v_vec(0:2)=nbody_data(iplanet,3:5)-vstar(0:2)
C Now that we have both velocity and position converted
C to heliocentric coordinates, we can compute (half of) the derivative
C of the sky velocity squared (this is the quantity 'D' in the
C TTVFast paper):
        v2sky=r_vec(0)*v_vec(0)+r_vec(1)*v_vec(1)
C Let's save this for figuring out whether a transit has occurred:
        nbody_data(iplanet,9)=v2sky
C Store the heliocentric velocity in the nbody_data array:
        nbody_data(iplanet,10:12)=v_vec(0:2)
C Now, need to recompute the period & eccentricity using
C heliocentric coordinates.  If verbose = 0 or verbose =1, this
C code is skipped to save time.
        if(verbose.ge.2) then
          gm=mstar+mass(iplanet)
          rinv=1d0/sqrt(sum(r_vec(0:2)**2))
          v02=sum(v_vec(0:2)**2)
          ainv=2d0*rinv-v02/gm
          u=sum(r_vec(0:2)*v_vec(0:2))
          n=sqrt(gm*ainv**3)
          semi=1d0/ainv
C Compute e*cos(E) & e*sin(E) for each planet:
          ec=1d0-ainv/rinv
          es=u/n*ainv**2
          ecc=sqrt(ec**2+es**2)
          period=2d0*pi/n
          nbody_data(iplanet,6)=period
          nbody_data(iplanet,8)=ecc
        endif
      enddo
      return
      end

      subroutine sympcorrectinv(dt,nbody_data)
C This routine computes the third-order inverse corrector from Wisdom (2006):
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mstar,mass(0:nbody-2),semi,ecc,period
      real*8 nbody_data(0:nbody-2,0:12)
      real*8 alpha,beta,a1,a2,b1,b2
      alpha=sqrt(.175d0)
      beta=1d0/(48d0*alpha)
      b1=-beta*.5d0
      b2= beta*.5d0
      a1= -alpha
      a2= alpha
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(a1*dt,nbody_data)
      call kick(b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a1*dt,nbody_data)
      call kick(-b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift((a1+a2)*dt,nbody_data)
      call kick(b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a2*dt,nbody_data)
      call kick(-b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(a2*dt,nbody_data)
      return
      end

      subroutine sympcorrect(dt,nbody_data)
C This routine computes the third-order corrector from Wisdom (2006):
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mstar,mass(0:nbody-2),semi,ecc,period
      real*8 nbody_data(0:nbody-2,0:12)
      real*8 alpha,beta,a1,a2,b1,b2
      alpha=sqrt(.175d0)
      beta=1d0/(48d0*alpha)
      b1=-beta*.5d0
      b2= beta*.5d0
      a1= -alpha
      a2= alpha
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(a2*dt,nbody_data)
      call kick(-b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a2*dt,nbody_data)
      call kick(b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift((a1+a2)*dt,nbody_data)
      call kick(-b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a1*dt,nbody_data)
      call kick(b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(a1*dt,nbody_data)
      return
      end

      subroutine sympcorrect5(dt,nbody_data)
C This routine computes the fifth-order corrector from Wisdom (2006):
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mstar,mass(0:nbody-2),semi,ecc,period
      real*8 nbody_data(0:nbody-2,0:12)
      real*8 alpha,beta,a1,a2,b1,b2
      alpha=sqrt(.175d0)
      beta=1d0/(48d0*alpha)
      b1=-beta/6d0
      b2= beta*5d0/6d0
      a1= 2d0*alpha
      a2= alpha
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-a1*dt,nbody_data)
      call kick(b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(2d0*a1*dt,nbody_data)
      call kick(-b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-(a1+a2)*dt,nbody_data)
      call kick(b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(2d0*a2*dt,nbody_data)
      call kick(-2d0*b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a2*dt,nbody_data)
      call kick(b2*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift((a1+a2)*dt,nbody_data)
      call kick(-b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(-2d0*a1*dt,nbody_data)
      call kick(b1*dt,nbody_data,0)
C Reset delta E so that we don't have a mis-match:
      nbody_data(0:nbody-2,7)=0d0
      call drift(a1*dt,nbody_data)
      return
      end

      subroutine sympstep(dt,nbody_data)
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mstar,mass(0:nbody-2),semi,ecc,period
      real*8 nbody_data(0:nbody-2,0:12)
      real*8 nbody_data_save(0:nbody-2,0:12)
      integer j
C Takes a full time step using a symplectic integration
C scheme (this one is the one from Duncan et al. 1998).
C Note: The dt/2 drifts from successive steps have been
C combined into a single dt drift to save time.
C 1) Compute an impulse, or 'Kick', based on the perturbation acceleration
      call kick(dt,nbody_data,0)
C 2) Compute a Keplerian 'Drift' based on the f/g functions:
      call drift(dt,nbody_data)
      call update(nbody_data)
      return
      end

      subroutine drift(dt,nbody_data)
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mstar,mass(0:nbody-2),semi,ecc,period
      real*8 r0_vec(0:2),v0_vec(0:2),nbody_data(0:nbody-2,0:12)
      real*8 r_vec(0:2),v_vec(0:2),dekep,dekep_fast
      common /masses/ mstar,mass,nplanet
      nplanet=nbody-1
      do iplanet=0,nplanet-1
C In Duncan et al. (1998) & Wisdom (2006), they recommend using 
C canonical heliocentric coordinates for the orbital evolution.  
C The following are canonical heliocentric coordinates
C (heliocentric positions, barycentric velocities):
        r0_vec(0:2)=nbody_data(iplanet,0:2)
        v0_vec(0:2)=nbody_data(iplanet,3:5)
        dekep=nbody_data(iplanet,7)
c        dekep_fast=dekep
C The Keplerian Hamiltonian *only* uses the mass of the star:
        call step_fg(mstar,dt,r0_vec,v0_vec,r_vec,v_vec,dekep)
        nbody_data(iplanet,0:2)=r_vec(0:2)
        nbody_data(iplanet,3:5)=v_vec(0:2)
        nbody_data(iplanet,7)=dekep
      enddo
      return
      end

      subroutine cross(dt,nbody_data)
C Computes the momentum correction 'cross-term' (aka 'Sun' term
C in Duncan et al. 1998):
      implicit none
      include 'nbody_include.for'
      integer iplanet,nplanet
      real*8 dt,mass(0:nbody-2),mstar,vstar(0:2)
      real*8 nbody_data(0:nbody-2,0:12)
      common /masses/ mstar,mass,nplanet
      nplanet=nbody-1
C See Duncan (1998), paragraph just after equation 33:
      vstar(0:2)=0d0
      do iplanet=0,nplanet-1
C Add up the planets' barycentric momenta:
        vstar(0:2)=vstar(0:2)+mass(iplanet)*nbody_data(iplanet,3:5)
      enddo
      vstar(0:2)=vstar(0:2)/mstar
C Now, change the positions of the planets by the stellar motion offset
C wrt the barycenter:
      do iplanet=0,nplanet-1
        nbody_data(iplanet,0:2)=nbody_data(iplanet,0:2)+dt*vstar(0:2)
      enddo
      return
      end

      subroutine kick(dt,nbody_data,force_save)
C Computes the derivatives of the coordinates for the planets
      implicit none
      include 'nbody_include.for'
      integer iplanet,kplanet,nplanet,force_save
      real*8 dt,accel_array(0:nbody-2,0:2),rik(0:2)
      real*8 mass(0:nbody-2),mstar
      real*8 nbody_data(0:nbody-2,0:12)
      common /masses/ mstar,mass,nplanet
      common /save_accel/ accel_array
C Now, compute the 'perturbation' acceleration for each planet due to all
C of the others:
      nplanet=nbody-1
      if(force_save.eq.0) then
        accel_array(0:nplanet-1,0:2)=0d0
        do iplanet=0,nplanet-2
          do kplanet=iplanet+1,nplanet-1
C Loop only over planets that are not the current planet:
                rik(0:2)=nbody_data(kplanet,0:2)-
     &          nbody_data(iplanet,0:2)
                rik(0:2)=rik(0:2)/(sqrt(sum(rik(0:2)**2)))**3
C Compute the acceleration of one planet due to the other...
              accel_array(iplanet,0:2)= accel_array(iplanet,0:2)
     &             +mass(kplanet)*rik(0:2)
              accel_array(kplanet,0:2)= accel_array(kplanet,0:2)
     &             -mass(iplanet)*rik(0:2)
          enddo
        enddo
      endif
C Now apply the 'kick' to each planet's barycentric velocity:
      nbody_data(0:nplanet-1,3:5)=nbody_data(0:nplanet-1,3:5)
     &          +dt*accel_array(0:nplanet-1,0:2)
      call cross(dt,nbody_data)
      return
      end
