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
wl = names(dat.Xm5)
wl_num = parse.(Float64, wl)
namy = names(Y)

summ(Y).res

plotsp(Xm5, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Reflectance").f

fpreproc(X) = savgol(snv(X); f = 11, d = 2, pol = 3) 
Xpm5 = fpreproc(Xm5)
Xpmp5 = fpreproc(Xmp5)
Xpmp6 = fpreproc(Xmp6)

X1 = copy(Xpm5)
X2 = copy(Xpmp6)
n1 = nro(X1)
n2 = nro(X2)    

#### Plotting spectra

## Before transfert
i = 40
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
lines!(X1[i, :]; label = "x1")
lines!(ax, X2[i, :]; label = "x2")
axislegend(position = :rb, framevisible = false)
f
## After transfert
res = Jchemo.difmean(X1, X2) ;
fm0 = eposvd(res.D; nlv = 1) ;
M = fm0.M    # orthogonalization matrix
X1c = X1 * M
X2c = X2 * M
f = Figure(resolution = (500, 300))
ax = Axis(f[1, 1])
lines!(X1c[i, :]; label = "x1_correct")
lines!(ax, X2c[i, :]; label = "x2_correct")
axislegend(position = :rb, framevisible = false)
f

#### Plotting spectral spaces

## Before transfert
fm = pcasvd(X1; nlv = 10) ;
T1 = fm.T
T2 = Jchemo.transform(fm, X2)
i = 1
f, ax = plotxy(T1[:, i:(i + 1)];
    xlabel = string("PC", i), ylabel = string("PC", i + 1))
scatter!(ax, T2[:, i:(i + 1)])
f
## After transfert
res = Jchemo.difmean(X1, X2) ;
fm0 = eposvd(res.D; nlv = 1) ;
X1c = X1 * fm0.M
X2c = X2 * fm0.M
fm = pcasvd(X1c; nlv = 10) ;
T1 = fm.T
T2 = Jchemo.transform(fm, X2c)
i = 1
f, ax = plotxy(T1[:, i:(i + 1)];
    xlabel = string("PC", i), ylabel = string("PC", i + 1))
scatter!(ax, T2[:, i:(i + 1)])
f

#### Predictions

## Build of training and test sets 
## Switch of the train and test observations between
## the two machines since corn data contains actually standards
m = n1 / 2
res = sampdp(hcat(X1, X2); k = m) ;
pnames(res)
res.train
res.test
s = res.train
## Machine 1
X1train = X1[s, :]
Y1train = Y[s, :]
X1test = rmrow(X1, s)
Y1test = rmrow(Y, s)
## Machine 2
X2test = X2[s, :]
Y2test = Y[s, :]
X2train = rmrow(X2, s)
Y2train = rmrow(Y, s)
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
res = gridcvlv(zXtrain, zytrain; segm = segm,
    score = rmsep, fun = plskern, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = plskern(zXtrain, zytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, zXtest).pred
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f

## Model tuning after transfert, within each machine
D = Jchemo.difmean(X1train, X2train).D
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
res = gridcvlv(zXtrain, zytrain; segm = segm,
    score = rmsep, fun = plskern, nlv = nlv).res
plotgrid(res.nlv, res.y1).f
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
fm = plskern(zXtrain, zytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, zXtest).pred    # test predictions on corrected spectra
println(rmsep(pred, zytest))
plotxy(vec(pred), zytest;
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed").f


