!**********************************************************************************************************************
! This is the code from the section (DYNAMIC.EQ.RUNINIT) ! Initialization, lines 3550 - 3941 of the original CSCAS code.
! The actual and dummy arguments are only for those variables that are dummy arguments for CSCAS. The type of all
! other variables are declared in the module CS_First_Trans_m. The type of only the dummy arguments are declared here.
! The variables and their units are defined in CSCAS.
!
! SUBROUTINE CS_SeasInit_Final sets up the output descriptors, checks controls and writes information to the overview and 
! work files
!**********************************************************************************************************************
    
    SUBROUTINE CS_SeasInit_Final ( &
        ALBEDOS     , CLOUDS      , CN          , IDETG       , ISWDIS      , ISWNIT      , ISWWAT      , KCAN        , &
        KEP         , ON          , RN          , RNMODE      , RUN         , RUNI        , RWUMX       , SLPF        , &
        SN          , TAIRHR      , TN           &                                                                                        
        )
        
        USE CS_Formats_m
        USE CS_First_Trans_m
       
        IMPLICIT NONE
        
        CHARACTER(LEN=1) IDETG       , ISWDIS      , ISWNIT      , ISWWAT      , RNMODE        
        INTEGER CN          , ON          , RN          , RUN         , RUNI        , SN          , TN         
        REAL    ALBEDOS     , CLOUDS      , KCAN        , KEP         , RWUMX       , SLPF        , TAIRHR(24)           
        INTEGER TVILENT                                                                       ! Integer function call.
        
        
