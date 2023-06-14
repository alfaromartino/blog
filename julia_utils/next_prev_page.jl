#these functions are applied in each page
using DataFrames

get_prevpage(dftoc, local_page) = string(first(dftoc[dftoc.pagemd.==local_page,:prev_page]))
get_nextpage(dftoc, local_page) = string(first(dftoc[dftoc.pagemd.==local_page,:next_page]))

