
using Jchemo, JchemoData
using JLD2, CairoMakie


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


wlst = names(X)
wl = parse.(Float64, wlst)


tab(year)


plotsp(X).f


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance", title = "Cassava data").f


plotsp(X, wl; color = (:red, .3), xlabel ="Wavelength (nm)", ylabel = "Absorbance", title = "Cassava data").f


plotsp(X, wl; nsamp = 10, xlabel ="Wavelength (nm)", ylabel = "Absorbance", title = "Cassava data").f


plotsp(X, wl; nsamp = 1, xlabel ="Wavelength (nm)", ylabel = "Absorbance", title = "Cassava data").f


i = 1
plotsp(X[i:i, :], wl; color = :blue, xlabel ="Wavelength (nm)", ylabel = "Absorbance", title = "Cassava data").f


f, ax = plotsp(X, wl; color = (:grey70, .5), xlabel ="Wavelength (nm)", ylabel = "Absorbance", 
    title = "Cassava data")
lines!(ax, wl, colmean(X); color = :red, linewidth = 2)
f

