using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
CairoMakie.activate!()  

#-
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/octane.jld2") 
@load db dat
pnames(dat)
  
#-
X = dat.X 
n = nro(X)

#-
@head X

#-
wl = names(X)
wl_num = parse.(Float64, wl)

#-
## Six of the samples of the dataset contain 
## added alcohol  (= 25, 26, and 36-39)
plotsp(X, wl_num;
    xlabel ="Wavelength (nm)", ylabel = "Absorbance",
    title = "Octane data").f

#-
## Model fitting
fm = pcasvd(X; nlv = 6) ; 
## For robust PCA:
#fm = pcasph(X; nlv = 6) ;  
pnames(fm)

#-
## Score distance (SD)
res = occsd(fm) ;
pnames(res)

#-
d = res.d

#-
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized score distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f

#-
## Orthogonal distance (OD)
res = occod(fm, X) ;
pnames(res)

#-
d = res.d

#-
f = Figure(resolution = (500, 400))
Axis(f[1, 1]; xlabel = "Standardized orthogonal distance", 
    ylabel = "Nb. observations")
hist!(d.dstand; bins = 20)
f

#-
## SD-OD
sd = occsd(fm).d
od = occod(fm, X).d
f, ax = plotxy(sd.dstand, od.dstand;
    xlabel = "Standardized SD", ylabel = "Standardized OD")
hlines!(ax, 1)
vlines!(ax, 1)
f

#-
CairoMakie.activate!()  
#GLMakie.activate!() 
sd = occsd(fm).d
od = occod(fm, X).d
f, ax = plotxy(sd.dstand, od.dstand;
    xlabel = "Standardized SD", ylabel = "Standardized OD")
text!(ax, sd.dstand, od.dstand; text = string.(1:n), 
    fontsize = 15)
hlines!(ax, 1)
vlines!(ax, 1)
f

#-
## Direct computation of a composite SD-OD
res = occsdod(fm, X) ;
pnames(res)

#-
d = res.d

#-
f, ax = plotxy(1:n, d.dstand;
    xlabel = "Observation", 
    ylabel = "Standardized SD-OD distance")
text!(ax, 1:n, d.dstand; text = string.(1:n), 
    fontsize = 15)
hlines!(ax, 1)
f

