## Example of calibration transfert between two machines, 
## without standards and by orthogonalization, 
## using function 'difmean'.

using JLD2, CairoMakie, FreqTables
using Jchemo, JchemoData
using GLMakie
CairoMakie.activate!()  

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/corn.jld2") 
@load db dat
pnames(dat)
Xm5 = dat.Xm5
Xmp5 = dat.Xmp5
Xmp6 = dat.Xmp6
Y = dat.Y 
ntot = nro(Xm5)
wlst = names(dat.Xm5)
wl = parse.(Float64, wlst)
namy = names(Y)

summ(Y).res

plotsp(Xm5, wl; xlabel = "Wavelength (nm)", ylabel = "Reflectance").f

mod1 = snv(centr = true, scal = true)
mod2 = savgol(npoint = 11, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, Xm5)
Xpm5 = transf(mod, Xm5)
Xpmp5 = transf(mod, Xmp5)
Xpmp6 = transf(mod, Xmp6)

X1 = copy(Xpm5)
X2 = copy(Xpmp6)
n1 = nro(X1)
n2 = nro(X2)    

#### Plotting spectra

## Before transfert
i = 40
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
lines!(X1[i, :]; label = "x1")
lines!(ax, X2[i, :]; label = "x2")
axislegend(position = :rb, framevisible = false)
f
## After transfert
res = difmean(X1, X2) ;
fm0 = eposvd(res.D; nlv = 1) ;
M = fm0.M    # orthogonalization matrix
X1c = X1 * M
X2c = X2 * M
f = Figure(size = (500, 300))
ax = Axis(f[1, 1])
lines!(X1c[i, :]; label = "x1_correct")
lines!(ax, X2c[i, :]; label = "x2_correct")
axislegend(position = :rb, framevisible = false)
f

#### Plotting spectral spaces

## Before transfert
mod = pcasvd(nlv = 10)
fit!(mod, X1)
T1 = mod.fm.T
T2 = transf(mod, X2)
i = 1
f, ax = plotxy(T1[:, i], T1[:, i + 1]; xlabel = string("PC", i), 
    ylabel = string("PC", i + 1))
scatter!(ax, T2[:, i], T2[:, i + 1])
f
## After transfert
res = difmean(X1, X2) ;
fm0 = eposvd(res.D; nlv = 1) ;
X1c = X1 * fm0.M
X2c = X2 * fm0.M
mod = pcasvd(nlv = 10)
fit!(mod, X1c)
T1 = mod.fm.T
T2 = transf(mod, X2c)
i = 1
f, ax = plotxy(T1[:, i], T1[:, i + 1]; xlabel = string("PC", i), 
    ylabel = string("PC", i + 1))
scatter!(ax, T2[:, i], T2[:, i + 1])
f

#### Predictions

## Build of training and test sets 
## Switch of the train and test observations between
## the two machines since corn data contains actually standards
m = Int(round(n1 / 2))
s = sampdp(hcat(X1, X2), m) 
## Machine 1
X1train = X1[s.train, :]
Y1train = Y[s.train, :]
X1test = X1[s.test, :]
Y1test = Y[s.test, :]
## Machine 2
X2train = X2[s.train, :]
Y2train = Y[s.train, :]
X2test = X2[s.test, :]
Y2test = Y[s.test, :]
## End
n1train = nro(X1train)
n1test = nro(X1test)
n2train = nro(X2train)
n2test = nro(X2test)
(n1 = n1, n2, n1train, n1test, n2train, n2test)

## Selection of the y-variable
j = 1  
println(namy[j])
y1train = Y1train[:, j]
y1test = Y1test[:, j]
y2train = Y2train[:, j]
y2test = Y2test[:, j]

## Model tuning and performance on the reference data,
## within each machine (benchmark)
## On machine 1
zXtrain = copy(X1train)
zytrain = copy(y1train)
zn = copy(n1train)
zXtest = copy(X1test)
zytest = copy(y1test) 
## On machine 2
#zXtrain = copy(X2train)
#zytrain = copy(y2train)
#zn = copy(n2train)
#zXtest = copy(X2test)
#zytest = copy(y2test)
# End 
K = 5
segm = segmkf(zn, K; rep = 20)
nlv = 0:15
mod = plskern()
res = gridcv(mod, zXtrain, zytrain; segm, score = rmsep, 
    nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
mod = plskern(nlv = res.nlv[u])
fit!(mod, zXtrain, zytrain)
pred = predict(mod, zXtest).pred
@show rmsep(pred, zytest)
plotxy(pred, zytest; bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f

## Model tuning after transfert, within each machine
D = difmean(X1train, X2train).D
M = eposvd(D; nlv = 1).M
## On machine 1
zXtrain = X1train * M 
zytrain = copy(y1train)
zn = copy(n1train) 
## On machine 2
#zXtrain = X2train * M
#zytrain = copy(y2train)
#zn = copy(n2train) 
## End
K = 5
segm = segmkf(zn, K; rep = 20)
nlv = 0:15
mod = plskern()
res = gridcv(mod, zXtrain, zytrain; segm, score = rmsep, 
    nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]

## Model performance after transfert, within each machine
res = difmean(X1train, X2train)
M = eposvd(res.D; nlv = 1).M 
## On machine 1
zXtrain = X1train * M
zytrain = copy(y1train)
zXtest = X1test * M     # correction not required if PLSR (othogonalization is embedded)
#zXtest = copy(X1test)  # would be enough here (PLSR) 
zytest = copy(y1test)
## On machine 2
#zXtrain = X2train * fm0.M
#zytrain = copy(y2train)
#zXtest = X2test * M     # correction not required if PLSR (othogonalization is embedded)
##zXtest = copy(X2test)  # would be enough here (PLSR) 
#zytest = copy(y2test)
## End
nlv = 7   # compromise between machines, for the given y-variable (here j = 1)
mod = plskern(; nlv)
fit!(mod, zXtrain, zytrain)
pred = predict(mod, zXtest).pred    # test predictions on corrected spectra
@show rmsep(pred, zytest)
plotxy(pred, zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f


