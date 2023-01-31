## CairoMakie, GLMakie and WGLMakie are different backend packages
## Each backend re-exports Makie.jl ==> no need to install Makie.jl 
## WGLMakie: 2D and 3D interactive plots working within browsers

## Docs
## https://docs.makie.org/stable/
## https://docs.juliahub.com/AbstractPlotting/6fydZ/0.12.12/index.html
## https://towardsdatascience.com/makie-high-level-beautiful-plots-3ae670de2fa1 # Good intro 
## https://beautiful.makie.org/dev/

## The active repository is:
## https://github.com/JuliaPlots/Makie.jl
## (e.g. CairoMakie.jl repository is deprecated)

## The install is:
add CairoMakie
## or
add GLMakie

using CairoMakie
using GLMakie

## To pass to one backend to another
CairoMakie.activate!()  # ==> backend CairoMakie is used
GLMakie.activate!()     # ==> backend GLMakie is used

using Jchemo
res = scatter(randn(100, 2)) 
pnames(res)

################# ABLINES!, VLINES!, HLINES! 

n = 10
x = rand(n) ; y = rand(n)
f, ax = scatter(x, y)
hlines!(ax, 0)
vlines!(ax, [0; 1]; color = [:green, :purple])
ablines!(ax, 0, 1; color = :lightgrey)
f

################# BARPLOTS 

## https://docs.makie.org/stable/examples/plotting_functions/barplot/

df = DataFrame(
    x = [1, 1, 1, 2, 2, 2],
    height = 0.1:0.1:0.6,
    grp = [1, 2, 3, 1, 2, 3])
df.std = .1 * df.height
df

barplot(df.x, df.height; 
    dodge = df.grp, color = df.grp,
    axis = (xticks = (1:2, ["left", "right"]),
        title = "Dodged bars"))

barplot(df.x, df.height; direction = :x,
    dodge = df.grp, color = df.grp,
    axis = (yticks = (1:2, ["left", "right"]),
        title = "Dodged bars"))

f = Figure()
ax = Axis(f[1, 1], xticks = (1:2, ["left", "right"]),
        title = "Dodged bars")
barplot!(ax, df.x, df.height, dodge = df.grp,
    color = df.grp)
z = [.73; 1; 1.28; 1.73; 2; 2.28]
errorbars!(ax, z, df.height, df.std, color = :red) 
f

f = Figure()
ax = Axis(f[1,1], xticks = (1:2, ["left", "right"]),
    title = "Dodged bars with legend")
barplot!(ax, df.x, df.height, dodge = df.grp,
    color = colors[df.grp])
lab = ["group 1", "group 2", "group 3"]
elt = [PolyElement(polycolor = colors[i]) for i in 1:length(lab)]
title = "Groups"
Legend(f[1, 2], elt, lab, title)
f

################# BOXPLOTS

## https://docs.makie.org/stable/examples/plotting_functions/boxplot/

n = 200
x = rand(1:3, n) ; y = randn(n)
grp = rand(1:2, n)

boxplot(x, y)

boxplot(x, y; orientation = :horizontal)

boxplot(x, y, 
    dodge = grp, show_notch = true, 
    color = grp)

boxplot(x, y, 
    dodge = grp, show_notch = true, 
    color = grp,
    axis = (xticks = (1:3, ["A", "B", "C"]),
        title = "Dodged bars"))

colors = Makie.wong_colors()
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1],
    xticks = (1:3, ["A", "B", "C"]), title = "Dodged bars")
boxplot!(ax, x, y, 
    dodge = grp, show_notch = true, 
    color = colors[grp])
lab = ["group 1", "group 2"]
elt = [PolyElement(polycolor = colors[i]) for i in 1:length(lab)]
title = "Groups"
Legend(f[1, 2], elt, lab, title)
f

################# COLORS

## https://docs.makie.org/stable/documentation/colors/
## https://docs.juliaplots.org/latest/generated/colorschemes/
## https://docs.makie.org/stable/documentation/transparency/ 

n = 500 ; x = rand(n) ; y = rand(n)
z = vcat(repeat(["B"], 20), repeat(["A"], n - 20))
group = recodcat2int(z)

f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group)
f

#### ColorSchemes

colsh = [:red; :blue]
#colsh = [(:red, .5); (:blue, .5)]
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, 
    colormap = colsh)
f

colsh = :default
#colsh = :Dark2_5
#colsh = [:red; :blue]
cgrad(colsh)
cgrad(colsh; categorical = true)
cgrad(colsh, 3; categorical = true)
cgrad(colsh, 3; categorical = true, rev = true)

colm = cgrad(:Dark2_5; categorical = true)
colm[1:2]

nlev = 2
cols = cgrad(:Dark2_5; categorical = true,
    alpha = .8)[1:nlev]
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, 
    colormap = cols)
f

