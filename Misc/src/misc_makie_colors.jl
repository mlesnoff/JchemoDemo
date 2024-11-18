using CairoMakie, Jchemo

## https://docs.makie.org/stable/documentation/colors/
## https://docs.makie.org/stable/documentation/transparency/ 
## https://docs.juliaplots.org/latest/generated/colorschemes/
## http://juliagraphics.github.io/Colors.jl/stable/

n = 500 ; m = 50
x = rand(n) ; y = rand(n)
z = vcat(repeat(["B"], m), repeat(["A"], n - m))
group = recod_catbyint(z)
lev = mlev(z)
nlev = length(lev)

f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group)
f

colm = [:red; :blue]
#colm = [(:red, .5); (:blue, .5)]
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, colormap = colm)
f

## Palettes from colorschemes
colsh = :default
#colsh = :tab10
#colsh = :Dark2_5
#colsh = [:red; :blue]
cgrad(colsh)
cgrad(colsh; alpha = .6)
## Discrete
cgrad(colsh; categorical = true)
cgrad(colsh, 3; categorical = true)
cgrad(colsh)[1:3]
cgrad(colsh, 3; categorical = true, alpha = .5)
cgrad(colsh, 3; categorical = true, rev = true)
cgrad(colsh, 15; categorical = true)
cgrad(colsh, 15; categorical = true)[1:2]
cgrad(colsh, 15)[1:2]


cgrad(:Dark2_5) 
cgrad(:Dark2_5; categorical = true) 
cgrad(:Dark2_5; categorical = true)[1:2]
cgrad(:Dark2_5)[1:2]
## Note the difference with:
cgrad(:Dark2_5, 2; categorical = true)

colm = cgrad(:Dark2_5; categorical = true, alpha = .8)[1:nlev]
#colm = cgrad(:Dark2_5, 2; categorical = true, alpha = .8)
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, colormap = colm)
f

colm = cgrad(:default; alpha = .8)
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = y, colormap = colm)
f

## With Legend
colm = cgrad(:Dark2_5; categorical = true, alpha = .8)[1:nlev]
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, colormap = colm)
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
lab = copy(lev) 
title = "Type"
Legend(f[1, 2], elt, lab, title; nbanks = 1, rowgap = 10, backgroundcolor = "lightgrey")
f

colm = cgrad(:Accent_5, nlev; categorical = true, alpha = .8)
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
scatter!(ax, x, y; color = group, colormap = colm)
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
lab = copy(lev) 
title = "Type"
Legend(f[1, 2], elt, lab, title; framevisible = false)
f

##############

f = Figure()
Axis3(f[1, 1])
Colorbar(f[1, 2]; colormap = :viridis, limits = (0, 10), flipaxis = false)
f
