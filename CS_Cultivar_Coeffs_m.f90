Module CS_Cultivar_Coeffs_m
    
    REAL    :: LNUM_slope            ! Slope of the leaf number relationship 
    REAL    :: Tb_cul_leaf_size      ! Base temperature for leaf size increase 
    DATA Tb_cul_leaf_size /12.0/     ! LPM 28feb15 it would be a cultivar coefficient (for testing)
    REAL    :: nod_cul               ! Node weight of the stem for BR = 0 (first stem of the shoot before branching) at harvest (it should be a fix amount of thermal time) 
    DATA nod_cul /5.5992/            ! LPM 11APR15 it would be a cultivar coefficient (for testing)
End Module CS_Cultivar_Coeffs_m