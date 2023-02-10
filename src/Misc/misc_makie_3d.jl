using CairoMakie, GLMakie

## https://docs.makie.org/stable/examples/plotting_functions

################ CONTOUR 

CairoMakie.activate!()  
#GLMakie.activate!() 

n = 100
x = LinRange(0, 10, n) 
y = LinRange(0, 15, n) 
z = [cos(x) * sin(y) for x in x, y in y] 

contour(z;
    axis = (xlabel = "a", ylabel = "b", 
        title = "Cos(a) * Sin(a)"))

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1]; xlabel = "a", ylabel = "b", 
        title = "Cos(a) * Sin(a)")
contour!(ax, x, y, z; levels = 10)
f

contourf(z;
    axis = (xlabel = "a", ylabel = "b", 
        title = "Cos(a) * Sin(a)"))

## Contour withi vortex
x = randn(200)
y = randn(200)
z = x .* y
f, ax, tr = tricontourf(x, y, z, colormap = :batlow)
scatter!(x, y, color = z, colormap = :batlow, strokewidth = 1, strokecolor = :black)
Colorbar(f[1, 2], tr)
f

################ HEATMAP 


CairoMakie.activate!()  
#GLMakie.activate!() 

x = [1, 2, 3, 1, 2, 3, 1, 2, 3]
y = [1, 1, 1, 2, 2, 2, 3, 3, 3]
z = [1, 2, 3, 4, 5, 6, 7, 8, NaN]
heatmap(x, y, z)

n = 100
x = range(0, 2π, length = n)
y = range(0, 2π, length = n)
z = 10 * [sin(x * y) for x in x, y in y]
f, ax, hm = heatmap(x, y, z)
Colorbar(f[:, end + 1], hm)
f

rg = (minimum(z), maximum(z))
f, ax = heatmap(x, y, z)
Colorbar(f[:, end + 1], colorrange = rg)
f

rg = (minimum(z), maximum(z))
cmp = :thermal
f = Figure()
ax = Axis(f[1, 1]; aspect = 1, 
    xlabel = "x axis", ylabel = "y axis")
heatmap!(ax, x, y, z; colormap = cmp)
Colorbar(f[:, end + 1]; colorrange = rg,
    colormap = cmp)
f

n = 100 ; p = 200 
X = 20 * rand(n, p) 
f = Figure(backgroundcolor = :lightgrey)
ax = f[1, 1]
heatmap(ax, X)
f

f = Figure()
ax = Axis(f[1, 1]; aspect = 1, xlabel = "x axis", ylabel = "y axis")
heatmap!(ax, X)
Colorbar(f[1, 2])
f

f, ax, hm = heatmap(X;
    figure = (backgroundcolor = :lightgrey,),
    axis = (aspect = 1, xlabel = "x axis", 
        ylabel = "y axis"))
Colorbar(f[1, 2], hm)
f

################ SCATTER X-Y-Z 

n = 100
X1 = randn(n, 3)
X2 = 2 * randn(n, 3) .+ 3
X3 = .5 * randn(n, 3) .- [10 2 1]
X = vcat(X1, X2, X3)
year = sort(repeat(2009:2011, n))
x = X[:, 1]
y = X[:, 2]
z = X[:, 3]
lev = sort(unique(year))
nlev = length(lev)

CairoMakie.activate!()  
#GLMakie.activate!() 
mks = 20
scatter(x, y, z, 
    markersize = mks, color = year, colormap = (:Dark2_5, .7),
    axis = (type = Axis3, xlabel = "Axis 1", ylabel = "Axis 2", 
        zlabel = "Axis 3", title = "3D"))

f = Figure(resolution = (700, 500))
mks = 15
ax = Axis3(f[1, 1]; aspect = (1, 1, 1), perspectiveness = 0.2)
scatter!(ax, x, y, z,
    markersize = mks, color = year, colormap = (:Dark2_5, .7))
f

f = Figure(resolution = (700, 500))
mks = 15
cols = cgrad(:Dark2_5, collect(1:nlev); alpha = .7) 
#cols = cgrad(:tab10, collect(1:nlev); alpha = .3) 
ax = Axis3(f[1, 1];
    xlabel = "Axis 1", ylabel = "Axis 2", 
    zlabel = "Axis 3", 
    perspectiveness = 0.2, azimuth = 1.2pi) 
