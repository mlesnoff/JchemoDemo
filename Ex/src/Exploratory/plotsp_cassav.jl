using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y
ntot = nro(X)

@head X
@head Y

y = dat.Y.tbc
year = dat.Y.year

wl = names(X)
wl_num = parse.(Float64, wl) 

tab(year)

plotsp(X).f

plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

plotsp(X, wl_num;
    color = (:red, .3),
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

plotsp(X, wl_num; nsamp = 10, 
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

i = 1
plotsp(X[i:i, :], wl_num;
    color = :blue,
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data").f

f, ax = plotsp(X, wl_num;
    color = (:grey70, .5),
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Cassava data")
lines!(ax, wl_num, colmean(X); color = :red,
    linewidth = 2)
f

