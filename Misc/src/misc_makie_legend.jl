using GLMakie, CairoMakie, StatsBase 
using Jchemo

## https://docs.makie.org/v0.19/examples/blocks/legend/index.html

n = 100
x = range(0, 10; length = n)
y1 = sin.(x)
y2 = cos.(x)

f, ax = lines(x, y1; color = :red, label = "sin")
lines!(ax, x, y2; color = :green, label = "cos")
axislegend()
f

f = Figure(size = (500, 300))
ax = Axis(f[1, 1]) 
lines!(ax, x, y1; color = :red, label = "sin")
lines!(ax, x, y2; color = :green, label = "cos")
axislegend("Function"; position = :lb, framevisible = false)
f 

n = 1000
x = rand(n)
typ = rand(1:3, n)
lev = sort(unique(typ))
nlev = length(lev)
colm = (:red, :blue, :orange)
f = Figure(size = (500, 300))
ax = Axis(f[1, 1], xlabel = "x")
for i = 1:nlev
    s = typ .== lev[i]
    hist!(ax, x[s] .+ i / 1.2; bins = 50, color = (colm[i], .5), label = string(lev[i]))
end
axislegend("Type")
f

#### With Legend
f = Figure()
Axis(f[1, 1])
elt1 = MarkerElement(color = "red", marker = '●', markersize = 15)
elt2 = MarkerElement(color = "blue", marker = 'o', markersize = 15)
Legend(f[1, 2], [elt1, elt2], ["A", "B"], rowgap = 10)
f

f = Figure(size = (500, 300))
ax = Axis(f[1, 1], xlabel = "x")
for i = 1:nlev
    s = typ .== lev[i]
    hist!(ax, x[s] .+ i / 1.2; bins = 50, color = (colm[i], .5), label = string(lev[i]))
end
f[1, 2] = Legend(f, ax, "Type", framevisible = false)
f

f = Figure(size = (800, 300))
ax = Vector{Any}(nothing, 3)
y = [5.82; 4.00; 1.60; 4.23; 2.20; 1.63; 6.10; 6.30; 6.13]
z = [5.26; 3.65; 1.69; 4.35; 2.12; 1.40; 4.60; 6.96; 5.18]
x = collect(1:length(y))
ax[1] = Axis(f, xlabel = "Error", ylabel = "k", yticks = (x, string.(x)), title = "Ligneous")
lines!(ax[1], y, x)
lines!(ax[1], z, x)
f[1, 1] = ax[1] 
y = [2.84; 2.66; 2.80; 2.63; 1.02; .75; 4.79; 3.52; 4.61]
z = [2.99; 2.58; 2.48; 2.63; .93; .81; 4.60; 3.60; 4.41]
ax[2] = Axis(f, xlabel = "Error", ylabel = "k", yticks = (x, string.(x)), title = "Grasslands")
lines!(ax[2], y, x)
lines!(ax[2], z, x)
f[1, 2] = ax[2] 
y = [1.73; .70; 1.16; 1.59; .63; .68; 2.83; 2.20; 2.57]
z = [1.85; .89; 1.28; 1.68; .64; .70; 2.83; 2.49; 2.71]
ax[3] = Axis(f, xlabel = "Error", ylabel = "k", yticks = (x, string.(x)), title = "Sorghum")
lines!(ax[3], y, x, label = "Forages")
lines!(ax[3], z, x, label = "Specific")
f[1, 3] = ax[3] 
f[1, 4] = Legend(f, ax[3], "Training", framevisible = false)
f

n = 300
x = rand(n)
y = 2 * x .+ 1 + rand(n)
typ = sample(["A"; "B"; "C"], n)
lev = sort(unique(typ))
nlev = length(lev)
group = recodcat2int(typ)
colsh = :Dark2_5
f = Figure(size = (500, 300))
colm = cgrad(colsh; categorical = true, alpha = .7)[1:nlev] 
ax = Axis(f, xlabel = "x", ylabel = "y")
scatter!(ax, x, y; markersize = 15, color = group, colormap = colm)
f[1, 1] = ax 
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 20) for i in 1:nlev]
title = "Category"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, backgroundcolor = :lightgrey, 
    framevisible = true, framecolor = :grey)
f

x = [ones(3); 2 * ones(3)]
y = rand(6)
grp = repeat(1:3, 2)
colors = Makie.wong_colors()
f = Figure(size = (500, 400))
ax = Axis(f[1, 1], yticks = (1:2, ["hays"; "legumes"]), title = "Error rate")
barplot!(ax, x, y; direction = :x, dodge = grp, color = colors[grp])
lab = ["A"; "B"; "C"] 
elt = [PolyElement(polycolor = colors[i]) for i in 1:length(lab)]
title = "Model"
Legend(f[1, 2], elt, lab, title)
f

f = Figure(size = (500, 400))
ax = Axis(f[1, 1], yticks = (1:2, ["hays"; "legumes"]), title = "Error rate")
barplot!(ax, x, y; direction = :x, dodge = grp, color = colors[grp])
lab = ["A"; "B"; "C"]
mks_l = 10
elt1 = MarkerElement(color = colm[1], marker = '●', markersize = mks_l)
elt2 = MarkerElement(color = colm[2], marker = '●', markersize = mks_l)
elt3 = MarkerElement(color = colm[3], marker = '●', markersize = mks_l)
elt = [elt1; elt2; elt3]
title = "Model"
Legend(f[1, 2], elt, lab, title)
f

