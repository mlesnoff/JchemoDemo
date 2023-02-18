using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "octane.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
wl = names(X)
wl_num = parse.(Float64, wl)

## Six of the samples (= 25, 26, and 36-39) of the dataset contain 
## added alcohol.

############ END DATA

fm = pcasvd(X, nlv = 3) ; 
pnames(fm)

res = occsd(fm).d
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", 
    ylabel = "Nb. observations")
hist!(res.dstand; bins = 20)
f

res = occod(fm, X).d
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", 
    ylabel = "Nb. observations")
hist!(res.dstand; bins = 20)
f

res_sd = occsd(fm).d
res_od = occod(fm, X).d
zsd = res_sd.dstand 
zod = res_od.dstand 
n = length(zsd)
f, ax = plotxy(zsd, zod;
    xlabel = "SD", ylabel = "OD")
f

CairoMakie.activate!()  
#GLMakie.activate!() 
res_sd = occsd(fm).d
res_od = occod(fm, X).d
zsd = res_sd.dstand 
zod = res_od.dstand 
n = length(zsd)
f, ax = plotxy(zsd, zod;
    xlabel = "SD", ylabel = "OD")
text!(ax, zsd, zod; text = string.(1:n), fontsize = 15)
f

res = occsdod(fm, X).d
n = length(zsd)
plotxy(1:n, res.dstand;
    xlabel = "Observation", 
    ylabel = "Standardized SD-OD distance").f


