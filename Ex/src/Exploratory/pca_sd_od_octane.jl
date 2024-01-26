
using Jchemo, JchemoData
using JLD2, CairoMakie, GLMakie


CairoMakie.activate!()
#GLMakie.activate!()


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)


X = dat.X 
n = nro(X)


@head X


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance",
    title = "Octane data").f


mod = pcasvd(nlv = 6) 
## For robust spherical PCA, do:
#mod = pcasph(nlv = 6)
fit!(mod, X)  
pnames(mod)
pnames(mod.fm)
fm = mod.fm


@head T = mod.fm.T


mod = occsd()
fit!(mod, fm)
pnames(mod)
pnames(mod.fm)


d = mod.fm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


mod = occod() 
fit!(mod, fm, X)
pnames(mod)
pnames(mod.fm)


d = mod.fm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


mod = occsd()
fit!(mod, fm)
d_sd = mod.fm.d
mod = occod()
fit!(mod, fm, X)
d_od = mod.fm.d
f, ax = plotxy(d_sd.dstand, d_od.dstand; xlabel = "Standardized SD", 
    ylabel = "Standardized OD")
hlines!(ax, 1)
vlines!(ax, 1)
f


f, ax = plotxy(d_sd.dstand, d_od.dstand; xlabel = "Standardized SD", 
    ylabel = "Standardized OD")
text!(ax, d_sd.dstand, d_od.dstand; text = string.(1:n), fontsize = 15)
hlines!(ax, 1)
vlines!(ax, 1)
f


mod = occsdod() 
fit!(mod, fm, X)
pnames(mod)
pnames(mod.fm)


d = mod.fm.d


f, ax = plotxy(1:n, d.dstand; xlabel = "Observation", 
    ylabel = "Standardized SD-OD distance")
text!(ax, 1:n, d.dstand; text = string.(1:n), fontsize = 15)
hlines!(ax, 1)
f

