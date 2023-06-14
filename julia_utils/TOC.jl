using DataFrames

function previous_folder(path; nr_prev=1) 
    aux = ntuple(x -> "..", nr_prev)
    abspath(joinpath("$(path)", aux...))
 end

function capture_PAGEdescription(folder, file, name)
    file       = open("$folder\\$file", "r")
    content    = read(file, String)
    expression = Regex("$(name)\\s*=\\s*\"(?<group>.*)\"")
    xx         = match(expression, content)
    return string.(xx[:group])
end

folder = joinpath(previous_folder(@__DIR__), "PAGES")

files   = readdir(folder)  |>  x -> x[startswith.(x, r"^\d")]    #we keep those files that start with a number
titles  = capture_PAGEdescription.(folder, files,"CODINGpage_name")
dates   = capture_PAGEdescription.(folder, files,"CODINGpage_date")
updates = capture_PAGEdescription.(folder, files,"CODINGpage_update")

page_names = replace.(files, r".md$" => "") #we remove .md
pagemd     = string.(["PAGES\\"], files)
pagelink   = string.(["\\PAGES\\"], page_names)

function dftoc_pages(page_names)
    chapter_nr  = eachindex(page_names)
    dftoc       = DataFrame(number=chapter_nr, name = files, pagemd = pagemd, pagelink = pagelink, 
                            title=titles, date=dates, update=updates)
end

dftoc = dftoc_pages(page_names)


# TO CREATE THE NEXT AND PREVIOUS PAGE
function add_nextAndPrevious!(dftoc)
    next_page = [dftoc[i+1, :pagemd] for i in 1:nrow(dftoc)-1]
    push!(next_page,"")
    
    prev_page = [vcat(dftoc.pagemd...)[i-1] for i in 2:nrow(dftoc)]
    pushfirst!(prev_page,"")

    dftoc.next_page = replace.(next_page, r".md$" .=> "")
    dftoc.prev_page = replace.(prev_page, r".md$" .=> "")
end

add_nextAndPrevious!(dftoc)

dftoc[lastindex(dftoc.pagemd), :next_page] = replace(dftoc.pagemd[1], r".md$" => "")
dftoc[firstindex(dftoc.pagemd), :prev_page] = replace(dftoc.pagemd[end], r".md$" => "")

#we have to load dftoc in config.md