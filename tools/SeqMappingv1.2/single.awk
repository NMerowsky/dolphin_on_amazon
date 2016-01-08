NR==2 {
    RDS_T=$1
}
NR==3 {
    RDS_P=$1" "$2
}
NR==4 {
    a=$1
    RDS_C1=$1" "$2
}
NR==5 {
    b=$2
    RDS_C2=$1" "$2
}
NR==6 {
    ALGN_T=a+b" ("$1")"
}

END {
    fmt="%s\t%s\t%s\t%s\t%s\t%s\n"
    #printf fmt, "File", "Reads", "Paired reads", "Conc reads 1", "Conc Reads >1", "Total align"
    printf fmt, name, RDS_T, RDS_P, RDS_C1, RDS_C2, ALGN_T
}

