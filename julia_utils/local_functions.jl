#these functions are applied in each page
using DataFrames

# function to retrieve previous and next page
get_prevpage(dftoc, local_page) = string(first(dftoc[dftoc.pagemd.==local_page,:prev_page]))
get_nextpage(dftoc, local_page) = string(first(dftoc[dftoc.pagemd.==local_page,:next_page]))

# functino to retrieve the path of assets and for codeDownload
get_pathassets(dftoc, local_page)       = string(first(dftoc[dftoc.pagemd.==local_page,:path_assets]))
get_pathcodeDownload(dftoc, local_page) = string(first(dftoc[dftoc.pagemd.==local_page,:path_codeDownload]))