## With Legend
lev = sort(unique(z))
nlev = length(lev)
cols = cgrad(:Dark2_5; categorical = true,
    alpha = .8)[1:nlev]
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, 
    colormap = cols)
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 10) for i in 1:nlev]
lab = copy(lev) 
title = "Type"
Legend(f[1, 2], elt, lab, title; 
    nbanks = 1, rowgap = 10, bgcolor = "lightgrey")
f

################# ERRORBARS 

x = 0:0.5:10
y = 0.5 .* sin.(x)
n = length(x)
lowerrors = fill(0.1, n)
higherrors = LinRange(0.1, 0.4, n)

# Same low and high errors 
f = Figure()
Axis(f[1, 1])
scatter!(x, y; markersize = 25, color = :green)
scatter!(x, y; markersize = 15, color = :lightgrey)
errorbars!(x, y, higherrors; color = :red) 
f

# Different low and high errors
f = Figure()
Axis(f[1, 1])
scatter!(x, y; markersize = 25, color = :green)
scatter!(x, y; markersize = 15, color = :lightgrey)
errorbars!(x, y, higherrors; color = :red) # same low and high error
f

# Horizontal
f = Figure()
Axis(f[1, 1])
scatter!(y, x, markersize = 20, color = :grey)
errorbars!(y, x, higherrors; 
    whiskerwidth = 15, direction = :x)
f

################# EXPORT

## https://makie.juliaplots.org/stable/documentation/backends_and_output/figure_size/

################# HISTOGRAMS 

## https://docs.makie.org/stable/examples/plotting_functions/hist/

x = randn(1000)
f, ax = hist(x, bins = 50)
xlims!(ax, [-5, 5])
f

x = randn(1000)
f = Figure()
hist(f[1, 1], x, bins = 10)
hist(f[1, 2], x, bins = 20, color = :red, strokewidth = 1, 
    strokecolor = :black)
hist(f[2, 1], x, bins = [-5, -2, -1, 0, 1, 2, 5], color = :gray)
hist(f[2, 2], x, normalization = :pdf)
f

f = Figure()
ax = Axis(f[1, 1])
for i in 1:5
     hist!(ax, randn(1000), scale_to = -0.6, 
         offset = i, direction = :x)
end
f

n = 300
y = rand(n) ; year = sample(2000:2002, n)
years = sort(unique(year))

f = Figure(resolution = (500, 400))
Axis(f[1, 1], xlabel = "Y", ylabel = "Density")
for i in 1:length(years)
    s = year .== years[i]
    density!(y[s]; label = string(years[i]))
end
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [0.; 1.5; 3]
Axis(f[1, 1], xlabel = "Y", ylabel = "Density",
    yticks = (offs, string.(years)))
for i in 1:length(years)
    s = year .== years[i]
    density!(y[s]; offset = offs[i], 
        label = string(years[i]), bandwidth = 0.2)
end
f

f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "Y", ylabel = "Nb. observations")
s = year .== years[1]
hist!(ax, y[s]; bins = 50, label = string(years[1]))
s = year .== years[2]
hist!(ax, y[s] .+ .5; bins = 50, label = string(years[2]))
axislegend(position = :rt)
f[1, 1] = ax
f

################# LAYOUT 

x = rand(20)
f = Figure()
ax1 = Axis(f[1, 1])
ax2 = Axis(f[1, 2])
lines!(ax1, x)
lines!(ax2, -x)
f

x = rand(20)
f = Figure()
ax1 = Axis(f)
ax2 = Axis(f)
lines!(ax1, x)
lines!(ax2, -x)
f[1, 1] = ax1
f[2, 1] = ax2
f

f = Figure()
ax1 = f[1, 1]
scatter(ax1, rand(100, 2))
ax2 = f[1, 2]
lines(ax2, cumsum(randn(100)))
heatmap(f[1, 3], randn(10, 10))
f

x = LinRange(0, 10, 100)
y = sin.(x)
f = Figure()
lines(f[1, 1], x, y, color = :red)
lines(f[1, 2], x, y, color = :blue)
lines(f[2, 1:2], x, y, color = :green)
f

