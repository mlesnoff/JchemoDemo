
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


mo = pcasvd(nlv = 6) 
## For robust spherical PCA, do:
#mo = pcasph(nlv = 6)
fit!(mo, X)  
pnames(mo)
pnames(mo.fm)
fm = mo.fm


@head T = mo.fm.T


mo = occsd()
fit!(mo, fm)
pnames(mo)
pnames(mo.fm)


d = mo.fm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


mo = occod() 
fit!(mo, fm, X)
pnames(mo)
pnames(mo.fm)


d = mo.fm.d


f = Figure(size = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f


mo = occsd()
fit!(mo, fm)
d_sd = mo.fm.d
mo = occod()
fit!(mo, fm, X)
d_od = mo.fm.d
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


mo = occsdod() 
fit!(mo, fm, X)
pnames(mo)
pnames(mo.fm)


d = mo.fm.d


f, ax = plotxy(1:n, d.dstand; xlabel = "Observation", 
    ylabel = "Standardized SD-OD distance")
text!(ax, 1:n, d.dstand; text = string.(1:n), fontsize = 15)
hlines!(ax, 1)
f

