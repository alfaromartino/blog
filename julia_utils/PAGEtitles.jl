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



folder = joinpath(previous_folder(@__DIR__), "PAGES")

files   = readdir(folder)  |>  x -> x[startswith.(x, r"^\d")]  |>   #we keep those files that start with a number
          x-> sort!(x, rev=true)                                    #we sort them in descending order
titles  = capture_PAGEdescription.(folder, files,"PAGEpost_name")
dates   = capture_PAGEdescription.(folder, files,"PAGEpost_date")
updates = capture_PAGEdescription.(folder, files,"PAGEpost_update")

pagemd   = string.(["PAGES\\"], files)

files    = replace.(files, r".md$" => "") #we remove .md
pagelink = string.(["\\PAGES\\"], files)


function createTitle(file, title, date, update)
    toadd0(date)   = string("""<span style="font-size:70%">$(date)</span>""", " ")
    toadd1(file)   = string("<li><a href=\"", "/", "PAGES/", "$(file)", "/", "\"",">")
    toadd2(title)  = string("$(title)",raw"""</a><br>""")
    toadd3(update) = string(ifelse("$(update)" .== "", "", """<span style="font-size:70%">(updated on $(update))</span>"""), raw"""</li><br>""")

    string(toadd1(file), toadd2(title), " ", toadd0(date), toadd3(update))
end


PAGEStoiter = string.(createTitle.(files, titles, dates, updates))


function dftoc_pages(files)
    chapter_nr  = eachindex(files)
    dftoc       = DataFrame(number=chapter_nr, name = files, pagemd = pagemd, pagelink = pagelink, 
                            title=titles, date=dates, update=updates)
end

dftoc = dftoc_pages(files)


# TO CREATE THE NEXT AND PREVIOUS PAGE
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