let
    ## https://discourse.julialang.org/t/beautiful-makie-gallery/62523/31
    n = 200
    x, y, color = randn(n) / 2, randn(n), randn(n)
    f = Figure(resolution = (700, 700))
    ax1 = Axis(f, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1, ytickalign = 1)
    ax2 = Axis(f, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1, ytickalign = 1)
    ax3 = Axis(f, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1, ytickalign = 1)
    hist!(ax1, x, color = (:orange, 0.5), strokewidth = 0.5)
    scatter!(ax2, x, y, color = color, colormap=:plasma, markersize = 10,
        marker = :circle, strokewidth = 0)
    density!(ax3, y, direction = :y, color = (:dodgerblue, 0.5), strokewidth = 0.5)
    xlims!(ax1, -4, 4)
    limits!(ax2, -4, 4, -4, 4)
    ylims!(ax3, -4, 4)
    hidexdecorations!(ax1, ticks = false, grid = false)
    hideydecorations!(ax3, ticks = false, grid = false)
    f[0, 1] = ax1
    f[1, 1] = ax2
    f[1, 2] = ax3
    #f[1, 1] = ax1
    #f[2, 1] = ax2
    #f[2, 2] = ax3
    f
    colsize!(f.layout, 1, Relative(2 / 3))
    rowsize!(f.layout, 1, Relative(1 / 3))
    colgap!(f.layout, 10)
    rowgap!(f.layout, 10)
    f
end

################# LEGEND 

## https://docs.makie.org/v0.19/examples/blocks/legend/index.html

n = 100
x = range(0, 10; length = n)
y1 = sin.(x)
y2 = cos.(x)

f, ax = lines(x, y1; color = :red, label = "sin")
lines!(ax, x, y2; color = :green, label = "cos")
axislegend()
f

f = Figure(resolution = (500, 300))
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
cols = (:red, :blue, :orange)
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1], xlabel = "x")
for i = 1:nlev
    s = typ .== lev[i]
    hist!(ax, x[s] .+ i / 1.2; bins = 50, 
        color = (cols[i], .5), label = string(lev[i]))
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

f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1], xlabel = "x")
for i = 1:nlev
    s = typ .== lev[i]
    hist!(ax, x[s] .+ i / 1.2; bins = 50, 
        color = (cols[i], .5), label = string(lev[i]))
end
f[1, 2] = Legend(f, ax, "Type", framevisible = false)
f

f = Figure(resolution = (800, 300))
ax = list(3)
y = [5.82; 4.00; 1.60; 4.23; 2.20; 1.63; 6.10; 6.30; 6.13]
z = [5.26; 3.65; 1.69; 4.35; 2.12; 1.40; 4.60; 6.96; 5.18]
x = collect(1:length(y))
ax[1] = Axis(f, 
            xlabel = "Error", ylabel = "k", 
            yticks = (x, string.(x)), title = "Ligneous")
lines!(ax[1], y, x)
lines!(ax[1], z, x)
f[1, 1] = ax[1] 
y = [2.84; 2.66; 2.80; 2.63; 1.02; .75; 4.79; 3.52; 4.61]
z = [2.99; 2.58; 2.48; 2.63; .93; .81; 4.60; 3.60; 4.41]
ax[2] = Axis(f, 
            xlabel = "Error", ylabel = "k", 
            yticks = (x, string.(x)), title = "Grasslands")
lines!(ax[2], y, x)
lines!(ax[2], z, x)
f[1, 2] = ax[2] 
y = [1.73; .70; 1.16; 1.59; .63; .68; 2.83; 2.20; 2.57]
z = [1.85; .89; 1.28; 1.68; .64; .70; 2.83; 2.49; 2.71]
ax[3] = Axis(f, 
            xlabel = "Error", ylabel = "k", 
            yticks = (x, string.(x)), title = "Sorghum")
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
f = Figure(resolution = (500, 300))
cols = cgrad(colsh; categorical = true, alpha = .7)[1:nlev] 
ax = Axis(f, xlabel = "x", ylabel = "y")
scatter!(ax, x, y;
    markersize = 15, color = group, colormap = cols)
f[1, 1] = ax 
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 20) for i in 1:nlev]
title = "Category"
Legend(f[1, 2], elt, lev, title; 
    nbanks = 1, rowgap = 10, bgcolor = :lightgrey, 
    framevisible = true, framecolor = :grey)
f

x = [ones(3); 2 * ones(3)]
y = rand(6)
grp = repeat(1:3, 2)
colors = Makie.wong_colors()
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], yticks = (1:2, ["hays"; "legumes"]),
        title = "Error rate")
barplot!(ax, x, y; direction = :x, 
    dodge = grp, color = colors[grp])
lab = ["A"; "B"; "C"] 
elt = [PolyElement(polycolor = colors[i]) for i in 1:length(lab)]
title = "Model"
Legend(f[1, 2], elt, lab, title)
f

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], yticks = (1:2, ["hays"; "legumes"]),
        title = "Error rate")
barplot!(ax, x, y; direction = :x, 
    dodge = grp, color = colors[grp])
lab = ["A"; "B"; "C"]
mks_l = 10
elt1 = MarkerElement(color = cols[1], marker = '●', markersize = mks_l)
elt2 = MarkerElement(color = cols[2], marker = '●', markersize = mks_l)
elt3 = MarkerElement(color = cols[3], marker = '●', markersize = mks_l)
elt = [elt1; elt2; elt3]
title = "Model"
Legend(f[1, 2], elt, lab, title)
f