!-----------------------------------------------------------------------
!       Create output descriptors
!-----------------------------------------------------------------------

        ! Run name
        IF (runname(1:6).EQ.'      ' .OR.runname(1:3).EQ.'-99') runname = tname
        
        ! Composite run variable
        IF (RUNI.LT.10) THEN
            WRITE (RUNRUNI,'(I3,A1,I1,A3)') RUN,',',RUNI,'   '
        ELSEIF (RUNI.GE.10.AND.RUNI.LT.100) THEN
            WRITE (RUNRUNI,'(I3,A1,I2,A2)') RUN,',',RUNI,'  '
        ELSE
            WRITE (RUNRUNI,'(I3,A1,I3,A1)') RUN,',',RUNI,' '
        ENDIF
        IF (RUN.LT.10) THEN
            RUNRUNI(1:6) = RUNRUNI(3:8)
            RUNRUNI(7:8) = '  '
            ! Below is to give run number only for first run
            IF (RUNI.LE.1) RUNRUNI(2:8) = '       '
        ELSEIF (RUN.GE.10.AND.RUN.LT.100) THEN
            RUNRUNI(1:7) = RUNRUNI(2:8)
            RUNRUNI(8:8) = ' '
            ! Below is to give run number only for first run
            IF (RUNI.LE.1) RUNRUNI(3:8) = '      '
        ENDIF
        
        ! Composite treatment+run name
        CALL LTRIM (RUNNAME)
        RUNNAME = TRIM(RUNNAME)
        CALL LTRIM (TNAME)
        TNAME = TRIM(TNAME)
        LENTNAME = MIN(15,TVILENT(TNAME))
        LENRNAME = MIN(15,TVILENT(RUNNAME))
        IF (LENRNAME.GT.5) THEN
            TRUNNAME = RUNNAME(1:LENRNAME)//' '//MODNAME
        ELSE
            TRUNNAME = TNAME(1:LENTNAME)//' '//MODNAME
        ENDIF
        IF (MEEXP.EQ.'E') THEN
            CALL LTRIM (TRUNNAME)
            LENTNAME = TVILENT(TRUNNAME)
            TRUNNAME = TRUNNAME(1:LENTNAME)//' EXPERIMENTAL'
        ENDIF
        
        ! File header
        IF (CN.GT.1) THEN
            IF (TN.LT.10) THEN
                WRITE (OUTHED, FMT7104) RUNRUNI(1:5),EXCODE,TN,RN,CN,TRUNNAME
            ELSEIF (TN.GE.10.AND.TN.LT.100) THEN
                WRITE (OUTHED, FMT7105) RUNRUNI,EXCODE,TN,RN,CN,TRUNNAME
            ELSEIF (TN.GE.10 .AND. TN.LT.100) THEN
                WRITE (OUTHED, FMT7106) RUNRUNI,EXCODE,TN,RN,CN,TRUNNAME
            ENDIF
        ELSE
            IF (TN.LT.10) THEN
                WRITE (OUTHED, FMT7107) RUNRUNI(1:5),EXCODE,TN,TRUNNAME
            ELSEIF (TN.GE.10.AND.TN.LT.100) THEN
                WRITE (OUTHED, FMT7108) RUNRUNI,EXCODE,TN,RN,TRUNNAME
            ELSEIF (TN.GE.10 .AND. TN.LT.100) THEN
                WRITE (OUTHED, FMT7109) RUNRUNI,EXCODE,TN,RN,TRUNNAME
            ENDIF
        ENDIF
        
        !-----------------------------------------------------------------------
        !       Check controls
        !-----------------------------------------------------------------------
        
        ! Water and N uptake methods .. MEWNU 
        ! R=RLV+LL complex,W=RLV for h20,N=RLV for N,B=RLV for both
        IF (MEWNU.NE.'R') THEN 
            IF (MEWNU.NE.'W') THEN 
                IF (MEWNU.NE.'N') THEN 
                    IF (MEWNU.NE.'B') THEN 
                        MEWNU = 'R'
                    ENDIF        
                ENDIF        
            ENDIF        
        ENDIF        
        IF (MEPHO.NE.'I') THEN
            IF (MEPHO.NE.'M') THEN
                IF (MEPHO.NE.'R') THEN
                    WRITE(MESSAGE(1),'(A22,A1,A15,A19)')'Photosynthesis method ',MEPHO,' not an option ',' Changed to R (RUE)'
                    
                    CALL WARNING(1,'CSCGR',MESSAGE)
                    WRITE(FNUMWRK,*)' '
                    WRITE(FNUMWRK,'(A23,A1,A15,A19)')'Photosynthesis method ',MEPHO,' not an option ',' Changed to R (RUE)'
                    MEPHO = 'R'
                ENDIF
            ENDIF
        ENDIF
        ! Other CSM codes are:
        !  C Canopy photosynthesis curve.
        !  L Leaf photosynthesis response curve
        IF (IHARI.NE.'M') THEN
            IF (hnumber.LE.0) THEN 
                WRITE(MESSAGE(1),'(A37,A13,A1)')'No harvest date set although planting','flag set to: ',IHARI
                MESSAGE(2)='Flag reset to M.'
                CALL WARNING(2,'CSCGR',MESSAGE)
                IHARI = 'M'                      
            ENDIF
        ENDIF
        
        !-------------------------------------------------------------------
        !       Write run information to Overview and Work output files
        !-------------------------------------------------------------------
        
        ! To avoid problems of writing to closed file in Sequence mode 
        INQUIRE (FILE = 'WORK.OUT',OPENED = FOPEN)
        IF (.NOT.FOPEN) THEN
            OPEN (UNIT = FNUMWRK,FILE = 'WORK.OUT')
            WRITE(fnumwrk,*) 'CSCGR  Cassava Crop Module '
        ENDIF
        
        WRITE(fnumwrk,*)' '
        WRITE(fnumwrk,'(A18,A10,I3)')' GENERAL INFO FOR ',excode,tn
        WRITE(fnumwrk,*)' FILE       ',FILEIO(1:60)
        WRITE(fnumwrk,*)' EXPERIMENT ',EXCODE
        WRITE(fnumwrk,*)' TREATMENT  ',TN
        WRITE(fnumwrk,*)' REPLICATE  ',RN
        WRITE(fnumwrk,*)' '
        WRITE(fnumwrk,*)' MODEL      ',MODEL
        WRITE(fnumwrk,*)' MODULE     ',MODNAME
        WRITE(fnumwrk,'(A13,I6)')'  VERSION    ',VERSIONCSCAS
        WRITE(fnumwrk,*)' PRODUCT    ',HPROD
        WRITE(fnumwrk,*)' RNMODE     ',RNMODE
        IF (RUN.LT.10) THEN
            WRITE(fnumwrk,'(A13,I1)')' RUN        ',RUN   
        ELSEIF (RUN.GE.10.AND.RUN.LT.1000) THEN
            WRITE(fnumwrk,'(A13,I2)')' RUN        ',RUN   
        ELSE
            WRITE(fnumwrk,'(A13,I3)')' RUN        ',RUN   
        ENDIF
        WRITE(fnumwrk,*)' CULTIVAR   ',CUDIRFLE(1:60)
        WRITE(fnumwrk,*)' ECOTYPE    ',ECDIRFLE(1:60)
        WRITE(fnumwrk,*)' SPECIES    ',SPDIRFLE(1:60)
        WRITE(fnumwrk,*)' METHODS '
        IF (MEEXP.EQ.'E')WRITE(fnumwrk,'(A26,A1)')'   EXPERIMENTAL ALGORITHM ',MEEXP
        WRITE(fnumwrk,'(A26,A1)') '   PHOTOSYNTHESIS         ',MEPHO
        WRITE(fnumwrk,'(A26,A1,1X,A1)') '   WATER AND N SWITCHES   ',ISWWAT,ISWNIT
        WRITE(fnumwrk,'(A26,A1)') '   LEAF LIFE SWITCH       ',CFLLFLIFE     
        WRITE(fnumwrk,'(A26,A3)')  '   N UPTAKE               ',MERNU
        WRITE(fnumwrk,'(A26,I1)') ' '
        WRITE(fnumwrk,'(A26,I1)') '  CROP COMPONENT          ',CN
        WRITE(fnumwrk,'(A26,A6,2X,A16)')'  CULTIVAR                ',VARNO,VRNAME
        IF (IPLTI.NE.'A') THEN
            WRITE(fnumwrk,'(A23,I7)')'  PLANTING DATE TARGET:',PLYEARDOYT
        ELSE
            WRITE(fnumwrk,'(A23)')'  AUTOMATIC PLANTING   '              
            WRITE (fnumwrk,*) '  PFIRST,PLAST :',pwdinf,pwdinl
            WRITE (fnumwrk,*) '  HFIRST,HLAST :',hfirst,hlast
        ENDIF
        WRITE (fnumwrk,'(A15,2F7.1)')'  PLTPOP,ROWSPC',PPOP,ROWSPC !LPM 06MAR2016 To have just one name for PPOP
        WRITE (fnumwrk,'(A15,2F7.1)')'  SDEPTH,SDRATE',SDEPTH,SDRATE
        IF (sdepthu.LT.sdepth)WRITE (fnumwrk,'(A15,F7.1)')'  SHOOT DEPTH  ',SDEPTHU      
        WRITE (fnumwrk,'(A15,2F7.1,A6)')'  SEEDRS,SEEDN ',SEEDRSI*PPOP*10.0,SEEDNI*PLTPOPP*10.0,' kg/ha' !LPM 06MAR2016 To have just one name for PPOP
        WRITE (fnumwrk,'(A15, F7.1)') '  PLMAGE       ',PLMAGE
        ! LAH NEED TO CHECK HARVEST OPTIONS FOR dap,growth stage.
        ! DISCUSS WITH CHP
        IF (IHARI.NE.'M') THEN
            IF (IHARI.NE.'A') THEN
                WRITE(fnumwrk,'(A22,I7)')'  HARVEST DATE TARGET:',YEARDOYHARF 
            ELSE
                WRITE(fnumwrk,'(A22,A9)')'  HARVEST DATE TARGET:','AUTOMATIC'  
            ENDIF 
        ELSE
            WRITE(fnumwrk,'(A22,A8)')'  HARVEST DATE TARGET:','MATURITY'  
        ENDIF
        WRITE (fnumwrk,'(A15,2F7.1)') '  HPCF,HBPCF   ',HPCF,HBPCF
        
        IF (IDETG.NE.'N') THEN
            WRITE(fnumwrk,*)' '
            WRITE(fnumwrk,*)' MAJOR COEFFICIENTS AFTER CHECKING'
            WRITE(fnumwrk,*)' Development '
            WRITE(fnumwrk,*)'  Ppsen  ',Ppsen   
            WRITE(fnumwrk,*)'  Ppfpe  ',Dfpe 
            IF (Ppsen.EQ.'LQ') WRITE(fnumwrk,*)'  Ppexp  ',Ppexp   
            WRITE(fnumwrk,*)'  Ppthr  ',Ppthr   
            WRITE(fnumwrk,*)'  Pps1   ',Dayls(1)
            WRITE(fnumwrk,*)'  Pps2   ',Dayls(2)
            !WRITE(fnumwrk,*)'  Mstg   ',Mstg    !LPM 07MAR15 There is not a maturity stage for cassava
            !DO L = 1,MSTG                      !LPM 07MAR15 MSTG to PSX
            DO L = 0,PSX
                WRITE(fnumwrk,'(A15,I2,2F8.1)')'  B#->,Deg.d-> ',l,Pdl(L),PD(l)
            ENDDO  
            WRITE(fnumwrk,*)' Plant. stick stages '
            WRITE(fnumwrk,*)'  Crfr   ',Crfr 
            WRITE(fnumwrk,*)' CH2O reserves '
            WRITE(fnumwrk,*)'  Rsfrs  ',rsfrs
            WRITE(fnumwrk,*)'  Rspco  ',rspco
            WRITE(fnumwrk,*)' Radiation use  '
            WRITE(fnumwrk,*)'  Parue  ',Parue
            WRITE(fnumwrk,*)'  Paru2  ',Paru2
            WRITE(fnumwrk,*)' Shoots  '
            WRITE(fnumwrk,*)'  Sgro   ',shgr(1),shgr(2)
            WRITE(fnumwrk,*)'  Brfx(1)',brfx(1)
            WRITE(fnumwrk,*)'  Brfx(2)',brfx(2)
            WRITE(fnumwrk,*)'  Brfx(3)',brfx(3)
            WRITE(fnumwrk,*)'  Brfx(4)',brfx(4)
            WRITE(fnumwrk,*)'  Brfx(5)',brfx(5)
            WRITE(fnumwrk,*)'  Brfx(6)',brfx(6)
            WRITE(fnumwrk,*)'  Canhts ',canhts
            WRITE(fnumwrk,*)' Leaves     '
            WRITE(fnumwrk,*)'  La1s   ',La1s
            WRITE(fnumwrk,*)'  Laxs   ',Laxs
            !WRITE(fnumwrk,*)'  Lafs   ',Lafs        !LPM 05JUN2015 LAFS is not used 
            !WRITE(fnumwrk,*)'  Laxnd,2',Laxno,Laxn2 !LPM 05JUN2016 LAXNO LAXN2 are not used
            !WRITE(fnumwrk,*)'  Lafnd  ',Lafnd
            WRITE(fnumwrk,*)'  Slas,Slasmn  ',Laws,lawmnfr
            WRITE(fnumwrk,*)'  Slacf,Slaff  ',Lawcf,Lawff
            WRITE(fnumwrk,*)'  Slatr,Slats  ',Lawtr,Lawts
            WRITE(fnumwrk,*)'  Slawr        ',Lawwr
            WRITE(fnumwrk,*)'  Lpefr        ',Lpefr
            !WRITE(fnumwrk,*)'  Phints,Phntf ',Phints,Phintfac  !LPM 21MAY2015 PHINTS is not used           
            WRITE(fnumwrk,*)'  Llifg,a,s,x  ',Llifg,Llifa,Llifs,Llifx  
            WRITE(fnumwrk,*)'  Lwlos  ',Lwlos                
            WRITE(fnumwrk,*)'  Laixx,Parix  ',Laixx,Parix       
            WRITE(fnumwrk,*)' Stems      '
            WRITE(fnumwrk,*)'  Saws,Serx,sesr          ',Saws,Serx,sesr  !LPM 21MAR2016 Added SESR            
            WRITE(fnumwrk,*)' Roots  '
            WRITE(fnumwrk,*)'  Rdgs   ',Rdgs
            WRITE(fnumwrk,*)'  Rresp  ',Rresp
            WRITE(fnumwrk,*)' Storage roots '
            !WRITE(fnumwrk,*)'  Srfr   ',Srfr !LPM 08 JUN2015 SRFR is not used   
            !WRITE(fnumwrk,*)'  Dusri  ',Dusri  !LPM 05JUN2015 DUSRI is not used
            WRITE(fnumwrk,*)'  Hmpc   ',Hmpc
            WRITE(fnumwrk,*)' Nitrogen uptake concentration factors'
            WRITE(fnumwrk,*)'  Rtno3,Rtnh4 ',rtno3,rtnh4 
            WRITE(fnumwrk,*)'  No3cf,H2ocf ',no3cf,h2ocf
            WRITE(fnumwrk,*)'  No3mn,Nh4mn ',no3mn,nh4mn
            WRITE(fnumwrk,*)' Nitrogen concentrations'
            WRITE(fnumwrk,*)'  Ln%s   ',LNPCS           
            WRITE(fnumwrk,*)'  Ln%mn  ',LNPCMN            
            WRITE(fnumwrk,*)'  Sn%s   ',SNPCS           
            WRITE(fnumwrk,*)'  Sn%mn  ',SNPCMN           
            WRITE(fnumwrk,*)'  Rn%s   ',RNPCS           
            WRITE(fnumwrk,*)'  Rn%mn  ',RNPCMN          
            WRITE(fnumwrk,*)'  Srnpcs ',SRNPCS          
            WRITE(fnumwrk,*)' Nitrogen stress limits '
            WRITE(fnumwrk,*)'  Nfpu,L ',NFPU,NFPL       
            WRITE(fnumwrk,*)'  Nfgu,L ',NFGU,NFGL       
            WRITE(fnumwrk,*)'  Nfsu   ',NFSU           
            WRITE(fnumwrk,*)'  Nllg   ',NLLG           
            
            WRITE(FNUMWRK,*)' '
            WRITE(FNUMWRK,'(A17)')' BRANCH NODE NOS.'
            WRITE(FNUMWRK,'(A23)')'   BRANCH NODE #    ABV'
            !DO L = 1,MSTG                       !LPM 07MAR15 MSTG to PSX
            DO L = 0,PSX
                WRITE(FNUMWRK,'(I6,I10,2X,A5)')L,NINT(LNUMTOSTG(L)),PSABV(L)
            ENDDO
            
            WRITE(FNUMWRK,*)' '
            WRITE(FNUMWRK,'(A22)')' TEMPERATURE RESPONSES'
            IF (TRGEM(1).GT.-99.0) THEN
                WRITE(FNUMWRK,'(A9,4F5.1)')'   TRGEM ',TRGEM(1),TRGEM(2),TRGEM(3),TRGEM(4)
            ENDIF
            WRITE(FNUMWRK,'(A9,4F5.1)')'   TRDV1 ', TRDV1(1),TRDV1(2),TRDV1(3),TRDV1(4)
            WRITE(FNUMWRK,'(A9,4F5.1)')'   TRLFG ', TRLFG(1),TRLFG(2),TRLFG(3),TRLFG(4)
            WRITE(FNUMWRK,'(A9,4F5.1)')'   TRPHS ', TRPHS(1),TRPHS(2),TRPHS(3),TRPHS(4)
            IF (ISWDIS(LENDIS:LENDIS).NE.'N') THEN
                WRITE (fnumwrk,*) ' '
                WRITE (fnumwrk,*) 'DISEASE INITIATION AND GROWTH ASPECTS'
                WRITE (fnumwrk,'(A13,A49)')'             ','  DATE   GROWTH FACTOR  FAVOURABILITY REQUIREMENT'
                WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 1 ',DIDAT(1),DIGFAC(1),DIFFACR(1)
                WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 2 ',DIDAT(2),DIGFAC(2),DIFFACR(2)
                WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 3 ',DIDAT(3),DIGFAC(3),DIFFACR(3)
                WRITE (fnumwrk,*) ' '
                IF (DCTAR(1).GT.0) WRITE (fnumwrk,*)'DISEASE CONTROL DATES,GROWTH FACTORS,AND DURATION'
                DO L=1,DCNX
                    IF (DCTAR(L).EQ.1) WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 1 ',DCDAT(L),DCFAC(L),DCDUR(L)
                    IF (DCTAR(L).EQ.2) WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 2 ',DCDAT(L),DCFAC(L),DCDUR(L)
                    IF (DCTAR(L).EQ.3) WRITE (fnumwrk,'(A12,I10,2F10.1)')'  DISEASE 3 ',DCDAT(L),DCFAC(L),DCDUR(L)
                ENDDO
            ENDIF
            
        ENDIF
        
        !-----------------------------------------------------------------------
        !       Set equivalences to avoid compile errors
        !-----------------------------------------------------------------------
        
        tvr1 = tairhr(1)
        ! When running in CSM
        IF (FILEIOT.EQ.'DS4') THEN
            ALBEDO = ALBEDOS  ! Previously 0.2
            CLOUDS = 0.0
        ELSE
            ALBEDO = ALBEDOS  
        ENDIF
        
        !-----------------------------------------------------------------------
        !       Record starting values and files
        !-----------------------------------------------------------------------
        
        CNI = CN
        KCANI = KCAN
        ONI = ON
        RNI = RN
        RWUMXI = RWUMX
        SNI = SN
        TNI = TN
        KEPI = KEP
        
        !-----------------------------------------------------------------------
        !       Create and write warning messages re. input and output variables
        !-----------------------------------------------------------------------
        
        IF (SLPF.LT.1.0) THEN
            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,*) ' WARNING  Soil fertility factor was less than 1.0: ',slpf
        ENDIF  
        
        WRITE(FNUMWRK,*)' '
        WRITE(FNUMWRK,'(A22)')' OUTPUTS              '
        ! Control switch for OUTPUT file names
        CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'FNAME',fname)
        IF (FNAME.EQ.'Y') THEN
            WRITE(FNUMWRK,*)' File names switched from standard. '
        ELSE  
            WRITE(FNUMWRK,*)' Using standard file names. '
        ENDIF   
        
        ! Output choices
        ! 1=Reserves in laminae,stem,Plant. stick,SLA;stem includes petioles
        ! 2=No reserves;stem includes petioles
        ! 3=No reserves;stem does not include petioles
        OUTCHOICE = 3
        IF (OUTCHOICE.EQ.2) THEN
            WRITE(MESSAGE(1),'(A36,A37)')'  NO reserve CH2O included in the wt',' of leaves,stems,and Plant. stick.          ' 
            CALL WARNING(1,'CSCGR',MESSAGE)
            WRITE(FNUMWRK,'(A36,A38)')'  NO reserve CH2O included in the wt',' of leaves,stems,and Plant. stick.           '
            WRITE(FNUMWRK,'(A36)')'  Stem weight includes the petioles.'
        ELSEIF (OUTCHOICE.EQ.3) THEN
            WRITE(MESSAGE(1),'(A36,A37)')'  NO reserve CH2O included in the wt',' of leaves,stems,and Plant. stick.          ' 
            CALL WARNING(1,'CSCGR',MESSAGE)
            WRITE(FNUMWRK,'(A36,A38)')'  NO reserve CH2O included in the wt',' of leaves,stems,and Plant. stick.           '
            WRITE(FNUMWRK,'(A45)')'  Stem weight does NOT includes the petioles.'
        ENDIF  
        
        WRITE(FNUMWRK,*)' '
        WRITE(FNUMWRK,'(A22)')' DURING RUN STATUS:   '
        
    END SUBROUTINE CS_SeasInit_Final
