using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
CairoMakie.activate!()  

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "octane.jld2") 
@load db dat
pnames(dat)

X = dat.X 
wl = names(X)
wl_num = parse.(Float64, wl)
n = nro(X)

## Model fitting
fm = pcasvd(X; nlv = 3) ; 
#fm = pcasph(X; nlv = 3) ;    # Robust PCA 
pnames(fm)

## Score distance (SD)
res = occsd(fm) ;
pnames(res)
d = res.d
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f

## Orthogonal distance (OD)
res = occod(fm, X) ;
pnames(res)
d = res.d
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f

## SD-OD
sd = occsd(fm).d
od = occod(fm, X).d
plotxy(sd.dstand, od.dstand;
    xlabel = "Standardized SD", ylabel = "Standardized OD").f

GLMakie.activate!() 
#CairoMakie.activate!()  
sd = occsd(fm).d
od = occod(fm, X).d
f, ax = plotxy(sd.dstand, od.dstand;
    xlabel = "Standardized SD", ylabel = "Standardized OD")
text!(ax, sd.dstand, od.dstand; text = string.(1:n), 
    fontsize = 15)
f

## Direct computation of a composite SD-OD
res = occsdod(fm, X) ;
pnames(res)
d = res.d
f, ax = plotxy(1:n, d.dstand;
    xlabel = "Observation", 
    ylabel = "Standardized SD-OD distance")
text!(ax, 1:n, d.dstand; text = string.(1:n), 
    fontsize = 15)
f

