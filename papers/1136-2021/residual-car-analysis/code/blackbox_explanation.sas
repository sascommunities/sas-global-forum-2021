proc iml;
    use WORK.THE_SALES_B;

    varNames2={'_MESES_EFECTIVOS' '_TCNEMISIONCO2' 'kms' 'pvp_bast' 'pvp_opc'};

    read all var varNames2 into x;
    read all var {FILTY} into d_filty;
    read all var {_TCCTIPOCOMBUSTIBLE _TPCDESTIPOADJUDICACION MSI_MARCA MSI_MODEL 
        subseg} into c [colname=cvar];

    test=(c[1, ][1, ]);
    u=unique(d_filty);
    cnt=j(ncol(u), 2, .);

    do i=1 to ncol(u);
        cnt[i, ]=element(d_filty, u[i])[+]||i;
    end;

    call sortndx(idx, cnt, {1}, {1});
    cnt_all=cnt[+, 1];
    cnt=cnt[idx, ]||(cusum(cnt[idx, 1])/cnt_all);
    pareto=0.8;
    xnew=cnt[loc(cnt[, 3] < pareto), ];
    pareto_filt=u[xnew[, 2]];
    gpts=20;
    d_idx=loc(d_filty=pareto_filt[1]);
    cutpts=do(x[d_idx, 1] [><], x[d_idx, 1] [<>], range(x[d_idx, 1])/(gpts-1));
    b=bin(x[d_idx, 1], cutpts`);
    call tabulate(BinNumber, Freq, b);
    biny=union(binnumber, 1:gpts);
    idx2=setdif(biny, binnumber);
    freky=j(gpts, 1, 0);
    freky[binnumber]=freq;
    freky2=t(freky);
    headers={'range' 'frek' 'all_frek'} || varnames2;
    freq_info=j(gpts, ncol(varnames2)+3, .);
    create SimOut from freq_info[colname=headers];
    u=pareto_filt;

    /* get unique values for groups */
    do i=1 to nrow(u);
        /* iterate over unique values */
        do j=1 to ncol(varNames2);
            d_idx=loc(d_filty=pareto_filt[i]);

            if range(x[d_idx, j])=0 then
                goto breakout;
            cutpts=do(x[d_idx, j] [><], x[d_idx, j] [<>], range(x[d_idx, j])/(gpts-1));
            b=bin(x[d_idx, j], cutpts`);
            call tabulate(BinNumber, Freq, b);
            biny=union(binnumber, 1:gpts);
            idx2=setdif(biny, binnumber);
            freky=j(gpts, 1, 0);
            freky[binnumber]=freq;
            freky2=t(freky);
            freq_info[, 4:ncol(varnames2)+3]=repeat(x[d_idx, 1:ncol(varnames2)] [:, ], 
                gpts, 1);
            freq_info[, 1:3]=cutpts`||freky||repeat((freky[+]), gpts, 1);
    breakout:
            append from freq_info;
        end;
    end;

    close SimOut;
    heady={'filty' 'nom'}||cvar;
    id_info=j(gpts, 2+ncol(cvar), "                                                                                                                     
        ");
    create simout2 from id_info[colname=heady];
    u=pareto_filt;

    /* get unique values for groups */
    do i=1 to nrow(u);
        /* iterate over unique values */
        do j=1 to ncol(varNames2);
            d_idx=loc(d_filty=pareto_filt[i]);

            if range(x[d_idx, j])=0 then
                goto breakout2;
            id_info=repeat(u[i]||varnames2[j]||(c[d_idx, ][1, ]), gpts, 1);
    breakout2:
            append from id_info;
        end;
    end;

    close SimOut2;
quit;
