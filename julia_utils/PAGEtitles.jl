############################################################################
#
#               FOLDER CONTAINING .MD FILES
#
############################################################################
path_prepath = "blog"
subfolder    = "PAGES"


############################################################################
#
#                           BASIC INFORMATION
#
############################################################################

using DataFrames

function previous_folder(path; nr_prev=1) 
    aux = ntuple(x->"..", nr_prev)
    abspath(joinpath("$(path)", aux...))
end



function capture_PAGEdescription(folder, file, name)
    file       = open("$folder\\$file", "r")
    content    = read(file, String)
    expression = Regex("$(name)\\s*=\\s*\"(?<group>.*)\"")
    xx         = match(expression, content)
    return string.(xx[:group])
end




function createTitle(file, title, date, update)
    toadd0(date)   = string("""<span style="font-size:70%">$(date)</span>""", " ")
    toadd1(file)   = string("<li><a href=\"", "/", "$(subfolder)/", "$(file)", "/", "\"",">")
    toadd2(title)  = string("$(title)",raw"""</a><br>""")
    toadd3(update) = string(ifelse("$(update)" .== "", "", """<span style="font-size:70%">(updated on $(update))</span>"""), raw"""</li><br>""")

    string(toadd1(file), toadd2(title), " ", toadd0(date), toadd3(update))
end

## function that creates the variable for config

function PAGElist_and_dftoc(subfolder)
    folder = joinpath(previous_folder(@__DIR__), "$(subfolder)")

    files   = readdir(folder)  |>  x -> x[startswith.(x, r"^\d")]  |>   #we keep those files that start with a number
            x-> sort!(x, rev=true)                                    #we sort them in descending order
    titles  = capture_PAGEdescription.(folder, files,"PAGEpost_name")
    dates   = capture_PAGEdescription.(folder, files,"PAGEpost_date")
    updates = capture_PAGEdescription.(folder, files,"PAGEpost_update")

    pagemd   = string.(["$(subfolder)\\"], files)

    files    = replace.(files, r".md$" => "") #we remove .md
    pagelink = string.(["$(subfolder)\\"], files)

    PAGEStoiter = string.(createTitle.(files, titles, dates, updates))


    chapter_nr  = eachindex(files)
    dftoc       = DataFrame(number=chapter_nr, name = files, pagemd = pagemd, pagelink = pagelink, 
                            title=titles, date=dates, update=updates)
    return PAGEStoiter, dftoc
end

PAGEStoiter, dftoc = PAGElist_and_dftoc(subfolder)


############################################################################
#
#                           TO CREATE THE NEXT AND PREVIOUS PAGE
#
############################################################################

function add_nextAndPrevious!(dftoc)
    prev_page = [dftoc[i+1, :pagemd] for i in 1:nrow(dftoc)-1]
    push!(prev_page,"")
    
    next_page = [vcat(dftoc.pagemd...)[i-1] for i in 2:nrow(dftoc)]
    pushfirst!(next_page,"")

    dftoc.prev_page = replace.(prev_page, r".md$" .=> "")
    dftoc.next_page = replace.(next_page, r".md$" .=> "")
end

add_nextAndPrevious!(dftoc)

dftoc[lastindex(dftoc.pagemd), :prev_page]  = replace(dftoc.pagemd[1], r".md$" => "")
dftoc[firstindex(dftoc.pagemd), :next_page] = replace(dftoc.pagemd[end], r".md$" => "")


############################################################################
#
#                           TO CREATE ASSETS LOCATION
#
############################################################################



# TO REFER TO ASSETS (for images and the link to codeDownload)
    assets_folder(PAGEfile) = "/assets/$(subfolder)/$(PAGEfile)"
dftoc.path_assets       = assets_folder.(dftoc.name)

let dftoc = dftoc
    assets_folder(PAGEfile) = "/assets/$(subfolder)/$(PAGEfile)"
    html_tree               = "https://github.com/alfaromartino/$(path_prepath)/tree/main/"
    dftoc.path_codeDownload = string.(html_tree, dftoc.path_assets, "/codeDownload")
end

