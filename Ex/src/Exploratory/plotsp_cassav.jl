using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

```julia
using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)

```julia
X = dat.X
Y = dat.Y
ntot = nro(X)

```julia term = true
@head X
@head Y

```julia
y = dat.Y.tbc
year = dat.Y.year

```julia
wl = names(X)
wl_num = parse.(Float64, wl) 

```julia
tab(year)

```julia
plotsp(X).f

```julia
plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

```julia
plotsp(X, wl_num;
    color = (:red, .3),
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

```julia
plotsp(X, wl_num; nsamp = 10, 
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

```julia
i = 1
plotsp(X[i:i, :], wl_num;
    color = :blue,
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

```julia
f, ax = plotsp(X, wl_num;
    color = (:grey70, .5),
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data")
lines!(ax, wl_num, colmean(X); color = :red,
    linewidth = 2)
f