scatter!(ax, x, y, z, 
    markersize = mks, color = year, colormap = (:Dark2_5, .7))
## Legend
lab = string.(lev)
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = cols[i]) for i in 1:nlev]
title = "Years"
Legend(f[1, 2], elt, lab, title; 
    nbanks = 1, rowgap = 10, framevisible = false)
f
## Alternative
mks_l = 10
elt1 = MarkerElement(color = cols[1], marker = '●', markersize = mks_l)
elt2 = MarkerElement(color = cols[2], marker = '●', markersize = mks_l)
elt3 = MarkerElement(color = cols[3], marker = '●', markersize = mks_l)
Legend(f[1, 2], [elt1, elt2, elt3], lab)
f
## End

## Function axislegend does not work
f = Figure(resolution = (800, 500))
cols = cgrad(:Dark2_5, collect(1:nlev); alpha = .7) 
#cols = cgrad(:tab10, collect(1:nlev); alpha = .3) 
mks = 10 ; i = 1
ax = Axis3(f[1, 1]; aspect = (1, 1, 1), perspectiveness = 0.5)  
for j = 1:nlev
    s = year .== lev[j]
    scatter!(ax, x[s], y[s], z[s], 
        markersize = mks, color = cols[j], label = lev[j])
end
#axislegend(ax, position = :rb)
#f[1, 2] = Legend(f, ax, "Type", framevisible = false) 
f
## End

## https://juliadatascience.io/glmakie
n = 10
x, y, z = randn(n), randn(n), randn(n)
f = Figure(resolution = (1200, 400))
ax1 = Axis3(f[1, 1]; aspect = (1, 1, 1), perspectiveness = 0.5)
ax2 = Axis3(f[1, 2]; aspect = (1, 1, 1), perspectiveness = 0.5)
ax3 = Axis3(f[1, 3]; aspect = :data, perspectiveness = 0.5)
scatter!(ax1, x, y, z; markersize = 15)
meshscatter!(ax2, x, y, z; markersize = 0.25)
hm = meshscatter!(ax3, x, y, z; markersize = 0.25,
    marker = Rect3f(Vec3f(0), Vec3f(1)), color = 1:n,
    colormap = :plasma, transparency = false)
Colorbar(f[1, 4], hm, label = "values", height = Relative(0.5))
f

################ SURFACE 

CairoMakie.activate!()  
#GLMakie.activate!() 

n = 100
x = LinRange(0, 10, n) 
y = LinRange(0, 15, n) 
z = [cos(x) * sin(y) for x in x, y in y] 

surface(z,
    axis = (type = Axis3, xlabel = "a", ylabel = "b", zlabel = "",
        title = "Cos(a) * Sin(a)", perspectiveness = 0))

f = Figure(resolution = (500, 400))
ax = Axis3(f[1, 1]; xlabel = "a", ylabel = "b", zlabel = "", 
        title = "Cos(a) * Sin(a)")
surface!(ax, x, y, z)
f

## https://juliadatascience.io/glmakie
function peaks(; n = 49)
    x = LinRange(-3, 3, n)
    y = LinRange(-3, 3, n)
    a = 3 * (1 .- x') .^ 2 .* exp.(-(x' .^ 2) .- (y .+ 1) .^ 2)
    b = 10 * (x' / 5 .- x' .^ 3 .- y .^ 5) .* exp.(-x' .^ 2 .- y .^ 2)
    c = 1 / 3 * exp.(-(x' .+ 1) .^ 2 .- y .^ 2)
    return (x, y, a .- b .- c)
end
x, y, z = peaks()
f = Figure(resolution = (1200, 400))
ax = [Axis3(f[1, i]) for i = 1:3]
hm = heatmap!(ax[1], x, y, z)
contour!(ax[2], x, y, z; levelt=20)
contourf!(ax[3], x, y, z)
Colorbar(f[1, 4], hm, height = Relative(0.5))
f

################ WIREFRAME

x, y = collect(-8:0.5:8), collect(-8:0.5:8)
z = [sinc(√(X^2 + Y^2) / π) for X ∈ x, Y ∈ y]
wireframe(x, y, z, 
    axis = (; type = Axis3), color = :grey)