################# LIMITS

n = 1000
x = rand(n) 
y = 5 * x + 10 * rand(n) 
z = [x ; y] 

f, ax = scatter(x, y)
xlims!(ax, minimum(z), maximum(z))
ylims!(ax, minimum(z), maximum(z))
f

f, ax = scatter(x, y)
limits!(ax, minimum(z), maximum(z), minimum(z), maximum(z))
f

################# LINES 

x = range(0, 10; length = 100)
y1 = sin.(x)
y2 = cos.(x)
f, ax = lines(x, y1, color = :red, linewidth = 2)
lines!(ax, x, y2, color = :blue, linestyle = :dot) 
f

n = 10 ; p = 100
X = randn(n, p)
w = collect(1:p) 
f, ax = lines(w, X[1, :])
for i in 2:n
    lines!(ax, w, X[i, :])
end
f

f, ax = lines(w, X[1, :])
map(i -> lines!(ax, w, X[i, :]), 1:n)
f

x = 0:0.01:1
p = -10:1:10
p = filter(x -> x != 0, collect(p))
Y = zeros(length(x), length(p))
for (indx, i) in enumerate(p)
    if i <= -1
        Y[:, indx] = x.^(1 / abs(i))
    else
        Y[:, indx] = x.^i
    end
end
cbarPal = :thermal
cmap = get(colorschemes[cbarPal], LinRange(0, 1, length(p)))
f = Figure(resolution = (700, 450), font =:sans, fontsize = 18)
ax = Axis(f, aspect = 1, xlabel = "x", ylabel = "xᵖ")
lins = [lines!( x, Y[:, v], color = cmap[v]) for v in 1:length(p)]
leg = Legend(f, lins, string.(p), "p", nbanks = 2, labelsize = 12,
    valign = :center)
f[1, 1] = ax
f[1, 2] = leg
f

################# MARKERS 

## https://docs.makie.org/stable/examples/plotting_functions/scatter/

n = 10
x = rand(n) ; y = rand(n)
z = 1:n

scatter(x, y;
    marker = '1', markersize = 30)

scatter(x, y;
    marker = '✈', markersize = 50)
    
scatter(x, y;
    marker = :utriangle, markersize = 20)

f, ax = scatter(x, y)
text!(ax, x, y; text = string.(z), fontsize = 25)
f

f, ax = scatter(x, y; marker = ' ')
text!(ax, x, y; text = string.(z), fontsize = 25,
    align = (:center, :center))
f

f = Figure()
ax = Axis(f[1, 1])
scatter!(x[1:5], y[1:5];
    marker = :utriangle, markersize = 20, label = "A")
scatter!(x[6:10], y[6:10];
    marker = :diamond, markersize = 20, label = "B")
axislegend(ax)
f

zm = vcat(repeat([:circle], 5), repeat(['X'], 5)) 
scatter(x, y;
    marker = zm, markersize = 20)

################## SCATTER 

x = range(0, 10, length = 100)
y = sin.(x)
scatter(x, y)

n = 100
x = range(0, 10; length = n)
y1 = sin.(x)
y2 = cos.(x)
f, ax = scatter(x, y1, color = 1:length(x), colormap = :tab10, 
    label = "sin", linewidth = 4)
scatter!(ax, x, y2, color = 1:length(x), colormap = :inferno, 
    label = "cos", linewidth = 4)
axislegend()
f

scatter(rand(10000), color = (:red, .5))

n = 50 
x, y, color = rand(n), rand(n), rand(n)
cmaps = [:cool, :viridis, :plasma, :inferno, :thermal, :leonardo, :winter, :spring, :ice] 
markers = [:+, :diamond, :star4, :rtriangle, :rect, :circle, :pentagon, :cross,:star5] 
function FigGridScatters()
    f = Figure(resolution = (1200, 800))
    c = 1
    for i in 1:2, j in 1:2:5
        ax = Axis(f[i, j],aspect = 1,xgridstyle=:dash,ygridstyle=:dash,
                                xtickalign=1, ytickalign=1)
        pnts = scatter!(x, y.^c, color = color, colormap=cmaps[c],
                markersize = 15, marker = markers[c], strokewidth=0)
        limits!(ax, -0.1, 1.1, -0.1, 1.1)
        ax.xticks = [0, 1]
        ax.yticks = [0, 1]
        ax.xticklabelsize = 20
        ax.yticklabelsize = 20
        cbar = Colorbar(f, pnts, height = Relative(0.75), tickwidth = 2,
                            tickalign = 1, width = 14, ticksize = 14)
        f[i, j+1] = cbar
        c+=1
    end
    f
end
f = FigGridScatters()

################## TRANSPARENCY 

n = 10000 ; p = 2 
X = randn(n, p) 
scatter(X[:, 1], X[:, 2]; color = (:blue, .3))


